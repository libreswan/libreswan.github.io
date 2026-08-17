## Libreswan and TunnelCrack

The [TunnelCrack](https://tunnelcrack.mathyvanhoef.com/) vulnerability
is a tricky core problem to any VPN Remote Access protocol.

With a Remote Access VPN configuration, the server gives you an IP
address (eg 10.0.1.1) to use as your source IP, and a destination
network that usually compromises everything, eg 0.0.0.0/0. This creates
a VPN policy for all packets, eg 10.0.1.1/32 \<-\> 0.0.0.0/0. But of
course, you need to use the non-VPN network to send all your VPN packets
over. Some kernel/userland implementations depend on routing and some
have their own hooks outside of routing (eg Linux XFRM IPsec) to grab
packets, and as per IPsec policy, encrypt them and send them out. The
essential part is to get the source IP right. If your source IP is the
VPN given IP address, then it can only leave your device if it gets
encrypted properly. But when connecting to a possible hostile hotspot,
this can be tricky.

## Example hostile network

Let's say you connect to the StarBucks wifi, and the DHCP server on that
network gives you the IP address of 8.8.8.1, in a /24 (255.255.255.0)
network, and with 8.8.8.8 as the default gateway. It also gives you a
DNS server IP of 8.8.8.8. You connect and everything works fine. Note
that if you would use Google DNS on 8.8.8.8 as your DNS server, your
device would think that Google DNS lives in your local network. When you
browse the internet, the wifi router would NAT your packets to their
real public IP address and everything works. But if you want to hide all
your traffic from the local coffeeshop, you bring up a VPN. Let's say
you connect to vpn.nohats.ca. to setup a VPN connection. Your device
connects, gets an IP address to use on the VPN tunnel (eg 172.16.0.2)
and uses a remote destination range of everything (eg 0.0.0.0/0).

What happens now is that the IPsec policies are installed for
172.16.0.2/32 \<-\> 0.0.0.0/0

Any packet that has a source address of 172.16.0.2 will be encrypted and
the encrypted packet send via the wifi native IP of 8.8.8.1 (which gets
NATed by the wifi router to its public IP). Replies from the VPN server
follow the reverse path. But how does your device know to use 172.16.0.2
instead of the native wifi IP of 8.8.8.1 ? An application (eg a web
browser using HTTPS) will open a connection and the OS will pick a
source IP for it. Linux per default picks the "nearest IP" to the
destination IP. In this case, the nearest (furthest out) interface is
the wifi interface, so it would pick 8.8.8.1 as the source. Since this
is not the VPN address we were given, the packet would go out
unencrypted. So almost all VPN services use a trick called "half
routes", originally invented by [FreeS/WAN](https://freeswan.org), a
predecessor of libreswan. It installs two routes, which in Linux "ip
route" syntax would be:

`ip route add 0.0.0.0/1 src 172.16.0.2 dev wifi`
`ip route add 128.0.0.0/1 src 172.16.0.2 dev wifi`

These two routes cover the entire address space (0.0.0.0/0) and so cover
as much as the default route. but are "more specific" and so these will
be selected first by the Linux kernel. Now the application will open a
TCP connection, and it will use the 172.16.0.2 as source address, thus
match the IPsec policies and get encrypted. The routing table will also
have an entry for the wifi network. It will look something like:

`8.8.8.0/24 dev wlp0s20f3 proto kernel scope link src 8.8.8.1 metric 600 `
`default via 8.8.8.8 dev wlp0s20f3 proto dhcp src 8.8.8.1 metric 600 `

So once the encrypted packet is put in an IPsec packet with source IP
8.8.8.1, it will be send to 8.8.8.8 as the default gateway on the
network. It prefers this route because it is more specific (eg a /24)
than the half routes above (and the default route).

The problem that TunnelCrack uses, is that a rogue wifi hotspot can give
you any kind of IP network. In the example above, we squatted on Google
DNS which uses 8.8.8.8. So if your device uses Google DNS, you will open
a connection to 8.8.8.8, but since that is the local network, it has a
more specific route than the 'half routes' and so it will bypass the
IPsec policies and not get encrypted.

## Possible solutions

One solution is to block all local network traffic, with the exception
of some required to keep the local network connection up (eg only allow
DHCP, IKE, ESP and ipv6 neighbour discovery). Libreswan is looking at
adding a default on option for this when configured as a Remote Access
client. This block should happen at the IPsec policy layer so we don't
risk any interactions with the firewall systems installed and running
which might have conflicting rules (and with nftables, there can be more
than 1 firewal running and we don't want to have to understand all
firewalls people use). Note that one side effect would be that any local
network service such as a local printer, would get blocked.

Another solution could be to just add a single route to the VPN DNS
server IP we obtained, and force it as a more specific route with the
VPN address source IP. This would help avoid the LAN from stealing DNS
packetss by using a small more specific local IP range, such as stealing
Google DNS 8.8.8.0/24. Of course, if the malicious network makes 8.8.8.8
the default gateway, this would collapse the VPN and it would fail. But
failing on a malicious network is probably better than succeeding and
getting bypassed.

## Other VPN protocols

All non-IPsec VPN protocols have an additional problem. They do not have
IPsec policies that can block/accept packets for encryption that works
independent of the routing table. So in those scenarios, anything that
bypasses the route into the encryption device (eg wireguard's wg0
interface) would leak in the clear.