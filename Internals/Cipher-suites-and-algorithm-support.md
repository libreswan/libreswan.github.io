Support for algorithms and ciphers tries to narrowly follow two RFCs:

- [RFC 8221](https://tools.ietf.org/html/rfc8221): Cryptographic
  Algorithm Implementation Requirements and Usage Guidance for
  Encapsulating Security Payload (ESP) and Authentication Header (AH)

<!-- -->

- [RFC 8247](https://tools.ietf.org/html/rfc8247): Algorithm
  Implementation Requirements and Usage Guidance for the Internet Key
  Exchange Protocol Version 2 (IKEv2)

## Integrity and PRF

In both IKEv1 and IKEv2 there is a PRF and an INTEG algorithm. Libreswan
only supports scenario's where the PRF and INTEG are the same. The
reason is, if the algorithm is good enough for PRF, it is goof enough
for INTEG. If it is not good enough for one of the two, it is also not
good enough for the other. But when the IKEv2 RFCs were written, some
people insisted on being able to have different values for these.
Libreswan in fact cannot pass one [TAHI suite test
case](http://www.umip.org/docs/tahi.html) because libreswan do not
support such strange (ut RFC compliant) configurations.

There is one special case. While classic encryption/integrity uses two
separate algorithms (eg AES_CBC with HMAC-SHA2, or 3DES with HMAC-SHA1),
the newer AEAD algorithms work differently. These algorithms only
require one pass of the data to do both encryption/decryption *and*
integrity in one step. Examples of such algorithms are AES_GCM, AES_CCM
and CHACHA20-POLY1305. IKE negotiations (for IKE as well as IPsec) send
proposals listing encryption and integrity (and prf) values. Instead of
adding a new type for AEADs, they decided to list these AEAD algorithms
as "encryption algorithm" types. These AEAD encryption types are not
allowed to specify an "integrity" algorithm (or specify integrity
algorithm "none").

Since there the integrity algorithm is none, we don't know what to use
for PRF. We cannot fill it in from the integrity, so you have to specify
which prf you want to use. Hence you end up with a syntax like:

            ike=aes_gcm-sha2

Which means ENCR=aes-gcm, INTEG=null/none and PRF=sha2

The PRF is used to generate key material, which is used to create keys
for IPsec SA. The IPsec SA themselves do not have a "prf". So, to
specify aes_gcm for IPsec/ESP, you would use:

            phase2alg=aes_gcm-null

And as of libreswan 3.22, you can leave out the -null for the phase2alg
entry, as this is assumed to be the case. Any other integrity function
will be rejected.