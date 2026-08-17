## Introduction

Prior to RFC 7427, the Internet Key Exchange version 2 (IKEv2) signature
based authentication is signaled per algorithm i.e., there is one
Authentication Method for RSA digital signatures, one Authentication
Method for DSS digital signatures (using SHA-1), and three separate
Authentication Methods for the different ECDSA curves with each variant
tied to exactly one hash algorithm. This leads to two problems:

- The sending and receiving parties do not know which Hash Algorithm is
  used to generate a signature.
- Each time there is a new Signature Algorithm, a new Authentication
  Method is required, which required writing a new RFC specification.

Therefore this design is cumbersome when more signature algorithms, hash
algorithms, and elliptic curves need to be supported.

RFC 7427 solves these problems by generalising the IKEv2 signature
support to allow any signature method supported by PKIX and also adds a
signature hash algorithm negotiation. RFC 7427 defines a new "Digital
Signature Authentication" method. This method is flexible to include all
current signature methods (RSA, DSA, ECDSA, RSASSA-PSS, etc.) and add
new methods (ECGDSA, ElGamal, etc.) in the future.

The libreswan implementation of RFC 7427 is included in version 3.22.
RFC 7427 based Digital Signatures is automatically enabled if the
"authby" parameter in ipsec.conf is configured to use RSA and it has
received SHA-1 in the Hash Algorithm notification payload from the peer
indicating that the remote peer supports this method as well.

## Implementation

To make Libreswan RFC 7427 compliant, the following items have been
implemented :

1\. Hash Algorithm Notification

Notify payload of type SIGNATURE_HASH_ALGORITHMS is sent inside the
IKE_SA_INIT exchange. The supported hash algorithms like SHA1, SHA2 and
IDENTITY are exchanged by the initiator and responder in this notify
payload. The negotiated hash algorithm is the one that is supported by
both parties. This hash algorithm is used to generate the signature sent
in the Authentication payload. The decision of sending the Hash
Algorithm notification when Libreswan is the initiator is based on
checking which Signature algorithm is configured in the "authby"
parameter in ipsec.conf. When Libreswan is the responder, it responds
with a hash algorithm notification only if it has received one and SHA-1
was sent in it.

2\. Authentication payload

A new Authentication Method called *Digital Signature* is sent in the
IKE_AUTH message exchange. Earlier, the Authentication Data field inside
the Authentication payload contained only the signature value. Now, the
signature value is prefixed with an ASN.1 object indicating the
algorithm used to generate the signature. The ASN.1 object contains the
algorithm identification OID, which identifies both the signature
algorithm and the hash algorithm used for calculating the signature.
[IANA
registry](https://www.iana.org/assignments/ikev2-parameters/ikev2-parameters.xhtml#ikev2-parameters-12)
specifies the values to be used. The initial Digital Signature
Authentication method implementation for Libreswan only includes support
for the RSA with SHA-1 hash algorithm.

The following items are not yet implemented :

- Support for Signature Algorithms ECDSA and RSASSA-PSS
- Support for Hash Algorithm SHA-2

3\. Test Suite changes

The Test Suite was extended by adding test cases to verify feature
functionality and perform interoperability tests. Negative tests cases
were added using impairments that emulate clients that do not support
the Digital Signature Authentication scheme as specified by the RFC
7427, to confirm connectivity with clients not supporting the new
Authentication Method.

## Issues encountered

[The RFC
4307bis](https://datatracker.ietf.org/doc/draft-ietf-ipsecme-rfc4307bis/)
mandates the usage of RSASSA-PSS along with Digital Signature
Authentication. However the older flavour PKCS v1.5 may still be
supported. But a way to indicate to the peer, which flavour of RSA
should be used is not yet described. Since no other client supports
RSASSA-PSS, interoperability tests cannot be performed.

## Future work

- Support for Signature algorithms ECDSA and RSASSA-PSS

Implementation of ECDSA requires the extension of the Libreswan's public
key code to remove the hardwiring for RSA. Implementation of RSASSA-PSS
would have to use different NSS library method call. The implementation
is waiting for [RFC
4307bis](https://datatracker.ietf.org/doc/draft-ietf-ipsecme-rfc4307bis/)
to clarify the usage of PSS.

- Support for Hash algorithm SHA-2.

SHA2 needs an extended parser for the authby = keyword, in ipsec.conf.

## Source code

[Feature
implementation](https://github.com/libreswan/libreswan/commit/14c76638612226ab87f8fe14cb8b94282f729651)

[Addition and modification of test
cases](https://github.com/libreswan/libreswan/commit/272301a82178ea1a2c8afd39f26e2e024ef21853)

This project work was sponsored by Google as part of the Google Summer
of Code 2017 Program. The implementation for this project is done by
Sahana Prasad (sahana.prasad07@gmail.com) under the tutelage of Paul
Wouters.