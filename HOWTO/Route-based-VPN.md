Libreswan has, new in 2019, support for route based vpn using Linux XFRM
device. There will be an ipsec1 device where you can add routes or
"routing policies".

## Route-based VPNs using libreswan XFRM device

{{ ambox \| nocat=true \| type=speedy \| text = XFRMi support is
EXPERIMENTAL and the API and keywords are subject to change }}

By default Libreswan set up IPseec/VPN tunnels using IPsec policy alone,
without "ip routing". On Linux systems this is called a policy-based VPN
or IPsec. In libreswan, these policies are specified with *leftsubnet=*
and *rightsubnet=* and optionally also with *leftprotoport=* and
*rightprotport=*. Libreswan now, Kernel 4.19+ Libreswan 3.30+, allow you
to setup a route-based VPN. A route based VPN need both policy and
route. Libreswan will add the polices and basic routing in simple cases.
In more advanced cases you can add addition destination based routes or
routing policies. A ypical use case is policy covers everything 0/0 and
add specific routes to send traffic via the tunnels. This is basically a
policy-based VPN with leftsubnet=0.0.0.0/0 and rightsubnet=0.0.0.0/0.

The routes or routing policy (ip rule) go via XFRM device. Which is
created by librewan and attached to the IPsec policy. Now, whenever a
packet is routed into this XFRM device/interface, it will be encrypted.
Everything that goes via this device will either encrypted or dropped
based on associated IPsec policy. The encrypted EPS packet is routed
using main routing table. *While this type of setup is much less secure,
it is easier to manage because you just need to update the routing table
instead of adding or modifying IPsec policies*. While libreswan
supported route based VPN with KLIPS using the ipsec0 interface, as of
libreswan-3.30, adds support using the Linux XFRMi device.

{{ ambox \| nocat=true \| type=warning \| text = XFRMi support requires
libreswan-3.30_rc or later and a linux-4.19.x kernel or later.}}

An additional advantage of using libreswan with XFRM is that you have a
real network device (unlike the *nflogXX* interface) that supports
firewalling with *iptables*, running *tcpdump*, etc. It is really
functions as the old KLIPS ipsec0 interface.

## New ipsec.conf keywords for XFRM support

The following new keywords have been added to support XFRM:

     ipsec-interface=no|yes|<n> . <n> to create/use interface "ipsecN" default, when "yes" is 1. Allowed range 1-UINT32_MAX (4294967295U)

## Using XFRM interface

An example configuration is shown below. It is a regular VPN connection
with the additional options to turn it into a route-based VPN.

    conn routed-vpn
        left=192.1.2.23
        right=192.1.2.45
        authby=rsasigkey
        leftsubnet=0.0.0.0/0
        rightsubnet=0.0.0.0/0
        auto=start
        ipsec-interface=yes

This will create the ipsec1 interface. If you want to encrypt all
traffic to 10.0.0.0/8 using this VPN, simply run:

    ip route add 10.0.0.0/8 dev ipsec1

To see or monitor the traffic sent before encryption or received after
decrypion traffic, run:

    tcpdump -i ipsec1 -n

And you can add firewall rules if you want:

    # do not allow IRC traffic on port 6666
    iptables -I INPUT -j DROP -p tcp --dport 6666 -i ipsec1

To see the post-encrypt and pre-decrypt (assuming your external
interface is eth0), run:

    tcpdump -i eth0 -n esp or udp port 4500

To see more information about XFRM device:

    ip -d link show dev ipsec1
    ip -s link show dev ipsec1

## Setting up a route-based VPN with Amazon

\[ to be filled in \]

## XFRM related advanced use cases

### updown script

The standard updown script (_updown.netkey) tries to autodetect what
scenario is being deployed and will reconfigure the XFRM interface and
network options accordingly. As this feature is still new, we expect it
to not be perfect yet. If your scenario is not covered, please contact
the developers and explain your use case.

### Device options

Each device has a standard set of options associated with it. These can
be found in /proc/sys/net/ipv4/conf/ipsec/\*. The default updown script
sets some of these (rp_filter, forwarding, policy_disable) but specific
use cases might require different settings. Setting disable_xfrm will
cause the device to completely fail, so do not do that.

## XFRM device details

