The old OE method is not used because of a lack of access to the
reverse.

Trying to write this as a problem statements

1\) Mesh connecting. 1000's of servers in a cloud. They need to talk to
each other.

2\) client-server like solution as TLS, where client authenticates
server, but server does not authenticate the client. Does OE using IPsec
add enough value compared to TLS, or is this problem now basically
solved with TLS added to every protocol (and UDP with TLS, DTLS). TLS
does not hide what kind of communication you use (eg bittorrent, SIP)

What is new these days is that we believe everyone needs to run a local
validator resolver for DNSSEC. That gives us an option to hook into
there. When an application does an A record lookup, before the DNS
server returns that, lookup IPSECKEY, and if there, establish an IPsec
tunnel. Then release the A record to the application. This works for
resources accessed via DNS, but not resources accessed via IP. But we
believe that with IPv6, it will become more and more common to use FQDN.

A second method could be to use TLS and get a FQDN based on IP address
from the cert.

There are two different methods we can support for establishing IPsec
connections 1) initiator only like. This is the TLS model, where the
there is a client-server model. The client does not have to get
authenticated by the server. Only the client needs to authenticate the
server. 2) As Hugh Daniel rightfully would say, there are no
client-servers, only equal peers. They must both authenticate each
other. While 2) is better, 1) can be done without requiring a client
configuration.

Also think about "dnssec chains" to get keys, perhaps using IKE itself?

Regardless, it seems everyone agrees that the reverse will never be
used, and pluto should not do the work for finding if it can or cannot
do IPsec to an endpoint. It should be a model into the DNS server (eg
unbound) or into the ActiveDriectory server (eg sssd module)

Remove it, but not first thing now. Let's think and see where it is
going.