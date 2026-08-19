## Introduction

Libreswan currently supports RSA as Digital Signature Authentication
method, so it needs to be extended internally to use other methods, such
as ECDSA or EDDSA. Implementation of ECC/ECDSA requires the modification
of the existing Libreswan public key code to fix the RSA only parts so
that it is able to accept different new types of keys in the future (
not just limited to EDDSA ). Libreswan will then be compliant to
RFC-7427 and RFC-8247.

## Use Cases

**Use Case 1:** As an admin I should be able to configure ecdsa in
libreswan ipsec.conf as a digital signature authentication method

- Requirement 1: As per RFC 8247, ecdsa with sha2-256 should be
  supported and ecdsa with sha1 must not be supported.
- Requirement 2: Digital signature recommendations for hash function
  specify that sha2-256 must, sha2-384 may and sha2-512 should be
  supported. ( Should Libreswan support all three variants? )
- Requirement 3: Support for
  authby=secret\|rsasig\|null\|never\|rsa-HASH\|ecdsa-HASH in the
  ipsec.conf

**Use Case 2:** As an admin I should be able to configure other public
key algorithms along with ecdsa. Rational : Ecdsa might not be
implemented in all peers.

- Requirement 4: authby = ecdsa-HASH\|rsa-HASH. RSA can be configured to
  act as fallback incase Digital signature authentication with ecdsa
  fails.
- Requirement 5: if authby = ecdsa-HASH and there is no fallback then if
  the peer does not support ecdsa, IKE Authentication fails (Default
  behaviour, Retry?)

**Use Case 3:** As an Initiator, I should initiate IKE AUTH messages
with ecdsa support.

- Requirement 6: Authentication data must have the ASN.1 Algorithm
  identifiers as specified in Section A.3 of RFC 7427
- Requirement 7: Certificate Request payloads must have the
  algorithmIdentifier set to sha2WithECDSAEncryption
- Requirement 8: ECDSA Signature of the digest should be sent out in
  Authentication payload

Use Case 4: As a responder, I should respond to IKE AUTH messages with
ecdsa support.

- Requirement 9: Authentication data received must have the ASN.1
  Algorithm identifiers as specified in Section A.3 of RFC 7427

<!-- -->

- Requirement 10: Certificate Request payloads with algorithmIdentifier
  set to sha2WithECDSAEncryption must be validated.

<!-- -->

- Requirement 11: If ECDSA Signature verification of the digest fails,
  IKE AUTH failure is sent.

**Use Case 5:** Interoperability with Strongswan, Apple and ELVIS-PLUS