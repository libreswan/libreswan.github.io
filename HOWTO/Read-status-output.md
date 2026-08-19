The libreswan status output is very verbose and confusing. Work is being
done to make this a lot more userfriendly.

There are currently two status commands that can be used. Note all
status commands prefix their output using "FTP status codes" in the form
of three digits (eg 000 or 2xx or 5xx)

# ipsec trafficstatus

The "ipsec whack --trafficstatus" command shows the tunnels that are
**currently established**. An example output:

    006 #48971: "redhat", username=pwouters, type=ESP, add_time=1480687195, inBytes=12295525, outBytes=673668
    006 #50578: "supo.libreswan.org", type=ESP, add_time=1480701786, inBytes=0, outBytes=0, id='@melto.foobar.fi'
    006 #50206: "vault.libreswan.org", type=ESP, add_time=1480698400, inBytes=1008, outBytes=1008, id='@foo-gw.foobar.fi'

This output shows that there are currently three connections
established. The first connection is named "redhat". It has a username
(XAUTH or IKEv2 CP) associated with it of "pwouters". It shows when the
connection became active (add_time is the number of seconds since Unix
Epoch) and a traffic count for incoming and outgoing traffic. The other
two tunnels show simiar information, except that since these connections
specified a remote ID to connect to, these IDs are also listed.

This short output does not reveal any details of the connection. It does
not show if IKEv1 or IKEv2 was used.

# ipsec status

The "ipsec status" command shows a more verbose but not very
userfriendly output. This command is extremely verbose and was
originally a developer-only tool for debugging. It is not really
designed for administrators. Work is underway to replace this output
with something more human readable.

The output consists of a few sections seperated by blanc lines:

