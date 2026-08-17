# General Questions

( we will sort this in categories once we have more )

## Which RFC's or other standards does libreswan support?

See [Implemented Standards](./FAQ:-Implemented-Standards)

## Which ciphers / algorithms does libreswan support?

### IKEv1

- IKE: AES_CBC, 3DES and SHA2_256, SHA2_384, SHA2_512, SHA1, MD5 with
  all regular MODP and ECP groups (serpent, twofish, 1des no longer
  supported)

- ESP on Linux: AES_GCM, AES_CCM, AES_CTR, AES_CBC, CAMELLIA, 3DES, NULL
  and SHA2_256, SHA2_256_96(truncbug) SHA2_384, SHA2_512, AES-XCBC-MAC,
  SHA1, MD5 (serpent, twofish, 1des and cast no longer supported)

- AH on Linux: SHA2_256, SHA2_256_96(truncbug) SHA2_384, SHA2_512,
  AES-XCBC-MAC, SHA1, MD5

### IKEv2

- IKE: CHACHA20-POLY1305, AES_GCM, AES_CTR, AES_CBC, 3DES, CAMELLIA_CBC
  and SHA2_256, SHA2_384, SHA2_512, AES-XCBC-MAC, SHA1, MD5 with all
  regular MODP groups, NIST ECP groups and Curve25519, and ESN

- ESP on Linux: CHACHA20-POLY1305, AES_GCM, AES_CCM, AES_CTR, AES_CBC,
  CAMELLIA, 3DES, NULL and SHA2_256, SHA2_256_96(truncbug) SHA2_384,
  SHA2_512, AES-XCBC-MAC, SHA1, MD5

- AH on Linux: SHA2_256, SHA2_256_96(truncbug) SHA2_384, SHA2_512,
  AES-XCBC-MAC, SHA1, MD5

### Notes

- Serpent, Twofish, 1DES and CAST are no longer supported.

- Some algorithms are disabled when running in FIPS mode.

- DH2 (MODP1024) is too weak to be supported and is disabled at
  compile time. It can be re-enabled via USE_DH2=true but it is
  strongly recommended to not do so. Any device from the last 20 years
  should support DH5 or DH14, with the exception of Android when using
  L2TP. In those cases, please use Android with IKEv2.

## Which IKEv1 and IKEv2 Exchange Modes does libreswan support?

