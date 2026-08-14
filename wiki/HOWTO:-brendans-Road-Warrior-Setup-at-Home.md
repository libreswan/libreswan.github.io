_by Brendan Kearney_

i finally have a working config that i am content with.  i have been
trying to get a road warrior setup working in my home network and had
to work through the expected "growing pains" to achieve what success i
have.  i wanted to share some insights, configs and questions and ask
for feedback.  so, please enjoy my long winded diatribe. :D

first, i'll go into the network and server side of things.

on my firewall, which is iptables (i have not migrated to nftables
yet), i have a NAT rule (specifically, an inbound DNAT rule) and an
access rule.  with iptables, NAT acts on a packet before the access
policy, so you have to DNAT the packet and then allow access to the
NAT'd destination.  my NAT rule, in plain speak is:

```
Original Source = Any;
Original Destination = My Router/Firewall/Gateway External IP;
Original Service = IKE (UDP/500), IPSec-NAT-T (UDP/4500), ESP (proto 50);
Translated Source = Original/Unmodified;
Translated Destination = 192.168.152.254;
Translated Service = Original/Unmodified;
Inbound Interface = Auto/Any;
Outbound Interface = Auto/Any
```

i do not set an inbound interface intentionally, as this allows me to
establish an IPSec connection from behind my firewall, on my local
network, which is really helpful when setting things up and testing
through initial configs.  with NAT set, my access rule is, again in
plain speak:

```
Source = Any;
Destination = 192.168.152.254;
Service = IKE (UDP/500), IPSec-NAT-T (UDP/4500), ESP (proto 50);
Interface = Any;
Direction = Inbound;
Action = Accept;
Time = Any;
Log = Enabled
```

note again that in the access rule, any interface is allowed so that i
can be on my internal network and still establish an IPSec tunnel.
all i have to do is point at the external FQDN or IP and the NAT and
Access Rule will handle the rest.  also, the ports and protocols
include both IKE and IKE NAT Traversal, so that all bases are covered.

i run BGP on my home network, and the 192.168.152.0/24 network does
not exist on the wire.  my VPN server advertises/injects a route
pointing any traffic to that /24 via the servers "in-band" interface.
my router has this route listed:

```
192.168.152.0/24 nhid 141 via 192.168.88.5 dev vlan88 proto bgp src
192.168.248.254 metric 20
```

i may look to revise my routing scheme a bit, as i am running an eBGP
setup now, with my router in a separate AS than my servers. i am told
that an iBGP setup will make things easier, but for now this is
working.  I wont dive too deep into the routing pieces, but will share
if interest exists.  in the case of IPSec, the routing i have in place
would help me and my one user (myself) if i were to go multi-site and
wanted failover between sites. otherwise, this is all a learning
environment.

as you may have guessed, i do some crazy stuff with routing. LibreSWAN
does not listen on a physical interface.  in the days of yore, one
could stack virtual IPs on the loopback interface, but with
systemd-networkd which does not manage the loopback interface (lo), i
dont know if it has the same effect.  i have not tested, but using the
"Kind=dummy" type of interface closely resembles the setup and seems
to have the benefit i am looking for.  i do this because of the
improvement i saw with BIND/named when i switched to Anycast.  there
was a perceptible improvement in DNS response time.  the switch to
Anycast took my BIND/named listener off the physical interface and put
it on an IP that was stacked on the loopback.  in the old
network-scripts package days, i had an interface "lo:1" with the IP of
the Anycast address.  now i have an interface called "named" with the
"Kind" set to "dummy".  it seems to work the same way and still
performs with the same perceptible improvements.  now, with LibreSWAN
i have an interface "ipsec" set with "Kind=dummy" and the listener is
not on the wire.

i believe the improvement i see to be because there is less "context
switching" and "stops along the way" when getting from the wire to the
listener.  because i am (trying to) ride the loopback, there is a
higher MTU, faster path, fewer drivers, and a memory space in kernel
that the listener is listening on. seriously, things seem faster.  of
course i have not measured any of this, so feel free to refute my
claims.  that said, i do have a very well performing network with lots
of services trucking right along.  also, i have quite a few
sysctl.conf tweaks for my servers and assorted linux machines acting
as load balancers, firewalls, routers, gateways, etc.  if any interest
exists, i can share those tweaks.

