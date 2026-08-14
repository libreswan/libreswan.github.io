## Introduction

This project aims to extend the RFC-7427 Digital signature
authentication scheme to support EdDSA as per RFC 8420. Since Libreswan
relies on the NSS library for cryptographic operations, modifications in
the NSS code are required to add the implementation of EdDSA. The
mechanisms for generating Ed25519 keys, generating and verifying Ed25519
signatures need to be added to the NSS library.

As per RFC 8420, a new value "Identity" for the IKEv2
SIGNATURE_HASH_ALGORITHMS notification registry must be sent to indicate
this support. Sending this new value in the IKE_AUTH Message Exchange
indicates that the peer supports at least one signature algorithm that
accepts messages of an arbitrary size such as Ed25519 or Ed448.

## Implementation

Implementation of EdDSA required code changes in the NSS crypto library
as well as in libreswan itself.

### NSS Implementation

The freebl is the base cryptographic layer where the primitives are
implemented. The formally verified implementation (HACL\* Library) of
Ed25519 was integrated and EDDSA_SignDigest, EDDSA_VerifyDigest(), and
ED_NewKey() were added to in the freebl layer. The Softoken code is the
PKCS#11 plumbing layer. The current PKCS#11 spec defines the CKM_EDDSA
mechanism which is needed to add support for EdDSA. This mechanism was
implemented and the functions EDDSA_SignDigest() and
EDDSA_VerifyDigest() were hooked into NSC_SignInit() and
NSC_VerifyInit() using the stub functions nsc_EDDSASignStub() and
nsc_EDDSAVerifyStub(). This code was submitted to NSS upstream for
inclusion. Good feedback was received and the code is being merged.

The test suite of the gtests (freebl_gtest and pk11_gtest) was extended
and test vectors from RFC 8032 were included. The files Hacl_Ed25519.c,
Hacl_Ed25519.h, ed25519_unittest.cc, pk11_eddsa_unittest.cc,
pk11_eddsa_vectors.h were added. Modifications were made to
pk11_signature_test.h as EdDSA does not require prehashing of the
messages to generate and verify signatures. Other modifications were
made in blapi.h, pk11table.c, ec.c, loader.c, loader.h, pk11mech.c,
pkcs11c.c.

### Libreswan implementation

Changes were made in confread.c to parse the new eddsa option.
Connection policy, ASN.1 Object and structures for the public and
private keys were added to libreswan. Libreswan already supported ECDSA.
To avoid too much code duplication, functions were renamed and code was
generalized to EC that can handle both ECDSA and EDDSA. Modifications
were made in secrets.c to generalize the code. RFC-8420 specifies that
EdDSA versions that do not require prehashing of the message SHOULD be
used. To signal that no hashing needs to be done, the standard defines a
new value “Identity” in the SIGNATURE HASH ALGORITHMS IANA Registry.
This new hash algorithm IKEv2_HASH_ALGORITHM_IDENTITY was added and its
structure was defined in crypt_hash.c. To generate and verify
signatures, ikev2_eddsa.c was added and changes were made to
v2_calculate_sighash(), authsig_and_log_using_pubkey() to include
support for AUTHBY_EDDSA.

To test the new code, dest_certs.py and strongswan-ec-gen.sh were
extended to generate Ed25519 certificates and new test cases were added
to verify feature functionality and to perform interoperability tests
with strongswan to verify proper implementation.

To use EdDSA, the user must set the “authby” value of the connection in
the ipsec.conf to EdDSA (authby=eddsa).

## Issues encountered and Future Work

Currently, the NSS library supports curve25519 and uses it for Key
Exchange but the public keys generated can not be used for the Ed25519
signature scheme even though both of these generate keys using the same
curve. This is caused by NSS's public key generation code that currently
uses the encoding of the “x” coordinate of a point on the Curve25519
curve. Whereas an Ed25519 public key is encoded using the “x” and “y”
coordinates of a point on the Curve25519 curve.

A separate SECOID needs to be added to support Ed25519 x509
certificates. Changes need to be made to secsign.c and secvfy.c to
recognize and pass around the new OID value added for Ed25519. The new
OID has to be added to nss/lib/util/secoid\*. The oid table in the
secoid.c will link the new SECOID to the CKM_EDDSA mechanism. With this
functionality in place, libreswan can use the EDDSA algorithm as
specified in RFC 8420.

## Source code

NSS modifications:
<https://github.com/Rishabh-Kumar-07/nss/commit/ad50771b411fdf27251be9c5842180f2153e7e4a>

libreswan modifications:

1\.
<https://github.com/Rishabh-Kumar-07/libreswan/commit/245dd9726bcf7ebd6efb81dc76c55837d25c42d8>

2\.
<https://github.com/Rishabh-Kumar-07/libreswan/commit/14b0e0704fbc7b2afecae8e0f02390495bd69b25>

3\.
<https://github.com/Rishabh-Kumar-07/libreswan/commit/0469e43d7df35413de7c654b0c745e7c54469e18>

This project work was sponsored by Google as part of the Google Summer
of Code 2021 Program. The implementation for this project is done by
Rishabh Kumar (cs19mtech11026@iith.ac.in) under the mentorship of Paul
Wouters and Andrew Cagney.

Note: The commits had been accepted by the libreswan and will be
included in the release once support for EdDSA has been added to the NSS
library.