Sometimes it is desirable to have a virtual ethernet LAN so all remote
peers appear to be within the same LAN. One example is various
network/LAN type multiuser games. This will allow all broadcast traffic
to make it to all remote parties as if they were on the same local LAN
network.

# EoIP and IPsec

This configuration uses the [linux-eoip
software](https://code.google.com/archive/p/linux-eoip/) together with
libreswan. The linux-eoip software is currently being added to
fedora/epel7, see this [review
bug](https://bugzilla.redhat.com/show_bug.cgi?id=1302989)

Note that at least for RHEL/Fedora, the linux-eoip package isn't
properly integrated yet, so some additional manual configuration for now
is required.

## eoip configuration

Create a bridge device for the LAN facing interface and assign a LAN IP
address, for example LAN-bro

On RHEL/Fedora you can use an ifcfg file in
/etc/sysconfig/networking-scripts

## add a libreswan connection

The IPsec connection needs to allow sending GRE (protocol 47) traffic.
If you have public IP addresses on the IPsec gateways (not behind a NAT
router) you can use IPsec transport mode to save a few bytes over tunnel
mode to increase the changes of the packet sizes not causing problems
(because protocols might assume a 1500 mtu to be always possible because
it thinks it is operating in a LAN). If one of the IPsec gateways is
behind NAT, you should use tunnel mode. This assumes the two gateways
have stable public IP addresses (PublicIP-A and PublicIP-B)

    # /etc/ipsec.d/tun-eoip.conf

    conn tun-eoip
        type=transport
        left=PublicIP-A
        initial-contact=yes
        leftsubnet=PublicIP-A/32
        leftid=pubipA
        leftprotoport=47/0
        right=PublicIP-B
        rightsubnet=PublicIP-B/32
        rightid=pubipB
        rightprotoport=47/0
        # you can also use raw RSA instead of PSK authentication
        authby=secret
        auto=start

    # /etc/ipsec./tun-eoip.secret

    PublicIP-A PublicIP-B : PSK "Someverylongsecurerandomsecret"

Once both ends are configured you can bring the tunnel up manually
using: ipsec auto --up tun-eoip

## Bridge configuration

    #  /etc/sysconfig/network-scripts/ifcfg-LAN-br0

    DEVICE=LAN-br0
    STP=no
    TYPE=Bridge
    BOOTPROTO=none
    DEFROUTE=no
    IPV4_FAILURE_FATAL=yes
    PEERDNS=no
    NAME=LAN-br0
    IPADDR=<ip-address-to-use>
    PREFIX=<cidr-netmask>
    UUID=<uuid-generated-with-uuidgen>
    IPV6INIT=no
    IPV6_DEFROUTE=no
    IPV6_PEERDNS=no
    ONBOOT=yes

Start bridge interface

    ifup LAN-br0

## EoIP tunnel configuration

Configure the LAN-br0 tunnel. Note the ID must be the same on both
sides.

    # /etc/eoip/eoip.cfg

    [zeoip0]
    id=2
    dst=pubipB
    dynamic=1

Bring up the eoip tunnel:

    eoip /etc/eoip/eoip.cfg

This will show a new zeoip0: device

    5: zeoip0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast master LAN-br0 state UNKNOWN qlen 500
    link/ether 92:ab:59:99:9e:db brd ff:ff:ff:ff:ff:ff
    inet6 fe80::90ab:59ff:fe99:9edb/64 scope link
    valid_lft forever preferred_lft forever

Add this to the bridge:

    brctl addif LAN-br0 zeoip0

## iptables configuration

The tunnel should allow GRE only over IPsec. You should also clamp the
MSS on the LAN bridge:

    iptables -A INPUT -i eth0 -p gre -m policy --dir in --pol ipsec -j ACCEPT
    iptables -A OUTPUT -p gre -m policy --dir out --pol ipsec --mode tunnel --tunnel-dst PublicIP-A --tunnel-src PublicIP-B -j ACCEPT

    iptables -A POSTROUTING -o LAN-br0 -p tcp -m tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu

This write up was contributed by [NetworkLab](http://networklab.global)