anywho, with my routing (FRR) handling the path to the listener,
LibreSWAN listens on a "virtual" IP.  in /etc/ipsec.conf, i set the
listener to 192.168.152.254 (i route on the high side).  i also set
"ikev1-policy" to "drop".  the packaging for Fedora, which is my
distro of choice, sets "include" to "/etc/ipsec.d/*.conf" so i can add
my configs separately.

in /etc/ipsec.d/, i have my rac.conf and rac.secrets files, with "rac"
being short for Remote Access Connection.  i have tried to keep my
configs concise with comments separating different sections or
stanzas, to keep thing legible.  i dont know if blank lines are
acceptable between lines within a "conn" definition, so i have avoided
them.  otherwise, things are pretty straight forward.  my rac.conf
file:

```
# Remote Access Connection
conn rac
     # Local Definitions
     left=ipsec.bpk2.com
     leftsubnet=0.0.0.0/0
     # Remote Definitions
     right=%any
     rightaddresspool=192.168.152.50-192.168.152.99
     # Configuration Parameters
     auto=add
     authby=secret
     ikelifetime=24h
     salifetime=1h
     ikev2=insist
     rekey=yes
     fragmentation=yes
     mobike=yes
     # Dead Peer Detection
     dpddelay=30
     dpdaction=clear
     # Push Configs to Remote
     modecfgdns=192.168.248.254
     modecfgdomains=bpk2.com

conn x1titanium
     also=rac
     rightid=@x1titanium.bpk2.com

conn netbook
     also=rac
     rightid=@netbook.bpk2.com

conn s24ultra
     also=rac
     rightid=@s24ultra.bpk2.com
```

in the rac definition i set all my base configs that all subordinate
connections inherit.  then i set a specific conn for each device, so
that i can use separate pre-shared keys (PSKs) per device.  i dont
want to have a single PSK for all devices, in case of compromise.
each "per device" conn includes the base settings via the "also"
directive, and then specifies the "rightid" which is matched in the
rac.secrets file.

there is a nuance i came across is in dealing with the value of the
"left" directive.  as an aside, i adhere to the "left is local, right
is remote" mantra and my configs reflect this.  i believe this nuance
is due to the fact that i NAT the traffic, and the different names of
the external vs. internal IPs requires these config directives be
different.  on the server side, "left" is set to the FQDN of the
listener.  on the client side, "right" is set to the external name/IP
on my ISP connection, and "rightid" is set to the internal IP of the
listener.  the "rightid" is set to the IP and not the FQDN because DNS
resolution of the internal name will not work until the tunnel is up,
so i have to use the IP.  i might be able to use a string with "@"
preceding the value to avoid a DNS lookup or other matching mechanism,
but that is an option left to the reader.

also to note, with the "leftsubnet=0.0.0.0/0" directive, i backhaul
all traffic.  i do not "split-tunnel".  specifying something like
192.168.0.0/16 would setup split tunneling, so that anything not in
that range would not be routed via the VPN tunnel.  the use of
"narrowing=yes" may also be needed or useful when doing split
tunneling.  i have not dug into split tunneling or narrowing, so i can
only claim ignorance on the topics.

in the rac.secrets file, i have a line for each of the device specific
"conn" definitions.  again blank lines may be a no-no, so i avoid them
here as well.  the formula for the entries in the secrets file is
pretty simple and described in the man file.  my rac.secrets file:

```
# generate PSKs using 'openssl rand -hex 32' or 'openssl rand -hex 64'
ipsec.bpk2.com @x1titanium.bpk2.com : PSK "SomeSecret12345"
ipsec.bpk2.com @netbook.bpk2.com : PSK "SomeSecret67890"
ipsec.bpk2.com @s24ultra.bpk2.com : PSK "SomeOtherSecret123"
```

the first value is the FQDN, matching the server's "left" setting.
the second value is a string, as designated by the "@" preceding it,
and matches the "rightid" of the device specific "conn".  then a
colon. then the PSK designator and string, with the actual PSK string
encapsulated in double-quotes.  i leave a comment at the beginning of
the secrets file to help me remember how to create high quality PSKs.
i have even taken creating PSKs to another level with a simple
script...