The xfrm device is internally attached to another network device such as
eth0. Note "ipsec1@eth0" in the following output.

    ip -d link show dev  ipsec1
    2: ipsec1@eth0: <NOARP,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
        link/none 06:c7:58:c4:b2:c6 brd ff:ff:ff:ff:ff:ff promiscuity 0 minmtu 68 maxmtu 1500
        xfrm if_id 0x1 addrgenmode eui64 numtxqueues 1 numrxqueues 1 gso_max_size 65536 gso_max_segs 65535

    #to see the policy details, with iproute5.1 or later
    root@road:/#
    ip xfrm state
    src 192.1.2.23 dst 192.1.3.209
        proto esp spi 0xa7c66a14 reqid 16393 mode tunnel
        replay-window 32 flag af-unspec
        output-mark 0x1
        aead rfc4106(gcm(aes)) 0xd371dde7df8be108215590f49a084d665417ad63aa1896d51c03173b85d5037d02384567 128
        encap type espinudp sport 4500 dport 4500 addr 0.0.0.0
        anti-replay context: seq 0x0, oseq 0x0, bitmap 0x00000000
        if_id 0x1
    src 192.1.3.209 dst 192.1.2.23
        proto esp spi 0x873318d8 reqid 16393 mode tunnel
        replay-window 32 flag af-unspec
        output-mark 0x1
        aead rfc4106(gcm(aes)) 0xbda3403de033c690a4c6c54651493bd8590042a56997ae127965e1e1f01de405843c4e55 128
        encap type espinudp sport 4500 dport 4500 addr 0.0.0.0
        anti-replay context: seq 0x0, oseq 0x0, bitmap 0x00000000

    ip xfrm policy
    src 192.0.2.1/32 dst 0.0.0.0/0
        dir out priority 1040383 ptype main
        tmpl src 192.1.3.209 dst 192.1.2.23
            proto esp reqid 16393 mode tunnel
        if_id 0x1
    src 0.0.0.0/0 dst 192.0.2.1/32
        dir fwd priority 1040383 ptype main
        tmpl src 192.1.2.23 dst 192.1.3.209
            proto esp reqid 16393 mode tunnel
        if_id 0x1
    src 0.0.0.0/0 dst 192.0.2.1/32
        dir in priority 1040383 ptype main
        tmpl src 192.1.2.23 dst 192.1.3.209
            proto esp reqid 16393 mode tunnel
        if_id 0x1

Note new fields: "if_id 0x1", "output-mark 0x1", "xfrm if_id 0x1". The
output mark is not configurable, it is the same as the XFRM interface
ID. Also note this mark not the same as the one used by VTI.

## routing table for a typical roadwarrior client setup

    ip rule show
    0:  from all lookup local
    100:    from all fwmark 0x1 lookup 50
    32766:  from all lookup main
    32767:  from all lookup default
    road #
     ip route show
    0.0.0.0/1 dev ipsec1 scope link src 192.0.2.1
    default via 192.1.3.254 dev eth0
    128.0.0.0/1 dev ipsec1 scope link src 192.0.2.1
    192.1.3.0/24 dev eth0 proto kernel scope link src 192.1.3.209
    road #
     ip route show table 50
    192.1.2.23 via 192.1.3.254 dev eth0

## Sharing ipsec-ineterface/XFRMi interface

these interfaces can be shared between different connection. The xfrm
policy will match based on source and destination pick the right policy.
So the simple case ipsec-interface=yes can share many connections. Also
more than one address can be added to the same interface.

## possible limittions of xfrmi??

### no IKEv1 support in libreswan

Currently 3.30 ipsec-interface need ikev2=yes. May be something for the
future to add.

### 0/0 route and ospf

During testing one issue was noticed by [github
issue](https://github.com/libreswan/libreswan/issues/278#issuecomment-568001203)

### ipsec-interface on /32-to-32 responder

seems to create routing issue. On the responder IKE_AUTH response is
sent through the tunnel and initiator never establish the connection.
The initiator has no tunnel yet. So it won't see the response.

## Configuration example

### OpenWRT Static tunnel

/etc/config/network

    config interface 'ipsec1'
            option proto 'xfrm'
            option mtu '1438'
            option zone 'VPN'
            option tunlink 'lan'
            option ifid '1'

    config interface 'ipsec1_static'
            option proto 'static'
            option ifname '@ipsec1'
            option auto '0'
            list ipaddr '192.0.1.45/24'

libreswan connection config

/etc/ipsec.conf

    conn staticvpn
         leftid=west
         rightid=east
         left=192.1.2.45
         right=192.1.2.23
         leftsubnet=192.0.1.0/24
         rightsubnet=192.0.2./24
         ipsec-interface=yes
         authby=secret