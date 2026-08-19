## Introduction

As part of Google summer of Code work in 2017 described in , RFC-7427
Digital Signature Authentication was implemented with support for RSA
v1.5. But RFC-8247, in section 3.2 Digital Signature Recommendations,
mandates the support for RSASSA-PSS with SHA-256. RSASSA-PSS was
developed in an effort to have more mathematically provable security.
PKCS \#1 v1.5 signatures were developed in an ad hoc manner; RSASSA-PSS
was developed based on mathematical foundations.

## Implementation

To make Libreswan RFC 7427 and RFC 8247 compliant, the following items
have been implemented :

1\. Removing support of RSA v1.5 with SHA1 as Digital Signature
Authentication method

2\. Support for SHA2 and its variants. authby =rsa-sha2, rsa-sha2_256,
rsa-sha2_384,rsa-sha2_512 authby = rsasig (old style RSA with SHA1 and
without Digital Signature Authentication)

3\. Signature generation and Verification for RSA-PSS through NSS APIs

4\. Test Suite changes

The Test Suite was extended by adding test cases to verify feature
functionality and perform interoperability tests with strong swan.

## Future work

To make RSA with SHA2 as default and fall back to RSA with SHA1 (if
configured) Example : authby=rsa-sha2,rsasig - RSA with SHA1 and without
Digital Signature Authentication

Interoperability test with Elvis Plus

## Source code

Code commit : <https://github.com/libreswan/libreswan/commit/fd547b0>

Testing commit : <https://github.com/libreswan/libreswan/commit/83fc58d>

The implementation for this project is done by Sahana Prasad
(sahana.prasad07@gmail.com) under the tutelage of Paul Wouters.