# VTI support is OBSOLETE, use the [IPsec Interface](/HOWTO/Route-based-VPN)

VPN tunnels are normally set up based on an IPsec policy. This is called
a policy-based VPN. In libreswan, these policies are specified with
*leftsubnet=* and *rightsubnet=* and optionally also with
*leftprotoport=* and *rightprotport=*. Libreswan allow you to setup a
route-based VPN. This is basically a policy-based VPN with
leftsubnet=0.0.0.0/0 and rightsubnet=0.0.0.0/0. Then a special Virtual
Tunnel Interface ("VTI") device is created that is attached to the IPsec
policy. Now, whenever a packet is routed into this VTI device, it will
be encrypted. If the packet's route misses the interface, the packet
leaves in the clear. While this type of setup is much less secure, it is
easier to manage because you just need to update the routing table
instead of adding or modifying IPsec policies. While libreswan supported
this with KLIPS using the ipsec0 interface, when using XFRM/NETKEY this
was not supported. As of libreswan-3.18, this is now supported using the
Linux VTI interface and network MARKing.

{{ ambox \| nocat=true \| type=warning \| text = VTI support requires
libreswan-3.18 or later and a recent linux-3.x or 4.x kernel. The
iproute package in Ubuntu 14.04 and 16.04 (and likely debian versions)
has been reported to be too old }}

An additional advantage of using libreswan with VTI is that you have a
real interface (unlike the *nflogXX* interface) that supports
firewalling with *iptables*, running *tcpdump*, etc. It even fixes
tcpdump on the non-VTI device, so it really functions as the old KLIPS
ipsec0 interface.

## New ipsec.conf keywords for VTI support

The following new keywords have been added to support VTI:

| option                     | description                                                                                                                                                                         |
|----------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **mark=**                  | The mark number to use for this connection's IPsec SA policy. It will be used for all instances as well.                                                                            |
| **markin=** / **markout=** | Same as the above but setting different marks for inbound and outbound.                                                                                                             |
| **vti-interface=**         | The interface name of the VTI device to use, eg vti01                                                                                                                               |
| **vti-routing=**           | Whether routes should automatically be created into the VTI device (default yes)                                                                                                    |
| **vti-shared=**            | Whether this vti device is shared with other connections (default no). if not shared, and not a template connection with %any, the VTI device will be deleted when tunnel goes down |
| **leftvti=address/mask**   | Configure the address/mask on the vti-interface when connection is established.                                                                                                     |

## Creating a virtual ethernet connection

An example configuration is shown below. It is a regular VPN connection
with the additional options to turn it into a route-based VPN.

    conn routed-vpn
        left=192.1.2.23
        right=192.1.2.45
        authby=rsasigkey
        leftsubnet=0.0.0.0/0
        rightsubnet=0.0.0.0/0
        auto=start
        # route-based VPN requires marking and an interface
        mark=5/0xffffffff
        vti-interface=vti01
        # do not setup routing because we don't want to send 0.0.0.0/0 over the tunnel
        vti-routing=no
        # If you run a subnet with BGP (quagga) daemons over IPsec, you can configure the VTI interface
        leftvti=10.0.1.1/24

This will create the vti01 interface. If you want to encrypt all traffic
to 10.0.0.0/8 using this VPN, simply run:

    ip route add 10.0.0.0/8 dev vti01

You can also use more complicated routing using "*ip rule*", shorewall
or anything else.

If you want to see the pre-encrypt and post-decrypt traffic, run:

    tcpdump -i vti01 -n

And you can add firewall rules if you want:

    # do not allow IRC traffic on port 6666
    iptables -I INPUT -j DROP -p tcp --dport 6666 -i vti01

To see the post-encrypt and pre-decrypt (assuming your external
interface is en0), run:

    tcpdump -i en0 -n esp or udp port 4500

You can see information about vti tunnels using:

    ip tunnel show
    ip -s tunnel show
    ifconfig vti01

{{ ambox \| nocat=true \| type=important \| text = You can give a VTI
interface any name you want as long as it is a valid network interface
name (eg less than 16 characters). You can also pick any MARK number
that you want. However, in the future, libreswan will likely use
mark=50/0xffffff and vti-interface=ipsec0 to create a global VTI device,
so it is best if administrators avoid these values }}

## Create a single VTI device for all VPN clients

If you run a VPN server, it is difficult to monitor all VPN connections
using tcpdump because it mixes up encrypted and unencrypted traffic, and
doesn't show all packets due to the way XFRM/NETKEY steals the packet
for encryption. However, if you use a VTI device, all pre-encrypt and
post-decrypt traffic appears on the VTI interface. All post-encrypt and
pre-decrypt traffic appears on the regular physical interface.

    conn roadwarriors
        # Regular certificate based VPN server
        left=1.2.3.4
        leftsubnet=0.0.0.0/0
        right=%any
        rightaddresspool=10.0.1.0/24
        authby=rsasig
        leftcert=mycert
        leftid=%fromcert
        auto=add
        rekey=no
        # Create route-based VPN using VTI
        mark=12/0xffffff
        vti-interface=vti02
        vti-routing=yes

Now you can monitor all connected VPN clients traffic by running:

    tcpdump -i vti02 -n

## Setting up a route-based VPN with Amazon

\[ to be filled in \]

## VTI related issues

This functionality is all very new, so not all issues or features have
been resolved yet. This is a list of known interesting things.

### updown script

The standard updown script (_updown.netkey) tries to autodetect what
scenario is being deployed and will reconfigure the VTI interface and
network options accordingly. As this feature is still new, we expect it
to not be perfect yet. If your scenario is not covered, please contact
the developers and explain your use case.

### interface options

Each interface has a standard set of options associated with it. These
can be found in /proc/sys/net/ipv4/conf/vtiXXX/\*. The default updown
script sets some of these (rp_filter, forwarding, policy_disable) but
specific use cases might require different settings. Setting
disable_xfrm will cause the interface to completely fail, so do not do
that.

### MTU

We noticed different kernels create different MTU sizes for new VTI
devices. Currently the MTU is not set by libreswan.

### combing different IPsec gateways into one VTI interface \[PARTIALLY SOLVED\]

You cannot **yet** have a vti tunnel that uses local 0.0.0.0 and remote
0.0.0.0. Kernel patches for these are pending. This means that you
cannot yet combine two different gateways on the same VTI device, that
have a different **local** IP address. However, you can combine
different connections that use the same **local** address but use a
different **remote** address by using the **vti-shared=yes** option.
Obviously, the marks and interface name must be the same for all shared
connections.

    conn west
         left=1.2.3.4
         right=6.7.8.9
         [...]
         mark=10/0xffffff
         vti-interface=vti01
         vti-routing=yes
         vti-shared=yes

    conn east
         left=10.11.12.13
         right=9.8.7.6
         [...]
         mark=10/0xffffff
         vti-interface=vti01
         vti-routing=yes
         vti-shared=yes