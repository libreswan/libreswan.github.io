
# Common error messages

## 030 ignoring message from whack with bad magic

This means that the ipsec whack command that is used to talk to the
pluto daemon are different versions. The most common cause is that the
system has two installs of libreswan. One system install that appears
in /usr/libexec/ipsec and one local install in
/usr/local/libexec/ipsec.  The system started the non-local version,
but the user running the ipsec command prefers /usr/local/sbin/ipsec
over /usr/sbin/ipsec and thus uses the whack from /usr/local/. You
should remove one of the two installs.

Another reason this can happen is that a package upgrade did not
properly restart the daemon and the old daemon is running but the user
only has the new whack command. Manually killing the pluto daemon and
restarting the ipsec service will resolve that. Note that the
"shutdown" command is not version-specific, so regular package
upgrades (eg via rpm) can install the new whack, then call shutdown
with the new whack to the old pluto, without this error appearing.

## ERROR: netlink response for Add SA esp.XXXX@<IP> included errno 38: Function not implemented

This means the kernel does not support something of the negotiated
IPsec SA. This happens for instance on sime Raspberry Pi Linux images
that do not compile in support for AES-GCM. A workaround could be to
pick another esp= algorithm such as esp=aes-sha2

## compile error: ‘SEC_OID_CURVE25519’ undeclared here

The NSS library is too old and does not support CURVE25519. Either
upgrade the NSS library or compile with USE_DH31=false to disable
CURVE25519 at build time. This currently happens with Debian9 and
Debian8

== ERROR: asynchronous network error report on eth0 (sport=4500) for
message to xx.xx.xxx.xxx port 4500, complainant yy.yy.yyy.yyy: Message
too long \[errno 90, origin ICMP type 3 code 4 (not authenticated)\]
==

These errors are often intermittent, it depends on your application
data that is getting encrypted. Your NAT'ed IPsec tunnel is using
ESPinUDP, and the additional UDP header caused some of your packets to
be too big.  See the previous answer and try lowing your mtu. Use an
insanely small mtu like 1300 or 1200 for confirmation. Then try to
bring it up higher to what seems to work reliably for you.

== ERROR: asynchronous network error report on eth0 (sport=4500) for
message to xx.xx.xxx.xxx port 4500, complainant yy.yy.yyy.yyy: No
route to host \[errno 113, origin ICMP type 3 code 1(not
authenticated)\] ==

These errors often happen 15 minutes after the tunnel successfully
established. It's most likely that the tunnel was idle and the NAT
router removed the nat mapping. Or the NAT router rebooted and lost
state. It no longer knows which client to send the packet to. Ensure
your connection uses nat-keepalive=yes. Possibly decrease the global
keep-alive= value to send more frequent keep-alive packets.
Alternatively, enable DPD on the connection to cause some regular
traffic on idle tunnels.

== ERROR: asynchronous network error report on eth0 (sport=500) for
message to xx.xx.xxx.xxx port 500, complainant yy.yy.yyy.yyy:
Connection refused \[errno 111, origin ICMP type 3 code 3 (not
authenticated)\] ==

This error means the other end is not (or no longer) running an IKE
daemon. Ensure the IKE daemon is running on the remote system. If you
see this error *during* a negotiation, it could be that the remote IKE
daemon crashed or stopped listening. On Mac OSX if the IKE daemon is
not allowed to read the proper X.509 certificate, it will only realize
this partially into the IKE negotiation and terminate, resulting in
this error. It is also possible that the remote IP is actually a NAT
device with the IPsec device behind it. In that case, using rekey=no
and letting the other end initiate might make this error go away.

== error: ignoring informational payload, type NO_PROPOSAL_CHOSEN
msgid=00000000 ==

This error means exactly what i says. The IKE proposal(s) sent to the
server were rejected. This means there is a configuration mismatch
between libreswan and the remote IPsec server. Usually this is a
configuration mismatch in the ike= or esp= (phase2alg=) setting. But
other options could also be wrong, such as authby= or pfs= or
aggrmode=

