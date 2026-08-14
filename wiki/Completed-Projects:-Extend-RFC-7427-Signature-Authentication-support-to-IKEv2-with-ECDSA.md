## Introduction

As part of Google summer of Code work in 2017 described in , RFC-7427
Digital Signature Authentication was implemented with support for RSA.
This work is an extension to support ECDSA. Implementation of ECDSA
requires the modification of the existing Libreswan public key code to
fix the RSA only parts so that it is able to accept different new types
of keys in the future ( not just limited to ECDSA ). This will ensure
compliance to RFC-7427 and RFC-8247.

As per RFC-4754, ECDSA signatures are smaller than RSA signatures of
similar cryptographic strength. ECDSA public keys (and certificates) are
smaller than similar strength DSA keys, resulting in improved
communications efficiency. Furthermore, on many platforms, ECDSA
operations can be computed more quickly than similar strength RSA or DSA
operations for a security analysis of key sizes across public key
algorithms.

## Implementation

To make Libreswan RFC 7427 and RFC 8247 compliant, the following items
have been implemented :

1\. Fixing the RSA only public key code

Major code changes were done in ikev2_keys.c , x509.c and secrets.c. New
structures are defined for Private and public ECDSA key parameters. Most
functions that had a specific check for rsa are now able to also handle
ecdsa as public key algorithm. This involves checking if a certificate
is of type ecdsa and extracting the public key from it and storing it in
the NSS Database. Code changes are made to obtain the keyid and ckaid of
the ECDSA public keys. These IDs are used to retrieve the public key
from pluto secrets and extract the private key from the certificate
respectively. New public key algorithm and policy , PUBKEY_ALG_ECDSA and
POLICY_ECDSA are introduced respectively.

2\. Signature Verification

To verify a signature from the peer, the public key of the peer has to
be retrieved from pluto_pubkeys and check if the keyed matches. Inorder
to verify the hash received by the peer, we also compute our own hash
using the PRF(SK_d,ID\[ir\]). The computed hash, received Signature and
the retrieved Public are then used by NSS API : ECDSA_VerifyDigest to
verify the Signature. The ECDSA Signature is DER encoded and is as
follows :

Ecdsa-Sig-Value ::= SEQUENCE {

`          r     INTEGER,`
`          s     INTEGER`
` }`

Therefore before using the ECDSA_VerifyDigest API, the Signature must be
DER decoded to obtain the integers r and s. EC_FillParams is used to
fill the ecParams of the public key.

3\. Signature generation

Private key is retrieved using the API PK11_FindKeyByKeyID or
PK11_FindKeyByAnyCert through the CKAID. Signature generation is
performed by using the PK11_Sign API

4\. Test Suite changes

The Test Suite was extended by adding test cases to verify feature
functionality and perform interoperability tests with strong swan.

## Configuring ECDSA in Libreswan

Support for configuring authby=ecdsa

Possible options for setting ecdsa as the public key to be used for
Digital Signature Authentication with appropriate SHA2 hash algorithm
are as follows :

authby = ecdsa/ecdsa-sha2_256, ecdsa-sha2_384, ecdsa-sha2_512

## Issues encountered

NSS looks for specific x509v3 certificate extensions in the end
certificates and It is unclear which one is exactly missing in the
certificates being used. This error has be be debugged further (as there
is little information from the nss logs): SECERR: 35 (0x23): Certificate
extension not found. It was found that this error was set and not
cleared by NSS. It was solved by checking for errors only when private
key retrieved was not equal to NULL.

## Future work

Interoperability with Apple and Elvis Plus

## Source code

<https://github.com/libreswan/libreswan/commit/12f2f1a03de214e1e3ecf5cfa84950f09a8d35c4>

<https://github.com/libreswan/libreswan/commit/c6a711c091974b323feb61b3ea5c86713b80ea63>

This project work was sponsored by Google as part of the Google Summer
of Code 2018 Program. The implementation for this project is done by
Sahana Prasad (sahana.prasad07@gmail.com) under the tutelage of Paul
Wouters and Andrew Cagney

## Additional Work during GSoC 2018

Implementation of RSA-PSS and support for SHA2 and it's variants. The
work was started before GSoC 2018 but was fully completed and tested
during the GSoC 2018 period. Work is described in this project page
[RSA-PSS Support in compliance with RFC 7427 and RFC
8247](./Completed-Projects:-RSA-PSS-Support-in-compliance-with-RFC-7427-and-RFC-8247).
