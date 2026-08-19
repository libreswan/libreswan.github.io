# libreswan/pluto design choices

## pluto keywords

    ipsec-interface=no|yes|<n> (n = user configured device, systemd-networkd, OpenWRT..)
    leftinterface-ip=<ip>/<mask> get configured on xfrmi or loopback /* to be implemented */

    possibly need split of mark to in and out in the future, which means 3 key words for mask.

    iface-mark-in=n/mask
    iface-mark-out=n/mask

## pluto discarded keywords

vti-routing is discarded. Pluto would add route as longs the leftsubnet
!= rightsubnet. If they are same such as 0.0.0.0/0 to 0.0.0.0/0 no route
will be added.

- allow names ipsec1 ... ipsecx.

<!-- -->

- Should we allow names other than ipsecX ?

<!-- -->

- initial thought is keep "xfrm interface id" and "xfrm output mark"
  consistent.

<!-- -->

- interface creation is inside pluto.

<!-- -->

- create bugzilla entry for 4.18 support.

<!-- -->

- XFRMi code is compile time option. If the kernel headers do no't
  support it won't compile. Think RHEL 6 or Debian Weezy.

# Kernel XFRM - related

## XFRM INTERFACE

##### [Commit cover letter from Steffen 20180612](https://patchwork.ozlabs.org/cover/928175/), Merged in 4.19:


    https://patchwork.ozlabs.org/cover/928175/

    Steffen Klassert June 12, 2018, 7:56 a.m.

    This patchset introduces new virtual xfrm interfaces.
    The design of virtual xfrm interfaces interfaces was
    discussed at the Linux IPsec workshop 2018. This patchset
    implements these interfaces as the IPsec userspace and
    kernel developers agreed. The purpose of these interfaces
    is to overcome the design limitations that the existing
    VTI devices have.

    The main limitations that we see with the current VTI are the
    following:

    - VTI interfaces are L3 tunnels with configurable endpoints.
      For xfrm, the tunnel endpoint are already determined by the SA.
      So the VTI tunnel endpoints must be either the same as on the
      SA or wildcards. In case VTI tunnel endpoints are same as on
      the SA, we get a one to one correlation between the SA and
      the tunnel. So each SA needs its own tunnel interface.

      On the other hand, we can have only one VTI tunnel with
      wildcard src/dst tunnel endpoints in the system because the
      lookup is based on the tunnel endpoints. The existing tunnel
      lookup won't work with multiple tunnels with wildcard
      tunnel endpoints. Some usecases require more than on
      VTI tunnel of this type, for example if somebody has multiple
      namespaces and every namespace requires such a VTI.

    - VTI needs separate interfaces for IPv4 and IPv6 tunnels.
      So when routing to a VTI, we have to know to which address
      family this traffic class is going to be encapsulated.
      This is a lmitation because it makes routing more complex
      and it is not always possible to know what happens behind the
      VTI, e.g. when the VTI is move to some namespace.

    - VTI works just with tunnel mode SAs. We need generic interfaces
      that ensures transfomation, regardless of the xfrm mode and
      the encapsulated address family.

    - VTI is configured with a combination GRE keys and xfrm marks.
      With this we have to deal with some extra cases in the generic
      tunnel lookup because the GRE keys on the VTI are actually
      not GRE keys, the GRE keys were just reused for something else.
      All extensions to the VTI interfaces would require to add
      even more complexity to the generic tunnel lookup.

    To overcome this, we started with the following design goal:

    - It should be possible to tunnel IPv4 and IPv6 through the same
      interface.

    - No limitation on xfrm mode (tunnel, transport and beet).

    - Should be a generic virtual interface that ensures IPsec
      transformation, no need to know what happens behind the
      interface.

    - Interfaces should be configured with a new key that must match a
      new policy/SA lookup key.

    - The lookup logic should stay in the xfrm codebase, no need to
      change or extend generic routing and tunnel lookups.

    - Should be possible to use IPsec hardware offloads of the underlying
      interface.

### Initial xfrmi kernel commits

<https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=f203b76d78092faf248db3f851840fbecf80b40e>

<https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=7e6526404adedf079279aa7aa11722deaca8fe2e>

- Steffen Klassert's at Linux IPsec 2018, Dresden
  <https://workshop.linux-ipsec.org/2018/slides/xfrm_interfaces.pdf>

### XFRM OUTPUT_MARK

[Add mask and rename to XFRMA_SET_MARK,
Steffen](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=9b42c1f179a614e11893ae4619f0304a38f481ae)

[Initial Commit,
Lorenzo](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=077fbac405bfc6d41419ad6c1725804ad4e9887c)

#### 4.18 cherry pick the following commits to get xfrmi

<https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=f203b76d78092faf248db3f851840fbecf80b40e>

<https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=7e6526404adedf079279aa7aa11722deaca8fe2e>

<https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=9b42c1f179a614e11893ae4619f0304a38f481ae>

