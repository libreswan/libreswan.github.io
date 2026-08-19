Split VPN is the term used to indicate you only want to use the VPN
connection to reach one or more remote subnets. In order words, this
type of VPN disables the "send all traffic through the VPN".

The configuration is basically the same as for [VPN server for remote
clients using
IKEv2](/HOWTO/VPN-server-for-remote-clients-using-IKEv2) except now
we indicate with leftsubnet= on the VPN server what the subnet is that
we are giving access to. The easiest way to ensure that the clients can
reach the subnet involved is to give them an address from that subnet
and enable proxy arp. For example, say you want clients to reach the
remote 10.10.0.0/16 network via the VPN server at IP 1.2.3.4. You grab
10.10.20.0/24 as the range for the VPN clients. Then you configure the
connection as follows (this example assumes certificates):

    conn access-vpn
        authby=rsasig
        ikev2=insist
        # support Apple and Windows at the same time
        ike=aes256-sha2_512;modp2048,aes128-sha2_512;modp2048
        esp=aes_gcm256-null,aes_gcm128-null,aes256-sha2_512,aes128-sha2_512
        auto=add
        rekey=no
        # fill in with your VPN server IP
        left=1.2.3.4
        leftcert=yourcert
        leftsendcert=always
        leftid=@yourFQDN
        leftsubnet=10.10.0.0/16
        rightaddresspool=10.10.20.1-10.10.20.254
        right=%any
        rightca=%same
        # make cisco clients happy
        cisco-unity=yes
        # address of your internal DNS server
        modecfgdns=10.10.10.10
        leftxauthserver=yes
        rightxauthclient=yes
        leftmodecfgserver=yes
        rightmodecfgclient=yes
        modecfgpull=yes
        dpddelay=9m
        dpdtimeout=30m
        dpdaction=clear
        fragmentation=yes
        # if you want an ipsec0 interface using VTI
        # vti-interface=ipsec0
        # vti-shared=yes
        # vti-routing=yes
        # mark=20/0xffffffff

And don't forget to enable proxyarp on the VPN server's internal
interface. If this is eth1, add to /etc/sysctl.conf (or equivalent file
in /etc/sysctl.d/)

    # eth1 is the internal interface with a 10.10.X.Y/16 IP address
    net.ipv4.conf.eth1.proxy_arp=1