- Network interfaces used
- Global configuration (from ipsec.conf's "config setup"
- Supported kernel algorithms for ESP/AH
- Supported userland algorithms for IKE
- Connection list (loaded connections - not neccessarilly active)
- State Information (including count of IKE and IPsec states)
- A list of all active IKE and IPsec states
- Bare shunts (packet-triggered policies for which no loaded connection
  matched)

We are interested in the connection list and the state list. Connection
parameters are those parameters loaded from the configuration. State
parameters are those parameters that are being or were negotiated for
this particular negotiation of that connection.

## Connection listing example

The following example output is the "redhat" connection as taken from
the connection list section:

    000 "redhat": 10.3.228.119/32===192.168.10.124[@OURREMOTEID,+MC+XC+S=C]---192.168.10.1...209.XXX.XXX.XXX<XXX.XXX.redhat.com>[MS+XS+S=C]===0.0.0.0/0; erouted; eroute owner: #2
    000 "redhat":     oriented; my_ip=10.3.228.119; their_ip=unset
    000 "redhat":   xauth us:client, xauth them:server,  my_username=pwouters; their_username=[any]
    000 "redhat":   our auth:secret, their auth:secret
    000 "redhat":   modecfg info: us:client, them:server, modecfg policy:push, dns1:unset, dns2:unset, domain:redhat.com, cat:unset;
    000 "redhat": banner:Unauthorized Access to this or any other Red Hat Inc. device is strictly prohibited. Violators will be prosecuted. ;
    000 "redhat":   labeled_ipsec:no;
    000 "redhat":   policy_label:unset;
    000 "redhat": 10.3.228.119/32===192.168.10.124[@,+MC+XC+S=C]---192.168.10.1...209.XXX.XXX.XXX[MS+XS+S=C]===10.0.0.0/8; erouted; eroute owner: #2
    000 "redhat":     oriented; my_ip=10.3.228.119; their_ip=unset
    000 "redhat":   xauth us:client, xauth them:server,  my_username=pwouters; their_username=[any]
    000 "redhat":   our auth:secret, their auth:secret
    000 "redhat":   modecfg info: us:client, them:server, modecfg policy:push, dns1:unset, dns2:unset, domain:redhat.com, cat:unset;
    000 "redhat": banner:Unauthorized Access to this or any other Red Hat Inc. device is strictly prohibited. Violators will be prosecuted. ;
    000 "redhat":   labeled_ipsec:no;
    000 "redhat":   policy_label:unset;
    000 "redhat":   ike_life: 86400s; ipsec_life: 86400s; replay_window: 32; rekey_margin: 540s; rekey_fuzz: 100%; keyingtries: 0;
    000 "redhat":   retransmit-interval: 500ms; retransmit-timeout: 60s;
    000 "redhat":   sha2-truncbug:yes; initial-contact:yes; cisco-unity:no; fake-strongswan:no; send-vendorid:yes; send-no-esp-tfc:no;
    000 "redhat":   policy: PSK+ENCRYPT+TUNNEL+PFS+DONT_REKEY+UP+XAUTH+AGGRESSIVE+IKEV1_ALLOW+IKEV2_ALLOW+IKE_FRAG_ALLOW+NO_IKEPAD+ESN_NO;
    000 "redhat":   conn_prio: 32,32; interface: wlp4s0; metric: 0; mtu: unset; sa_prio:666; sa_tfc:none;
    000 "redhat":   nflog-group: unset; mark: 6/0xffffffff, 6/0xffffffff; vti-iface:ipsec0; vti-routing:yes; vti-shared:no;
    000 "redhat":   dpd: action:hold; delay:30; timeout:60; nat-t: force_encaps:no; nat_keepalive:yes; ikev1_natt:both
    000 "redhat":   newest ISAKMP SA: #3; newest IPsec SA: #2;
    000 "redhat":   IKE algorithms wanted: AES_CBC(7)_128-SHA1(2)-MODP1024(2)
    000 "redhat":   IKE algorithms found:  AES_CBC(7)_128-SHA1(2)-MODP1024(2)
    000 "redhat":   IKE algorithm newest: AES_CBC_128-SHA1-MODP1024
    000 "redhat":   ESP algorithms wanted: AES(12)_000-SHA1(2); pfsgroup=MODP1024(2)
    000 "redhat":   ESP algorithms loaded: AES(12)_000-SHA1(2)
    000 "redhat":   ESP algorithm newest: AES_256-HMAC_SHA1; pfsgroup=MODP1024

The most interesting bit is the first line that describes the IP ranges
of both ends of the tunnel. The bulk of the output displays the various
connection options that are set or unset. The last bit shows the
interpretation of the algorithms specified in the connection's ike= and
esp= line.

Note this part of the output does not state anything about whether this
tunnel is up or down or being negotiatied. That information is visible
in the State List:

## State Listing

Fully working VPN connections consist of an IKE SA (phase1) and an IPsec
SA (phase2). The IKE SA refers to the userland state and describes the
endpoints IKE negotiation state. The IPsec SA refers to the kernel state
that is actually responsible for encrypting and decrypting the IP
packets.

An IKEv1 connection example looks like:

    000 Total IPsec connections: loaded 6, active 1
    000
    000 State Information: DDoS cookies not required, Accepting new IKE connections
    000 IKE SAs: total(1), half-open(0), open(0), authenticated(1), anonymous(0)
    000 IPsec SAs: total(1), authenticated(1), anonymous(0)
    000
    000 #2: "redhat":4500 STATE_QUICK_I2 (sent QI2, IPsec SA established); EVENT_SA_REPLACE_IF_USED in 28039s; newest IPSEC; eroute owner; isakmp#1; idle; import:admin initiate
    000 #2: "redhat" esp.9c01f20f@209.132.183.55 esp.e12dd706@192.168.10.124 tun.0@209.132.183.55 tun.0@192.168.10.124 ref=0 refhim=0 Traffic: ESPin=0B ESPout=0B! ESPmax=4194303B username=pwouters
    000 #1: "redhat":4500 STATE_MAIN_I4 (ISAKMP SA established); EVENT_SA_EXPIRE in 86390s; newest ISAKMP; lastdpd=-1s(seq in:0 out:0); idle; import:admin initiate
    000

In this case there is one connection named "redhat". It has an
established IKE SA (also called phase1 or Parent SA) numbered \#1 and it
has one IPsec SA (also called phase2 or Child SA) numbered \#2. Every
IPsec SA will list its IKE SA state number as "isakmp#XXX".

If the state claims "established", it means that it is fully up and
running.

{{ ambox \| nocat=true \| type=important \| text = In IKEv1, the phase1
states are either MAIN MODE or AGGRESSIVE MODE states and the phase2
states are QUICK_MODE states }}

In IKEv2, the IKE states are called PARENT SA and the IPsec states are
called CHILD SA.

A Parent SA (phase1) state that is still negotiating has no Child SA
(phase2) state. For example:

    000 #51231: "private-or-clear#193.110.157.0/24"[1] ...193.110.157.102:500 STATE_PARENT_I1 (sent v2I1, expected v2R1); EVENT_v2_RETRANSMIT in 8s; idle; import:local rekey

In this case, we initiated an IKEv2 connection named "private-or-clear"
to the remote IP 193.110.157.102, but the remote endpoint never
responded to us. It shows the connection will retry in 8 seconds.

An established IKEv2 connection looks as follows:

000 \#50578: "supo.libreswan.org":500 STATE_PARENT_R2 (received v2I2,
PARENT SA established); EVENT_SA_REPLACE in 22484s; newest IPSEC; eroute
owner; isakmp#50577; idle; import:respond to stranger 000 \#50578:
"supo.libreswan.org" esp.9a8c024f@188.127.201.217
esp.8758b394@76.10.157.69 tun.0@188.127.201.217 tun.0@76.10.157.69 ref=0
refhim=0 Traffic: ESPin=0B ESPout=0B! ESPmax=0B 000 \#50577:
"supo.libreswan.org":500 STATE_PARENT_R2 (received v2I2, PARENT SA
established); EVENT_SA_REPLACE in 22484s; newest ISAKMP; isakmp#0; idle;
import:respond to stranger 000 \#50577: "supo.libreswan.org" ref=0
refhim=0 Traffic:

