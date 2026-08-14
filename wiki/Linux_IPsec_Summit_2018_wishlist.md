A scratchpad for things we'd like to talk about during the ipsec meetup

# Fixup XFRM and tcpdump

The fact that you see some plaintext, but not all plaintext, is the most
confusing aspect of IPsec to system administrators, who now believe hey
are leaking plaintext.

# INVALID_SPI acquires

When one endpoint crashes and restarts, and does not need to send
traffic, it will lead to traffic for because the other end's ESP/AH
packets are getting lost without triggering any ACQUIRE.

It would be nice of the kernel could send a rate limited INVALID_SPI
message, so the node can see if it has an ondemand/ready tunnel that it
should bring up.

# First query for IPsec Sa statistics returns bogus information

When we query for the IPsec SA statistics using XFRM_MSG_GETPOLICY it
seems the first call always returns 0's instead of actual data.

(not guaranteed to be a kernel bug)

# larval acquire saying "transport mode" - would be nice to not say mode at all

    src 192.0.2.100 dst 192.1.2.23
        proto esp spi 0xSPISPIXX reqid REQID mode transport
        replay-window 0
        sel src 192.0.2.100/32 dst 192.1.2.23/32 proto icmp type 8 code 0 dev eth0

# add support for Populate-From-Packet flag. Cause acquires for each different policy hit

Support rate limited acquires on a wider policy for individual policy
hits, so we can setup individual IPsec SA's for a part of a single SPD
policy entry.

# some clarification or documentation for IPsec SA flags

    FLAG := noecn | decap-dscp | nopmtudisc | wildrecv | icmp | af-unspec | align4 | esn
    EXTRA-FLAG-LIST := [ EXTRA-FLAG-LIST ] EXTRA-FLAG
    EXTRA-FLAG := dont-encap-dscp

    ip xfrm policy help shows:

    FLAG := localok | icmp

    XFRM-PROTO := esp | ah | comp | route2 | hao
    MODE := transport | tunnel | beet | ro | in_trigger
    LEVEL := required | use

# some clarification or documentation for /proc values

    /proc/sys/net/core/xfrm_acq_expires
    /proc/sys/net/core/xfrm_aevent_etime
    /proc/sys/net/core/xfrm_aevent_rseqth
    /proc/sys/net/core/xfrm_larval_drop

# fixup for userland using xfrm.h include

Our kernel_netlink.c code contains:

    #include "linux/xfrm.h" /* local (if configured) or system copy */
    #include "libreswan.h" /* before xfrm.h otherwise break on F22 */

