### What's in the name

Libreswan has its roots all the way back to [The FreeS/WAN
Project](http://www.freeswan.org/) which was started by [John
Gilmore](http://www.toad.com/gnu/) in the late nineties. When the
FreeS/WAN Project came to an end, it was continued by the people who
worked on it under the name Openswan. A legal dispute about the
trademark and ownership of the name lead to the creation of The
Libreswan Project. See [History](/FAQ/History).

### Design overview

There are two parts to setting up IPsec based VPN tunnels:

- Internet Key Exchange protocol

The IKE protocol is used by two end point systems to authenticate each
other and agree to setup an IPsec tunnel for a specific network range
using specific crypto parameters. Libreswan implements an IKE daemon
ins a program called [pluto](/Internals/Pluto).

- IPsec protocol

The IPsec protocol is the actual specification of this agreed policy
for the system (usually maintained by the operating system
kernel).