<https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=660899ddf06ae8bb5bbbd0a19418b739375430c5>

<https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=211d6f2dc883fe2235532d7ec4ed7e8222957ae0>

<https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=c6f5e017df9dfa9f6cbe70da008e7d716d726f1b>

<https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=44e2b838c24d883dae8496dc7b6ddac7956ba53c>

<https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=5baf4f9c0035f3e33bb693a1a1e87599f6e804e6>

<https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=bc56b33404599edc412b91933d74b36873e8ea25>

## Which mark? there as so many now!

There are wo marks relevant to IPsec , xfrm in Linux kernel.
[XFRMA_MARK](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=6f26b61e177e57a41795355f6222cf817f1212dc)
and
[XFRMA_SET_MARK](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=9b42c1f179a614e11893ae4619f0304a38f481ae)([aka
XFRMA_OUTPUT_MARK](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=077fbac405bfc6d41419ad6c1725804ad4e9887c)).
Now on I use XFRM_OUTPUT_MARK mark which as of 4.20 mean
[XFRM_SET_MARK/XFRM_SET_MARK_MASK](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=9b42c1f179a614e11893ae4619f0304a38f481ae)

A quick summary of difference between the two marks. XFRM_OUTPUT_MARK is
for routing a packet after XFRM(think as ESP out or Clear text in) a
look up key for routing rule, while
[XFRMA_MARK](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=6f26b61e177e57a41795355f6222cf817f1212dc)
is for routing a clear text packet into xfrm sub system; XFRMA_MARK is a
lookup key in SPDB and SADB.

