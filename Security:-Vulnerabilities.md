### Libreswan is vulnerable to TunnelCrack, see details

See [Libreswan and TunnelCrack](./Security:-Libreswan-and-TunnelCrack)

### Libreswan is not vulnerable to the OpenSSL "Heartbleed" exploit

See [Libreswan and Heartbleed](./Security:-Libreswan-and-Heartbleed)

### Libreswan is not vulnerable to bash CVE-2014-6271 or CVE-2014-7169

Libreswan sanitizers strings that may come from the network, such as
XAUTH username, domain and DNS servers by passing it through filter
functions **remove_metachar()** and **cisco_stringify()** before
assigning it to environment variables that are passed to the updown
scripts that invoke bash. These filters remove dangerous characters
including the ' character needed for these bash exploits.

### Libreswan **is** vulnerable to NSS CVE-2014-1568 RSA Signature Forgery

Please upgrade NSS to one of 3.17.1, 3.16.1 or 3.16.5.

This only affects libreswan when using X.509 certificates. Raw RSA
keys using leftrsasigkey/rightrsasigkey are not affected. Connections
using auth=secret (PSK) are also not affected.

See [Mozilla Foundation Security Advisory
2014-73](https://www.mozilla.org/security/announce/2014/mfsa2014-73.html)

### Libreswan is not vulnerable to LogJam / weakdh.org CVE-2015-4000

The IKE protocol never allowed any DH group smaller than MODP768.
Libreswan has never supported anything smaller than MODP1024

Libreswan as a client to a weak server will allow MODP1024 in IKEv1 as
the least secure option, and MODP1536 in IKEv2 as the least secure
option. However, the default is MODP2048.

Libreswan supports MODP group upto MODP8192, the ECP groups and
Curve25519.

Libreswan also supports the alternative primes for MODP1024 and
MODP2048 specified in RFC-5114. None of these will be placed in the
default proposal group due to the lack of transparency of where these
alternatives came from and why these were needed.

For more details, see ["The weak DH and LogJam attack impact on IKE /
IPsec (and the
\*swans)](https://nohats.ca/wordpress/blog/2015/05/20/weakdh-and-ike-ipsec/)

### Libreswan is not vulnerable to the TLS/IKE SLOTH / TRANSCRIPT attacks CVE-2015-7575

The IKE protocol is not affected, see ["The SLOTH attack and
IKE/IPsec"](https://access.redhat.com/blogs/product-security/posts/sloth)

### Libreswan is not vulnerable to CVE-2016-5361 (IKEv1 protocol is vulnerable to DoS amplification attack)

This attack basically spoofs IKEv1 packets from different IPs. Since
the IKEv1 protocol has the responder also retransmitting packets, one
spoofed packet can generate a response packet that is retransmitted a
number of times. This flaw is inherent to the IKEv1 protocol and was
addressed in IKEv2.

Nevertheless, libreswan has changed its implementation to not
retransmit as responder in these specific cases of receiving a "first
packet".  Since in IKEv1 the initiator is also responsible for
retransmission, this should not break any real IKEv1 clients.

### Libreswan is not vulnerable to CVE-2018-5389 ("Practical Attacks on IPsec IKE")

This CVE is issued along with the paper [The Dangers of Key Reuse:
Practical Attacks on IPsec
IKE](https://www.ei.rub.de/media/nds/veroeffentlichungen/2018/08/13/sec18-felsch.pdf).
The paper lists two attacks.

The first attack requires the use of two uncommon IKEv1 Authentication
Methods called "Encryption with RSA" (value 5) and "Revised encryption
with RSA" (value 6). These two modes are not implement by libreswan,
which only implements "RSA signatures" (value 3) for IKEv1. The
extension of this attack in the paper against IKEv2 assumes RSA key
reuse with these unsupported IKEv1 authentication methods, so
libreswan is not vulnerable to this attack.

The second attack requires IKEv1 or IKEv2 with weak PreSharedKeys
(PSKs). This is nothing new. Basically, you MITM the client (Alice)
and so perform a Diffie-Hellman key exchange. Alice will then send the
IKE_AUTH exchange packet containing their AUTH payload. Alice's AUTH
payload is constructed (as per RFC 7296):

    InitiatorSignedOctets = RealMessage1 | NonceRData | MACedIDForI
       GenIKEHDR = [ four octets 0 if using port 4500 ] | RealIKEHDR
       RealIKEHDR =  SPIi | SPIr |  . . . | Length
       RealMessage1 = RealIKEHDR | RestOfMessage1
       NonceRPayload = PayloadHeader | NonceRData
       InitiatorIDPayload = PayloadHeader | RestOfInitIDPayload
       RestOfInitIDPayload = IDType | RESERVED | InitIDData
       MACedIDForI = prf(SK_pi, RestOfInitIDPayload)

The attacker now has all values except the PSK, so it can go offline
and try out all the PSK's to see if it can recreate the received AUTH
payload, eg:

    for every PSK in dictionary
      if (calculate prf(prf(Shared Secret, "Key Pad for IKEv2"), <InitiatorSignedOctets>) == AUTH_of_Alice)
          print (Alice used PSK:%s", PSK)

The IKE RFC's list clearly that PSK's should never be based on short or
guessable passwords. Libreswan logs a warning about weak PSK's and
refuses to use such weak PSKs in FIPS mode. The [IKEv2
RFC](https://tools.ietf.org/html/rfc7296) clearly states this in three
different places:

       Note that it is a common but typically insecure practice to
       have a shared key derived solely from a user-chosen password
       without incorporating another source of randomness.  This is
       typically insecure because user-chosen passwords are unlikely
       to have sufficient unpredictability to resist dictionary
       attacks and these attacks are not prevented in this
       authentication method.  (Applications using password-based
       authentication for bootstrapping and IKE SA should use the
       authentication method in Section 2.16, which is designed to
       prevent off-line dictionary attacks.)  The pre-shared key needs
       to contain as much unpredictability as the strongest key being
       negotiated.

       When using pre-shared keys, a critical consideration is how to
       assure the randomness of these secrets.  The strongest practice
       is to ensure that any pre-shared key contain as much randomness
       as the strongest key being negotiated.  Deriving a shared
       secret from a password, name, or other low-entropy source is
       not secure.  These sources are subject to dictionary and
       social-engineering attacks, among others.

       As noted above, deriving the shared secret from a password is
       not secure.  This construction is used because it is
       anticipated that people will do it anyway.

We strongly recommend people to use X.509 or raw public keys instead
of PSKs. IKEv2 also supports RSA-PSS when using authby=rsa-sha2 so RSA
v1.5 and its Bleichenbacher oracles can be avoided altogether.

For those deployments insisting on needing passwords, but without
using X.509 and/or EAP authentication modes, there is [RFC 6467 Secure
Password Framework for IKEv2](https://tools.ietf.org/html/rfc6467)

       The IPsecME working group was chartered to provide for IKEv2 a
       symmetric secure password authentication protocol that supports
       the use of low-entropy shared secrets, and to protect against
       off-line dictionary attacks without requiring the use of
       certificates or the Extensible Authentication Protocol (EAP).

### Libreswan is not vulnerable to "The Deviation Attack" presented at TrustCom 2019

The paper is available at <https://hal.inria.fr/hal-01980276/document>

It is also known as "A Novel Denial-of-Service Attack Against IKEv2"

The attack described is a theoretical and extremely unpractical attack
that simply does not work against any IKE implementation. Various
people tried to convince the authors of this before final publication
of this paper at the IETF IPsec Working Group. See:
<https://mailarchive.ietf.org/arch/msg/ipsec/-xT8RclsMtdmFNzCAAR2PSGAPN0>

### Libreswan is not vulnerable to CVE-2019-14899 "Inferring and hijacking VPN-tunneled TCP connections"

Vulnerability disclosure: <https://seclists.org/oss-sec/2019/q4/122>

The Linux IPsec implementation (XFRM) is a "policy based VPN" and does
not accept unencrypted packets for IP ranges for which it has an IPsec
encryption policy, irrespective of the rp_filter setting. When using
VTI or XFRMi to create a "routing based VPN", AND disabling rp_filter
protection for spoofed traffic, libreswan is still not vulnerable as
it places the obtained VPN client IP address on the loopback device
with a non-global scope of 50, resulting in the unencrypted packet
still being dropped.

An additional defense can still be deployed in libreswan using the
tfc=1000 (or tfc=1500) option which causes all outgoing ESP traffic to
be padded to 1000 bytes (or the path MTU when specifying more than
what would otherwise fit) ensuring that nothing can be learned from
the size of the encrypted ESP packet.