The [IANA
Registry](https://www.iana.org/assignments/ipsec-registry/ipsec-registry.xhtml#ipsec-registry-8)
lists all official Exchange Modes. There are a few IKEv1 Modes that
are very common despite never gotten past the draft stage.

### IKEv2:

- [IKEv2 (PSK, raw RSA, X509)](https://tools.ietf.org/html/rfc5996#section-1.2)

- [IKEv2 CP mode](https://tools.ietf.org/html/rfc5996#section-3.15)

- [IKEv2 CREATE_CHILD_SA](https://tools.ietf.org/html/rfc5996#section-1.3)

- [IKEv2 Informational Exchange](https://tools.ietf.org/html/rfc5996#section-1.4)

- IKEv2 IKE_SESSION_RESUME

### IKEv1

- [IKEv1 Main Mode (PSK, raw RSA, X509)](https://tools.ietf.org/html/rfc2409#section-5)

- [IKEv1 Aggressive Mode (PSK, raw RSA, X509)](https://tools.ietf.org/html/rfc2409#section-5)

- [IKEv1 XAUTH/RSA and XAUTH/PSK with ModeConfig (aka "Cisco IPsec
  mode")](https://tools.ietf.org/html/draft-ietf-ipsec-isakmp-xauth-06)

### Not supported

- [IKEv1 Revised Mode](https://tools.ietf.org/html/rfc2409#section-5.3)

- [IKEv1 Hybrid Mode (aka "Mutual Group
  Authentication")](https://tools.ietf.org/html/draft-ietf-ipsec-isakmp-hybrid-auth-05)
  although there is some [unmaintained contributed
  code](https://github.com/libreswan/libreswan/tree/master/contrib/checkpoint-hybrid)

## Does libreswan interoperate with Microsoft Windows?

In general, yes it does. For specific features, see [Microsoft Product
Behaviour](https://msdn.microsoft.com/en-us/library/cc233476.aspx)

Note IKEv2 Fragmentation is only supported as of Windows 10 April 2018
build. If you see issues when using LTE/4g/5g, try updating to the
latest win10.

Another known issue is reconnecting not working, see this [techinline
blog](https://blog.techinline.com/2018/06/01/vpn-stuck-on-connecting-windows-10/)

## Microsoft and L2TP (xl2tpd)

It seems newer xl2tpd versions only interop with Microsoft when using
the l2tp_ppp kernel module loaded. Some distributions blacklist the
l2tp_netlink and/or l2tp_ppp module from auto-loading. Check the
blacklisting of modules for your distribution. To see if your modules
can properly load, use:

    modprobe l2tp_netlink
    modprobe l2tp_ppp
    lsmod | grep l2tp

You should see the l2tp modules in the output of the last command.

## Can I have an ipsec0 interface with XFFRM/NETKEY?

Yes, this is supported as of libreswan-3.18. With libreswan 3.x you
can set ipsec-interface=1 to get ipsec1.  As of libreswan-4.x you can
also set it to 0 to get ipsec0. See further [Route-based
VPN](./HOWTO:-Route-based-VPN)

## Does libreswan work with OpenVZ virtualization?

Yes it can work. You must run kernel 042stab084.8 or later. You must
load the proper kernel modules on the host before booting the
container.  The easiest way to do this is to install libreswan on the
host and then run "ipsec _stackmanager start". You also need to give
the container the "net_admin" capability.

## How can I debug the kernel?

For XFRM, see /proc/net/xfrm_stat and its documentations at
[xfrm_proc.txt](https://www.kernel.org/doc/Documentation/networking/xfrm_proc.txt)

note that some debian/ubuntu kernels do not compile in support for
CONFIG_XFRM_STATS and those kernels have no way of debugging anything :(

## Are there well known vulnerabilities?

See [Vulnerabilities](./Security:-Vulnerabilities).

## Google Cloud VPN issue

Google Cloud VPN does not support NAT. The libreswan endpoint has to
have a real public IP that is not NAT'ed

# Configuration Matters

## Using SHA2_256 for ESP connection establishes but no traffic passes (especially Android 6.0)

It seems that android 6.0 now defaults to ESP with SHA2, but it uses a
bad implementation of SHA2. You can work around that using
sha2-truncbug=yes but that would break all non-android clients that use
the proper RFC SHA2 implementation. It might be possible to avoid SHA2
completely and use esp=aes_gcm-null instead (which is also faster)

See the sha2-truncbug man page entry of ipsec.conf for more information.
There is also an [android bug
194269](https://code.google.com/p/android/issues/detail?id=194269) about
this issue.

Note Linux kernels before 2.6.33 all used the broken truncation, so to
interop with those old kernels, the sha2-truncbug=yes option would need
to be set.

libreswan-3.18 and higher prefers sha2_512 over sha2_256 to avoid this
issue. A note has also been added to RFC7321bis.

## Microsoft Windows connection attempts fail with NO_PROPOSAL_CHOSEN

Windows ships with insecure default IKEv2 proposals.  See [How to
configure DH for IKEv2 in
Windows](https://docs.microsoft.com/en-us/windows/security/identity-protection/vpn/how-to-configure-diffie-hellman-protocol-over-ikev2-vpn-connections?branch=master)
for how to enable secure alternatives using PowerShell.

Alternatively, you could use `regedit` and add add the entry:

    HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\Rasman\Parameters\NegotiateDH2048_AES256

with the DWORD value `1` (enable AES_CBC_256 and MODP_2048) or `2`
(enforce AES_CBC_256 and MODP_2048).

Finally, if you're sure that the system running Libreswan hasn't
removed support for DH2/MODP_1024 from NSS, you could try rebuilding
Libreswan with `USE_DH2=true`.  With DH2 enabled, the following
proposals will try to negotiate more secure algorithms, but fallback
back to modp1024:

    ike=aes_gcm256-sha2,aes_gcm128-sha2,aes256-sha2,aes128-sha2,aes256-sha1,aes128-sha1,aes256-sha2;modp1024
    esp=aes_gcm256-null,aes_gcm128-null,aes256-sha2_512,aes128-sha2_512,aes256-sha1,aes128-sha1,aes_gcm256-null;modp1024

## iOS (Apple) phone devices trying and failing to rekey in 8 minutes

This is a bug in Apple devices. These devices do not use `pfs=yes`
when configured via the phone manually (as opposed to via a
.mobileconfig provisioning profile). Either use `pfs=no` or `enable
ms-dh-downgrade=yes` option.

## How do I specify AEAD ciphers like GCM for IKE and IPsec

For IKE, a PRF must be configured. For IPsec, a PRF must not be
configured.

    # the IKE SA is configured for AES_GCM using a PRF of SHA2
    ike=aes_gcm-sha2_256
    # the -null can be left out when using version 3.23 or higher
    # phase2alg= and esp= are aliases for the same configuration option.
    phase2alg=aes_sha256-null

The format of the ike= and phase2alg= (esp=) lines are:
encr_algo-integ_algo. So for a classic non-AEAD AES CBC with SHA2_256
algorithm set, this would be: *ike=aes-sha2_256* and
*phase2alg=aes-sha2_256*. When using an AEAD algorithm such as AES
GCM, there is no separate encryption and integrity algorithm. The
combined algorithm however is negotiated and specified as if it is an
encryption algorithm and with no (separate) integrity
algorithm. However, IKE re-uses the integrity algorithm as the PRF to
generate key material for the encryption/integrity functions of both
IKE encryption and IPsec encryption. This PRF is negotiated along with
the encryption and integrity algorithms. Since from a security
standpoint, it makes no sense to trust an algorithm for integrity but
not trust it for PRF, libreswan re-uses the integrity keyword to
negotiate the PRF. It does not allow negotiating a different algorithm
for integrity and PRF. When using an AEAD such as aes_gcm, that means
we now need to specify a PRF, since the AEAD cannot be used as the
PRF. So now the IKE configuration line becomes ike=aes_gcm-sha2_256
where the latter argument denotes the PRF and not the integrity
algorithm. Since the IKE PRF also generates the key material for the
IPsec SA, when also using an AEAD for the IPsec encryption/integrity,
the phase2alg= (esp=) line does not need to specify an integrity
algorithm nor a PRF algorithm. Up to libreswan 3.23, the parser would
require to specify encryption-integrity, so the way to configure the
AEAD was by adding a null for integrity. So that would be
phase2alg=aes_gcm-null. As of libreswan 3.23, the trailing -null can
be left out, so it can be specified as phae2alg=aes_gcm. Note that the
esp= keyword is an alias for the phase2alg= keyword.

## My ssh sessions hang or connectivity is very slow

This could be an MTU issue. The overhead of IPsec encryption (and
possibly ESPinUDP encapsulation) yields a slightly smaller packet
size.  This can cause problems. A good way to confirm MTU problems is
if you can login remotely over the IPsec tunnel using ssh, but issuing
"ls -l /usr" causes the session to hang. Try adjusting the MTU with:

    iptables -I FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS  --clamp-mss-to-pmtu

If that does not help, try hardcoding it yourself:

    iptables -I FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --set-mss 1380

If these settings don't help, adding mtu=1420 to the connection might
work, although it will affect all traffic that the connection covers.

As a last case alternative, you can try lowering the MTU on the
internal interface of your IPsec server so that the PMTU discovery
locally already goes back to 1440, eg using *ip link set dev eth1 mtu
1440*.  This will not only affect packets for the VPN tunnel, but all
packets received and sent on that inerface. Only use this as a last
resort.

== using auto=ondemand slows down TCP establishments when using XFRM ==

(also known as rhbz#1010347 )

This should be fixed on recent kernels (3.x) and backported to some
older kernels (notably rhel 6.6)

The issue: The ESP packets are arriving sometimes very late or they do
not arrive at all. The issues are most noticeable after restarting the
IPsec daemon.

The problem as explained by Herbert Xu:

Your first TCP SYN packet triggers the IPsec lookup, however, the
packet itself is dropped. TCP then retransmits but it only gets
through after the IPsec SAs are fully instated, resulting in the
delay.

What happens in some kernels is that the IPsec trigger occurs in a
sleepable context, which means that the sending process will wait for
the IPsec SAs to be installed before sending the first SYN. However,
this was never meant to be a complete solution to supporting
auto=route as it relies on the fact that there must be some sleepable
context prior to the SYN packet being sent.

Evidently this is no longer the case for some kernels. Going forward I
suggest two courses of action:

1\) Doo not rely on auto=route. Instead use auto=start and ensure that
you synchronously wait for the SAs to complete. For example, ipsec
auto --up foo will bring foo up synchronously, while ipsec auto
--asynchronous --up foo will not wait and thus may fail.

2\) I will take this issue to the IPsec maintainer and the network
maintainer to see if we can make adjustments to allow at least the TCP
connection case to work with auto=route. However, there is no
guarantee that this will be done as we may not be able to insert the
requisite sleepable context into the general network stack just so
that IPsec auto=route can work.

Longer term for auto=route to be properly supported someone needs to
implement packet queueing on larval SAs.

Possible work around:

            echo 0 > /proc/sys/net/core/xfrm_larval_drop
            echo 3 > /proc/sys/net/ipv4/tcp_syn_retries

This means that the first retransmit of the SYN packet (+1s) should
make it through, rather than the current behaviour where only the
fourth retransmit (+15s) makes it through.

Note that this workaround causes a regression on the connect() call to
immediately return on a non-blocking socket with an appropriate POSIX
compliant errno, which is why the workaround also sets the TCP SYN
retry count to 3.

## PSK doesn't work against cisco ASA 55xx

While libreswan has very little restrictions to Pre-shared secret
Cisco has additional restriction, you can't have question mark '?' in
psk.  Cisco handles that as help request.

## When using hundreds of tunnels on a xen based cloud system like AWS, a fraction of tunnels fail regularly

This is a [known
issue](https://bugzilla.redhat.com/show_bug.cgi?id=1085025) that could
be a problem of the aesni kernel module in combination with the xen
hypervisor. Try unloading the aesni.ko kernel module on the xen
server.  If you can confirm this fixes your issue (we cannot change
the AWS servers), please email the swan-dev list with a confirmation.

## My XAUTH authentication via PAM always claims the password is incorrect on centos6

This is an odd bug (feature?) that shows up when you have disabled
selinux in /etc/sysconfig/selinux. Running selinux in permissive (or
enforcing) mode seems to resolve this.

## Why is it recommended to disable send_redirects in /proc/sys/net ?

Let's say you have a VPN server in a cloud that you use with your
phone.  Your phone will setup an IPsec VPN and all its traffic is
encrypted and send to the cloud instance, which decrypts it and sends
it on the internet, using SNAT. Replies it receives are encrypted and
send to your phone.

Your phone will send the VPN server an encrypted packet. The server
receives it on eth0 (its only interface!) and decrypts it. The
decrypted packet is then ready to get routed. The server looks which
interface it should send the packet to. It is destined to go out
eth0. Since the packet came in via eth0 and would go out via eth0, the
server concludes there clearly must be a better path not involving
itself, since it is going out the same interface. It has no idea the
packet arrived encrypted and got decrypted.

This is why we recommend disabling "send_redirects" in
/etc/sysctl.conf using

    net.ipv4.conf.all.send_redirects = 0
    net.ipv4.conf.default.send_redirects = 0

## How do I configure my firewall to allow IPsec

If using firewalld, you can issue:

    firewall-cmd --add-service="ipsec"
    firewall-cmd --runtime-to-permanent

If using iptables (directly of via the iptables service), you will need
to:

- Accept any port to your UDP port 500 (IKE port without NAT)
- Accept any port to your UDP port 4500 (IKE port with NAT, multiplexed
  with ESPinUDP)
- Accept proto 50 (ESP)
- For TCP support, accept any port to your TCP port 4500 (or whatever
  port you provision for this, eg 443)

Remember to accept any source port, since NAT gateways can remap the
source IP to an ephemeral port, although if there is only one
IKE/IPsec device behind the NAT gateway they might try to keep the
original port number.

## Why is it recommended to disable rp_filter in /proc/sys/net ?

The kernel has a notion of which interface a packet came from and
where it will go to and it determines if the path through the machine
makes sense based on the IP address it sees. If 10.0.2.0/24 lives on
eth0 and 1.2.3.4 has eth1 with the default route, then rp_filter will
automatically block a 10.0.2.1 packet coming in on eth1. The rp_filter
code is an implementation of [RFC-3704
<https://tools.ietf.org/html/rfc3704>](RFC-3704_https:/tools.ietf.org/html/rfc3704).
Of course, you should created had firewall rules on the machine that
would block these packets too. AND firewall rules on the router in
front of the machine.

The problem with IPsec appears when you hand out a 10.0.2.13 address,
like via XAUTH/IPsec. A packet with IP a.b.c.d comes in on eth1 for
1.2.3.4, which passes rp_filter, then gets decrypted to 10.0.2.13. Now
the packet is still seen as coming from eth1, so rp_filter will drop
the packet as 10.0.2.0/24 packets are only expected to originate from
eth0.

This is why we recommend disabling "rp_filter" in /etc/sysctl.conf using

    net.ipv4.conf.default.rp_filter = 0

A network restart or reboot might be neccessary for this entry to be
picked up. As a one shot disabling for all interfaces, you can use:

    for i in /proc/sys/net/ipv4/conf/*; do echo 0 > $i/rp_filter; done

## NAT + IPsec is not working

When using NAT on the same linux machine as IPsec, care must be taken
that packets meant for an IPsec remote address is not NATed. The NATed
packet would no longer match the IPsec tunnel source and destination
IP address ranges.

If you have the following common catch-all NAT rule:

    -A POSTROUTING -o eth0 -j MASQUERADE

or

    -A POSTROUTING -o eth0 -j SNAT --to-source 1.2.3.4

then either change these rules to only apply with a non-ipsec policy:

    -A POSTROUTING -o eth0 -m policy --dir out --pol none -j MASQUERADE

or insert a ipsec skip rule before these:

    -A POSTROUTING -o eth0 -m policy --dir out --pol ipsec -j RETURN
    -A POSTROUTING -o eth0 -j MASQUERADE

## Can I hand out LAN IP addresses in the addresspool?

Yes, but you will need to enable proxyarp on the IPsec server. You can
do this globally using the proxyarp entry in /etc/sysctl.conf, for
example if your LAN interface is ethX, use

    net.ipv4.conf.ethX.proxy_arp=1

## No acceptable ECDSA/RSA-PSS ASN.1 signature

This is an interop issue between libreswan and strongswan. When using
RFC -7427 style autentication, libreswan only allows RSA-PSS and not
RSA-v1.5 based signatures. As per RFC 8247, it is expected that any
implementation doing RFC-7427 MUST support RSA-PSS and MAY support
RSA-v1.5. Strongswan unfortunately defaults to using RSA-v1.5 when
configured with authby=rsasig, even if it received a RSA-PSS
signature.  To work around this problem on strongswan, the ipsec.conf
should be changed to contain:

    conn example
        authby=rsasig
        rightauth=ike:rsa/pss-sha512-sha384-sha256
        leftauth=ike:rsa/pss-sha512-sha384-sha256
        [...]
