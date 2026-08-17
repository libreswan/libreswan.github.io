## Introduction

As of version 4.0, libreswan supports [RFC
8229](https://tools.ietf.org/html/rfc8229) that supports sending IKE
packets and encapsulating ESP packets over the TCP protocol. The IKEv1
protocol does not support TCP support. TCP support is only available
when IKEv2 is used.

The IPsec TCP kernel support was merged in Linux kernel 5.6. See [LWN:
RFC 8229 (TCP Encapsulation for IPsec) support
merged](https://lwn.net/Articles/811198/). Note that some important
bugfixes have since been merged in and the Libreswan Team has found and
reported some remaining issues.

You can watch the <https://netdevconf.info/0x13/index.html> NetDev
0x13\] presentation [IPsec encapsulation over
TCP](https://www.youtube.com/watch?v=F_pHapQg59s) by Red Hat kernel
developer Sabrina Dubroca if you are interested in the kernel
implementation details.

IPsec connections are negotiated using IKE. This protocol is based on
UDP and uses UDP port 500 and 4500. Once the IKE negotiation has
completed, IP packets are encrypted and transported using the ESP
protocol (protocol 50). Many routers and NAT gateways only support
sending UDP and TCP packets and would drop ESP packets. A method was
standardized in 2005 by [RFC 3947](https://tools.ietf.org/html/rfc3947)
and [RFC 3948](https://tools.ietf.org/html/rfc3948) that defines how
negotiate and encapsulate ESP packets to be transported within UDP. This
is often written as ESPinUDP. These UDP packets are send over UDP port
4500.

Unfortunately, a number of networks block all non-DNS UDP packets and
some networks specifically block IPsec VPNs by blocking UDP port 500 and
4500. With the introduction of [RFC
8229](https://tools.ietf.org/html/rfc8229) IKE and ESP can now be
encapsulated in TCP on any (preconfigured) port. Furthermore, the TCP
stream could further be encrypted as HTTPS traffic, so it becomes
indistinguishable from generic web traffic. Note that libreswan does not
currently support using HTTPS, only TCP directly. But this resolves the
vast majority of network blocking issues seen in the wild. We will use
IKEoverTCP and ESPinTCP to refer to the implementation of RFC 8223.

## When to use TCP for IKE and EPS

As [Section 12](https://tools.ietf.org/html/rfc8229#section-12) of RFC
8229 clearly states, TCP should be avoided when possible. The
performance is significantly reduced, especially when there is packet
loss on the TCP link. Furthermore, any on-path attacker can just send
spoofed garbage or an RST packet onto the TCP stream to break it. Do not
switch all your UDP based connections to TCP just because sometimes UDP
packets are dropped.

The RFC recommends to always try UDP first, and only later fallback to
TCP. And once on TCP, to keep trying to see if UDP starts working and if
it does to migrate back to UDP. Currently, libreswan only implements
using TCP as fallback or using only TCP. It does not implement checking
of it can switch back to UDP. There are also some interactions with
MOBIKE that might prevent connections that were established on TCP to
move back to UDP when a network change happens (eg switching from wifi
to mobile data or back).

## New configuration options

In the **config setup** section of the /etc/ipsec.conf there is a new
option **listen-tcp=yes\|no** (default: no) Note that the listen= option
was renamed to listen-udp=yes\|no, so it is possible to only offer TCP
and not UDP.

In the connection section, there are two new options:

- enable-tcp=yes\|no\|fallback (default: no)

<!-- -->

- tcp-remoteport= (default: 4500)

Note that the local TCP port is obtained like any other regular
application - it will ask the operating system for an ephemeral port to
use.

Note that leftikeport= and rightikeport= only affect UDP ports.

Note that currently, there is a bug which means libreswan can only
listen as a responder on TCP port 4500

## examples

For some example configurations, see our TCP testcases:

<https://github.com/libreswan/libreswan/tree/main/testing/pluto/ikev2-tcp-00-fallback>

<https://github.com/libreswan/libreswan/tree/main/testing/pluto/ikev2-tcp-00-yes>