## Microsoft Windows fails to connect, log shows: retransmit response for message ID: 1 exchange ISAKMP_v2_AUTH

You are on a network that is dropping UDP fragments, and your client
has no support for IKEv2 fragmentation. This is common on LTE networks
when using Windows clients that are not up to date. Microsoft added
IKEv2 Fragmentation support in Windows 10 April 2018 Update (v1803) so
updating Windows might resolve this issue.

## Microsoft Windows Error 13806: IKE failed to find valid machine certificate

You are using a certificate that is missing some required
ExtendedKeyUsage ("EKU") attributes. See [Windows Certificate
requirements](/Interoperability#Windows_Certificate_requirements)

## ssh gives error: Corrupted MAC on input. Disconnecting: Packet corrupt

This usually indicates MTU issues. You can try lowering the mtu using
the mtu= option or by changing the actual mtu on the proper interface
on the libreswan server. This error is known to happen on Amazon EC2
AMI types that use PV (xen) instances. Switching to Amazon HVM
instances seems to resolve the problem on AWS.

## Using aes_gcm or aes_ctr results in ERROR: netlink response for Add SA esp.XXXXXXXX@IPADDRESS included errno 22: Invalid argument

This usually indicates that the ESP algorithm selected using the
phasealg= (esp=) line is not available in the kernel. These usually
indicate kernel bugs.

Linux kernels up to 3.2.x have a bug in the aesni-intel driver on
x86_64. See
[rhbz#1176211](https://bugzilla.redhat.com/show_bug.cgi?id=1176211)
The AESNI hardware acceleration kernel module does not properly
support 256 or 192 bit keys for AES_GCM. You can either switch to 128
bit keys or blacklist or unload the aesni-intel kernel module. Another
alternative is to switch from phase2alg=aes_gcm to phase2alg=aes,
although that will cut the performance in half.

Linux kernels to date seem to have a bug in the aes_ctr code on the
POWER8BE VM - use phase2alg=aes there as well to use AES_CBC,

## Can't find the private key from the NSS CERT (err -8177)

The old libreswan-3.8 /etc/ipsec.d/nsspassword requires just the
password to be entered. In later libreswan's, you must add the NSS
prefix to it. So to specify the password "secret", use:

    NSS Certificate DB:secret

## ESP DH algorithm MODP3072 is invalid as PFS policy is disabled

libreswan before version 3.25 allowed invalid configurations with pfs=no
while specifying a PFS group for esp (eg esp="aes-sha2;modp3072") and it
would ignore the PFS group. This is no longer allowed. Either use
pfs=yes (the recommended and default) or remove the modp item from any
ah= / esp= / phaesalg= option.

## "IPsec encryption transform did not specify required KEY_LENGTH"

This happens when trying to interoperate with old openswan versions that
mistakenly do not send the KEY_LENGTH attribute for AES. The work around
the problem, on those old implementations, specify "aes128" or "aes256"
instead of "aes". For example:

    phase2alg=aes256-sha1;modp1536
    esp=aes256-sha1;modp1536
    ike=aes256-sha1;modp1536

## No PARENT proposal selected

This error can happen when there is a mismatch of IKE proposals between
the server and client. In libreswan-3.14, the modp1024 (group 2) was
removed from the default proposal set because of its weakness, but
apparently Windows 7 requires it per default.

## Using VTI causes "Keys are not allowed with ipip and sit tunnels"

You need to upgrade the iproute package. For RHEL7, see
[RHBA-2015-2117](https://rhn.redhat.com/errata/RHBA-2015-2117.html)

# Old problems fixed in newer releases

## invalid last pad octet:

There is a bug in racoon (also called ipsec-tools) that sends improper
oversized padding. Libreswan version 3.14 became more struct and
rejected these packets. Libreswan 3.16 allows the bad padding again.
Note that racoon is used in various products including older versions of
OSX and iOS (up to iOS 7.x)

## Module unloading error on shutdown or restart: Module esp4 is in use

    ERROR: Module xfrm4_mode_tunnel is in use
    ERROR: Module esp4 is in use
    FAILURE to unload NETKEY esp4/esp6 module

This has been fixed in libreswan-3.9. Please upgrade

## IPv6 tunnel works manually but fails on freshly booted machine

When one machine reboots and loses state, the other machine still has an
encryption policy for the rebooted machine and will insist on receiving
only encrypted packets. Obviously, after a reboot the host cannot send
encrypted packets. For that reason, an "IKE hole" is present in the
host's kernel. This means that any UDP 500 and UDP 4500 packets for IKE
are allowed in plaintext even if we have an encryption policy active for
that host. On at least the Linux kernel that hole does not include
ipv6-icmp Neighbour Discovery packets, which is a unicast reply from the
host that did not reboot to the just rebooted host. You can see this in
"ipsec status" as:

    000 Shunt list:
    000 000 2620:52:0:ab0:42f2:e9ff:fe09:a16c/128:136 -58-> 2620:52:0:ab0:ca1f:66ff:fef1:c74c/128:0 => %hold 0 %acquire-netlink

Note protocol 58 (ipv6-icmp)

A workaround is to add the following connection:

    conn v6neighbor-hole
            left=::1
            leftsubnet=::0/0
            leftprotoport=58/0
            rightprotoport=58/34816
            rightsubnet=::0/0
            right=::0
            connaddrfamily=ipv6
            authby=never
            type=passthrough
            auto=route
            priority=1

If you wonder where the number "34816" comes from please see the
leftprotoport= entry of the
[ipsec.conf](https://libreswan.org/man/ipsec.conf.5.html) man page.

libreswan-3.13 to 3.22 installs this connection per default in
/etc/ipsec.d/ libreswan as of 3.23 loads this as a buildin connection
automatically.

## Using IPsec/L2TP with xl2tpd, the pppd ip-down script does not seem to run

Old pppd \< 2.4.5 could cause xl2tpd to hang on a hanging pppd, so
xl2tpd killed pppd itself to avoid this. But that meant pppd did not get
to execute its ip-down script. This behaviour can be tweaked using the
define TRUST_PPPD_TO_DIE in the xl2tpd Makefile. Fedora and EPEL
packages enable this as of April 2015.

## Interop issue with racoon: invalid padding-length octet: 0x23

Racoon has a broken implementation of IKE padding. Libreswan version
3.12 to 3.14 had strict padding checks that caused these packets to be
rejected. These restrictions have been loosened to accomadate the broken
racoon in libreswan 3.15 and higher

== on xen pluto crashes with: Illegal instruction when using ike=aes_gcm
==

This is due to the interaction of NSS and Xen (which is possibly lying
about the real AES hardware capability of the system. A workaround for
this is to disable AES_GCM encryption in NSS using:

    export NSS_DISABLE_HW_GCM=1

This should probably be placed somewhere more global than just
libreswan, as it will affect everything that is using the nss libraries.

## IPv6/KLIPS: ipsec_set_dst can't determine the correct routing device on a host connection

This is a kernel bug, see
[lsw#237](https://bugs.libreswan.org/show_bug.cgi?id=237) Confirmed
affected are kernel 4.1.6 and 3.14.51 but possible all 3.x and
4.\[12\].x kernels to date (Sep 28, 2015)

## L2TP / Transport Mode connections fail after system update

There is a kernel bug in Linux kernel 4.14 with the XFRM/NETKEY code.
Downgrade to 4.13 or upgrade to 4.15rc1 or later. Be aware that some
kernels could contain backports of the faulty 4.14 kernel.

## High Speed IPsec performance issues

Kernels used a really small crypto queue by default (100), which was
also hard coded. Recent kernels (4.x and RHEL7 kernels) can now be
configured to increase this queue length:

    echo 'options cryptd cryptd_max_cpu_qlen=1000' > /etc/modprobe.d/cryptd.conf
    reboot

To check your current queue length:

    # modprobe cryptd
    # dmesg | grep cryptd
    [ 4865.043558] cryptd: max_cpu_qlen set to 1000