Depending on how new gcc/glibc/userland and/or kernel is we need to swap
these two lines :(

Introduce some kind of \#ifdef _KERNEL_ that protects xfrm.h from
loading too much kernel related defines, so we only get the XFRM_
values we need to have available in userland. Now on older glibc we get:

    In file included from /source/programs/pluto/linux-copy/linux/xfrm.h:4:0,
                     from /source/programs/pluto/kernel_netlink.c:54:
    /usr/include/netinet/in.h:99:5: error: expected identifier before numeric constant
         IPPROTO_HOPOPTS = 0,   /* IPv6 Hop-by-Hop options.  */
         ^
    In file included from /source/linux/include/libreswan.h:76:0,
                     from /source/programs/pluto/kernel_netlink.c:55:
    /usr/include/netinet/in.h:209:8: error: redefinition of ‘struct in6_addr’
     struct in6_addr
            ^
    In file included from /source/programs/pluto/linux-copy/linux/xfrm.h:4:0,
                     from /source/programs/pluto/kernel_netlink.c:54:
    /usr/include/linux/in6.h:32:8: note: originally defined here
     struct in6_addr {
            ^
    [more errors left out]

Note that we have linux-copy/linux/xfrm.h because sometimes we need
newer XFRM values then the system provided version has, eg if people
upgrade kernel but not glibc.

# Comply with RFC 7296 NAT-T requirements

The kernel currently marks an IPsec SA as not natted or encaps-udp. It
rejects packets based on this. To comply to the RFC, it should:

       When either side is using port 4500, sending ESP with UDP encapsulation is
       not required, but understanding received UDP-encapsulated ESP packets
       is required.  UDP encapsulation MUST NOT be done on port 500.  If
       Network Address Translation Traversal (NAT-T) is supported (that is,
       if NAT_DETECTION_*_IP payloads were exchanged during IKE_SA_INIT),
       all devices MUST be able to receive and process both UDP-encapsulated
       ESP and non-UDP-encapsulated ESP packets at any time.  Either side
       can decide whether or not to use UDP encapsulation for ESP
       irrespective of the choice made by the other side.  However, if a NAT
       is detected, both devices MUST use UDP encapsulation for ESP.

This is also important for TCP support.

# crypto module loading problems

The problem of not autoloading crypto modules means we have to manually
load modules. We don't want the daemon to be able to load kernel
modules, so we have a helper script that loads everything that could
possibly be needed before the daemon starts. The problem is that
sometimes loading a crypto module is bad. Sometimes there is something
new we don't load.

A new recent issue is with containers, we cannot even run our helper to
load kernel modules anymore.

the kernel should really be able to auto load all crypto and IPsec
related modules on demand.

also, how to detect af_key is the old PF_KEY api is removed? we detect
af_key using /proc/net/pfkey as /proc/net/xfrm_stat is not available
everywhere

# VTI devices do not work for host-host tunnel/transport

For Opportunistc IPsec, we want all unauthenticated (anonymous) IPsec to
go into a single VTI device, so iptables rules that are installed the
machine's plaintext can be applied to the VTI device as well. Currently
(last tested early 4.x) only VTI policies with networks, not single
hosts, worked properly. ESP and IKE + NAT-T holes.

# RFC 8229 ESPinTCP support

AFAIK, Herbert Xu is working on this

# RFC 8229 ESPinTLS support

AFAIK, no one is working on this. Could it use ktls ?

# FIPS mode private key censoring

In FIPS mode, or actually maybe in normal mode too, it would be good if
the private keys are not visible in "ip xfrm state" unless there is some
debug flag passed/set into the kernel. The debug flag would not be
settable in FIPS mode.

Proposal: per default, show a CENSORED string instead of the actual
private key

# named sockets

getsockopt() and setsockopt() for named sockets. This way a client that
gets a DNS name, and resolves it to an IP, can set the socket name. This
can then be send along with the ACQUIRE so that the IKE daemon can use
that to possibly pull up some authentication mechanism based on this
FQDN (eg from DNS, confirm the CERT/ID payload matches this)

Also, this prevents an attack where someone who controls routing
(coffeeshop, hotel, etc) puts up an evil hostname to steal IP. Eg
evil.nohats.ca IN A 8.8.8.8 with an IPSECKEY XXXX. Then the client talks
to the rogue server and sends all encrypted 8.8.8.8 to the attacker that
can decrypt it.

The idea is, if you mark a connection to expect it to be
"dns.google.com", then if it comes with the mark "evil.nohats.ca" you
know there is a MITM.

# named IPsec policies

We would like to be able to "get" the name of an IPsec policy from
userland. Imagine this would be available via netlink or socket options.
This allows us to trigger an Opportunistic IPsec connection based on IP
address, then authenticate this via IKE, which gives us an identity (eg
FQDN) which we can then "add" to the SPD entry. Userland can then
confirm that a connect() or bind() it did based on a DNS name got a
policy matching the identity.

# a New 'Encryption Required' socket option

We'd like to be able to open a connection only if it is protected by
IPsec encryption. If the encryption is terminated, we want the kernel to
close the connection with some error.

currently, userland can ask the kernel about the encryption status, and
refuse to send data if there is no matching encryption, but obviously
this is comletely unsafe as the userland will not be notified if the
encryption status changes.

# Client Address Translation

For anonymous IPsec, where the client authenticates the server, but the
server does not authenticate the client, we have an IP clashing problem
of clients behind NAT. Either the server hands out addresses, in which
case a client connecting to multiple servers can get the same address
resulting in a conflict. Or the client can somehow use its internal
address, in which case the server has a clashing address problem with
multiple clients behind different NAT routers using the same pre-NAT IP.

We have a solution that currently installs an additional IPsec SA policy
using a special IP address. Then we tie that in with iptables rules.
This has the extra advantage that the system never needs to configure
the IP addresses given my the server side.

This works but it might clash with the administrator's firewall changes.
There is no reason this could not just be contained within the IPsec
subsystem, and this "CAT" IP address is passed to the kernel to install
the additional rule (and reverse rule so the iptables rule is not
needed)

We have a draft written for this which we will share soon)

# XFRM_MIGRATE support in ip xfrm monitor

Last I checked, ip xfrm monitor still threw errors when seeing
XFRM_MIGRATE messages

# Replace IPsec SA on successful traffic receiving

Currently, IKE daemon when doing a rekey need to ensure there is no
cleartext leaks. So the daemon flow looks like: (simplified, as
initiator/responder do install inbound/outbound at slightly different
times)

1\) Establish IKE SA 2) Add IPsec SA \#1 3) time passes 4) Negotiate new
IPsec SA \#2 via IKE SA 5) Insert IPsec SA \#2 6) wait until a packet
successfully decrypts on IPsec SA \#2 7) Delete IPsec SA \#1

It would be nice if the kernel could inform us of event 6, or even
better, that in 5) we could tell the kernel to associate this new IPsec
SA with the old one, and just sent us an confirmation netlink message
when it did 7)

# Routing and XFRM interaction

On machines with no default route and no route to a destination subnet,
a net-to-net IPsec SA will fail in the routing layer and will prevent
the XFRM code from ever capturing the packet for encryption.

This isn't intuitive to the user. We can work around it by detecting
this situation and manually adding a route (in our updown script) but
ideally the kernel would handle this properly itself.

# Implicit IV for Counter-based Ciphers for IoT support

See
[draft-ietf-ipsecme-implicit-iv](https://datatracker.ietf.org/doc/draft-ietf-ipsecme-implicit-iv/)

# Diet ESP for IoT support

See
[draft-mglt-ipsecme-diet-esp](https://tools.ietf.org/html/draft-mglt-ipsecme-diet-esp-05)