XFRMA_MARK (along with mask) is used inside xfrm code to find policy and
state on for an outgoing, clear text, packet [Jamal's
notes](https://lwn.net/Articles/375829/) (clear text packet out only.
Then I wonder why set XFRMA_MARK on incoming SA? See [libreswan
commit](https://github.com/libreswan/libreswan/commit/a37ed0da3b32a89147a50fe8467a536178c2c85d).
What is the use case of it. Is it supposed to copy mark from incoming
ESP to the incoming clear text? I don't thing so yet! I think that is
done by the new XFRMA_OUTPUT_MARK on the in SA.

To be clear, both marks could be used for routing a packet at its
different stages, while it goes through Linux stack. or in a more
complicated case where a packet get marked when arrive at the host
application replies. Now the magic is the incoming packet's mark is used
for two things to decide source address of the respons, the mark get
copied to related outgoing clear text packet. Then it is used to route
in multi homed situation. While XFRM_OUTPUT_MARK is used for routing ESP
packet on the output side and clear text packet on the input side. You
see a bit more details on XFRMA_MARK see [Jamal's
explanation](https://lwn.net/Articles/375829/)

XFRMA_MARK - mark(u32)/mask(u32). XFRM_OUTPUT_MARK -
mark(u32)/\[mask(u32). So one difference is for XFRM_OUTPUT_MARK mask is
optional as of 4.19, 4.18 did not support mask for OUTPUT_MARK.

IPsec and routing has to share same mark. That why there is mask. One
part for IPsec/XFRM and other part for the rest of the system use. XFRM
stack should pass on the mark set by the system when correct mask is
used. Masked part is opaque to xfrm.

### use case of marks

- Simple use case XFRMI interface.

XFRM_OUTPUT_MARK by libreswan when the the other/peer end is inside the
extruded tunnel. In other words. Say /32-to-/32 tunnel without NAT or
0.0.0.0/0 tunnel. Note it is adding rules to rout

#### XFRMi and RW

XFRMi need "ip rule" when the peer's ip is covered by ipsec policy and
for /32-to-/32 IPsec policies. Antony's initial attempt was the
following rule and route 50 table. Because of "table 50" we don't need
0/1 and 128/1 split rules when the the other end is 0/0.

    ip rule add from 192.1.3.209 to 192.1.2.23/32 fwmark 0x1/0xffffff lookup main
    ip rule add from 192.0.2.1 to 0.0.0.0/0 lookup 50
    ip route add default dev ipsec1 src 192.0.2.1 table 50

===== New xfrmi rule attempt ====

    # with not rule

    0:      from all lookup local
    100:    not from all fwmark 0x1 lookup 50
    32766:  from all lookup main
    32767:  from all lookup default

    # ip route list table main
    default via 192.1.3.254 dev eth0
    192.1.3.0/24 dev eth0 proto kernel scope link src 192.1.3.209

    # ip route list table 50
    default dev ipsec1 scope link src 192.0.2.1

    # With yes rule
    ip route
    0.0.0.0/1 dev ipsec1 scope link src 192.0.2.1
    default via 192.1.3.254 dev eth0 proto static
    128.0.0.0/1 dev ipsec1 scope link src 192.0.2.1
    192.1.3.0/24 dev eth0 proto kernel scope link src 192.1.3.209

    ip rule
    0:      from all lookup local
    100:    from all fwmark 0x1 lookup 50
    32766:  from all lookup main
    32767:  from all lookup default

    ip route show table 50
    #esp traffic
    192.1.2.23 via 192.1.3.254 dev eth0

#### XFRMi and RW Tuomo's suggestion

20190212 Tuomo thinks the above rule is negation rule with "not" which
is not friendly. We should have two rules and a route entry. A further
refined form of this is below.

    ip rule add prio 99 fwmark 6/0xffffffff lookup main
    ip rule add prio 100 to 192.1.2.23/32 lookup 50
    ip route add 192.1.2.23/32  table 50

201810 proff of concept rule

    ip rule add prio 100 to 192.1.2.23/32 not fwmark 1/0xffffffff lookup 50
    ip route add 0.0.0.0/0 dev ipsec1 src 192.0.2.1 table 50
    ip route add default dev ipsec1 src 192.0.2.1 table 50

- XFRMI interface and multihoming. Yet to test this. It would bet
  interesting to test. If it all work the idea is mark on incoming ESP,
  set by iptable rule, would get copied first to incoming clear packet,
  then to outgoing clear text packet and finally to the outgoing ESP
  packet. With XFRMi at every stage there are could routlookup involving
  fwmark with mark. I wonder if it works. Any one tested it?

<!-- -->

- Simple case IPsec with IP_VTI, only libreswan using marks on the
  ssytem.

Then you can pick any mark you want. in libreswan config you set
mark=2/0xffffffff. The rest is transparent to users, magic happens.

- more complicated case VTI and multihoming

Lets say you have two upstreams. Both route packets to your host. Then
you would start to use iptable to mark the incoming traffic, ESP. First
the ESP will get decrypted and new clear text packet will retain the
mark. The mark will be used to get source address for response packet.
Then it will go through xfrm. Get encrypted again retainng the mark.
Then get routed to via the interface the the packet came in.

Now with VTI. A portion of mark clear text outgoing response is over
written (using mask). If you are familiar with the commands bellow you
get an idea what is going on. I herd it works. I wonder if the incoming
ESP packet's mark, say set by iptable before hitting XFRM input code,
would end up on the outgoing ESP too or just on the clear text response.

    iptables -t mangle -N MARK-ISP1
    iptables -t mangle -A MARK-ISP1 -j MARK --set-mark 1
    iptables -t mangle -A MARK-ISP1 -j CONNMARK --save-mark

    iptables -t mangle -N MARK-ISP2
    iptables -t mangle -A MARK-ISP2 -j MARK --set-mark 2
    iptables -t mangle -A MARK-ISP2 -j CONNMARK --save-mark

    ip rule add fwmark 1 table ISP1
    ip rule add fwmark 2 table ISP2
    ip route add table ISP1 192.0.3.0/24 dev eth1 src 192.0.2.0/24
    ip route add table ISP2 192.0.3.0/24 dev eth2 src 192.0.22.0/24

# Track bugs and related issue

- Fedora support in F29 [F29
  commit](https://src.fedoraproject.org/rpms/kernel/c/84dd8fe88279144ddb82168d1cc44117073ff07e)
  enabled it. However not in F28
- RHEL bugzilla request??
- [CentOS 8 kernel-4.18.0-147.el8 supports
  XFRMi](https://git.centos.org/rpms/kernel/c/74e6aea855eecc7e3f053ac9837c2b396df80cc7?branch=c8)
- [Deebian
  Buster](https://salsa.debian.org/kernel-team/linux/commit/9954895622f9a487416e30ed95e29789b5cbc729)
  4.19.20-1
- [OpenWRT](https://git.openwrt.org/?p=openwrt/openwrt.git;a=commitdiff;h=452d88e8f798c550151cd1e1d204a528fb00db08)
  pull request
- [](https://github.com/systemd/systemd/pull/13013) xfrmi auto bind to
  lo, loopback\]

# Strongswan support

- <https://wiki.strongswan.org/issues/2845>

# Errors

## if you delete the namespace before deleting xfrm interface, xfrm interface will not go away

    Message from syslogd@swantest at Aug 28 18:38:15 ...
     kernel:unregister_netdevice: waiting for eth1 to become free. Usage count = 1

## routed vpn

- same destination, difference source routes to two different gateways.

<!-- -->

    conn north-east
            rightid=@west
        leftid=@north
        right=192.1.2.23
        left=192.1.3.33
            rightsubnet=192.0.1.0/24
        leftsubnet=192.0.33.0/24
        overlapip=yes

    conn north-west
            rightid=@west
        leftid=@north
        right=192.1.2.45
        left=192.1.3.33
            rightsubnet=192.0.1.0/24 #same subnet
        leftsubnet=192.0.3.0/24  #different
        overlapip=yes

# more configuration options

- Currently the new routing table is id "50" is hardcoded

<!-- -->

- same route to two different gateways. this will need an option to
  configure "ip rule priority"

` ipsec-interface-`

# xfrm interface with hardware offload

systemd-networkd man page specify, for the hardware offload, network
interface must match NIC used.