```
#!/bin/bash

if [ -z $1 ]
then
     echo "You must supply an identifier, typically a FQDN..."
     exit
fi

server="ipsec.bpk2.com"
fqdn=$1
bits=32
PSK=$(openssl rand -hex $bits)
outFile="rac.secrets"

echo "$server @${fqdn} : PSK \"${PSK}\"" >> $outFile
```

name the script what you want.  adjust the variables to your
environment.  call it with one parameter, which is the string you
match on in the device specific "conn" definition and bob's your
uncle.  hit your running instance with a "ispec auto --rereadall" and
everything should be running on the servers side.

one final note on the server side of things.  i dont know if i need to
set this or not, but i do anyway and it does not break things.  i am
not sure if the applicability of this setting is due to the IPSec
listener being on a machine separate from my router/gateway or not,
but having set it does not seem to affect the functionality.  in
/etc/sysctl.conf i have the following configured:

```
# Enable proxy arp?
net.ipv4.conf.all.proxy_arp = 1
net.ipv4.conf.default.proxy_arp = 1
net.ipv4.conf.enp1s0.proxy_arp = 1
```

i am handing out internal, LAN side IPs and this is supposed to
facilitate that.  because i set the "all" setting, i dont think i need
to specify any other interfaces.  the in-band interface is
specifically set, but my virtual is not.  in my quest to find what
setting i needed to specify, i found this and set it.  i was hoping
this would allow me to have my DHCP instance give out IPs to the IPSec
clients, but i dont think DHCP is a supported capability.  questions
about DHCP capability later...

now, on to the client side of things.

the client config is pretty straight forward, and i dont have crazy
routing going on there.  there are a couple important details to pay
attention to, and i will explain those in detail. the client side
rac.conf file:

```
# Remote Access Connection
conn rac
     # Local Definitions
     left=%defaultroute
     leftid=@x1titanium.bpk2.com
     leftsubnet=0.0.0.0/0
     leftmodecfgclient=yes
     # Remote Definitions
     right=my.dyndns.name
     rightid=192.168.152.254
     rightsubnet=0.0.0.0/0
     # Configuration Parameters
     auto=add
     authby=secret
     ikev2=insist
     ikelifetime=24h
     salifetime=1h
     rekey=yes
     fragmentation=yes
     pfs=yes
     mobike=yes
     # Dead Peer Detection
     dpddelay=30
     dpdaction=clear
     retransmit-timeout=120
```

adhering to the "left = local, right = remote" mantra, "left" is set
to the special setting of "%defaultroute" which auto populates a
couple of unspecified parameters.  it makes things easy.  'nuff said.
the "leftid" is specified to match the secrets file PSK on both sides
of the tunnel.  "leftsubnet" is set to everything, to backhaul all
traffic and not perform split-tunneling.

the "right" directive is set to the external dynamic DNS name for my
ISP connection.  the "rightid" is set to the internal IP of the
LibreSWAN listener.  the "right" and "rightid" settings are critical
because i am running a NAT Traversal scenario, and the box running
with a routable IP (i.e. not an RFC 1918 IP) is not the same box as
the one running the VPN listener.  "rightid" has to be set to the IP
and not the internally resolvable FQDN, as DNS resolution of that name
cannot be performed until the tunnel is up.  therefore, it is set to
the IP.  "rightsubnet" is also set to everything, for backhauling of
all traffic.

i have chosen the other config parameters based on the "best
practices" i have found across the internet, trying to provide a
secure and robust tunnel that affords the best available security and
reliability.  granted, certificates would be an improvement above
PSKs, but i dont have PKI infrastructure to mint certs and automate
their renewal and deployment.  otherwise, no IKE v1, relatively short
IKE and SA lifetimes, PFS enabled (which does not always work when
setting up connections between differing VPN vendors), and MobIKE
because road warriors might change interfaces and IPs based on
connection and availability.  adjust seasonings to taste...

as for the secrets file, there is one entry and it follows the same
format as the server side, but the first two values are reversed.  the
client side rac.secrets file:

```
@x1titanium.bpk2.com ipsec.bpk2.com : PSK "SomeSecret12345"
```

note that the second value is the FQDN of the NAT'd, internal (RFC
1918) IP for the LibreSWAN listener.  i expected this to have to be an
IP, but it works as a FQDN, so i leave it as is.  that could vary from
implementation to implementation, or OS to OS, so be wary and test.
YMMV.