Here, state number 50577 is the IKE SA, and state 50578 is the IPsec SA.

{{ ambox \| nocat=true \| type=important \| text = The Child SA (#50578)
in IKEv2 mistakenly calls itself a a PARENT SA. This is a known (but
harmless) bug }}

# ip xfrm

It is also possible to ask the kernel about the IPsec state inside the
kernel. The kernel IPsec state consists of two parts. The Security
Policy Database (SPD) and the Security Association Database (SAD). In
Linux kernel terms these are called "xfrm policy" and "xfrm state". They
are linked together by the *reqid*.

IPsec SA's always come in a bundle. There is an inbound (in) and
outbound (out) IPsec SA. They have their own policy that are usually
just a mirror image of each other, although each direction as its own
encryption and/or authentication keys. There is also a forward (fwd)
policy which is an artifact of the implementation and can mostly be
ignored.

    # ip xfrm pol
    src 10.3.228.211/32 dst 10.0.0.0/8
        dir out priority 666 ptype main
        mark 0x6/0xffffffff
        tmpl src 76.10.157.68 dst 209.132.183.55
            proto esp reqid 16417 mode tunnel
    src 0.0.0.0/0 dst 10.3.228.211/32
        dir fwd priority 666 ptype main
        mark 0x6/0xffffffff
        tmpl src 209.132.183.55 dst 76.10.157.68
            proto esp reqid 16417 mode tunnel
    src 0.0.0.0/0 dst 10.3.228.211/32
        dir in priority 666 ptype main
        mark 0x6/0xffffffff
        tmpl src 209.132.183.55 dst 76.10.157.68
            proto esp reqid 16417 mode tunnel
    src 0.0.0.0/0 dst 0.0.0.0/0
        socket out priority 0 ptype main
    src 0.0.0.0/0 dst 0.0.0.0/0
        socket in priority 0 ptype main
    src 0.0.0.0/0 dst 0.0.0.0/0
        socket out priority 0 ptype main
    src 0.0.0.0/0 dst 0.0.0.0/0

    [...]

The output can look slightly different depending on the kernel version.
As libreswan pokes holes for the IKE port (UDP 500) there will be a
number of similar looking states to and from 0.0.0.0/0, even if no IPsec
connection has been established. The source/destination addresses of the
policy determine which packets are send to a kernel state for
encryption/decryption. It will match either the libreswan connection's
left= and right= IP addresses (for a host-to-host connection) or it will
match the libreswan connection leftsubnet= and rightsubnet= values if
set. The reqid's from this policy is linked to the states that have the
crypto keys:

A more verbose version including traffic counters can be obtained using
*ip -s xfrm pol*

The corresponding xfrm state can be shown using *ip xfrm state* :

{{ ambox \| nocat=true \| type=speedy \| text = This command actually
shows the encryption/decryption and authentication private keys. Anyone
who sees this output can decrypt all the traffic encrypted with these
keys! }}

    # ip xfrm state
    src 209.132.183.55 dst 76.10.157.68
        proto esp spi 0x6e45ab4b reqid 16417 mode tunnel
        replay-window 32 flag af-unspec
        auth-trunc hmac(sha1) 0x5292bb9d25099ecec68c54457ccd06099b4930ac 96
        enc cbc(aes) 0xd7a05a7fd43ca2110b90e151ec55883c4623f86905178cb9eed5d42e328d31bf
        anti-replay context: seq 0x0, oseq 0x0, bitmap 0x00000000
    src 76.10.157.68 dst 209.132.183.55
        proto esp spi 0x360d5bb6 reqid 16417 mode tunnel
        replay-window 32 flag af-unspec
        auth-trunc hmac(sha1) 0x059d0c7ee4a0a1cbbba3efc33aa779abaf8fa0ed 96
        enc cbc(aes) 0x66085742da59ccb01e6c7702675ca6fc7876ede803883ad519ecc805327d97d0
        anti-replay context: seq 0x0, oseq 0x0, bitmap 0x00000000

Here the IP addresses are the IP's of the gateways themselves and not
the leftsubnet= or rightsunet= values.

This command also supports the more verbose version using *ip -s xfrm
state*