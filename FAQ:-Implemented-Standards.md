The following tables list the RFCs, drafts and standards related to IKE
and IPsec.

An overview of IKE and IPsec related RFC's is available in
[RFC 6071](https://datatracker.ietf.org/doc/rfc6071).

Implementation status can be:

| Status | Description |
|--------|-------------|
| vN.N | first implementation, see comments for limitations
| in-progress | by who, and date of last time this file was updated
| yes-please | very high on our wish list, interested?
| N/A | not applicable
| **X** | not really interested

## Current and Proposed [IP Security Maintenance and Extensions Working Group](https://datatracker.ietf.org/wg/ipsecme/documents/) (IPSECME) RFCs

- IKEv2: [RFC 7296](https://datatracker.ietf.org/doc/rfc7296)
- AH: [RFC 4302](https://datatracker.ietf.org/doc/rfc4302)
- ESP: [RFC 4303](https://datatracker.ietf.org/doc/rfc4303)

### IPSECME Internet-Drafts Active with the IESG

_I.e., about to be adopted, likely in last call._

_This table should track the "Active with the IESG Internet-Drafts" section of the IPSECME [documents](https://datatracker.ietf.org/wg/ipsecme/documents/) page._

| Standard | Area | Description | Status | Comments |
|----------|------|-------------|--------|----------|
| [RFC TBD](https://datatracker.ietf.org/doc/draft-ietf-ipsecme-ikev2-downgrade-prevention) | IKE | Downgrade Prevention for the Internet Key Exchange Protocol Version 2 (IKEv2) | yes-please | 2026-05-29, In Last Call (ends 2026-06-12)<br>
| [RFC TBD](https://datatracker.ietf.org/doc/draft-ietf-ipsecme-ikev2-pqc-auth) | IKE | Signature Authentication in the Internet Key Exchange Version 2 (IKEv2) using PQC | in-progress | Sahana <br> 2026-04-14, Publication Requested
| [RFC TBD](https://datatracker.ietf.org/doc/draft-ietf-ipsecme-ikev2-mlkem) | IKE | Post-quantum Key Exchange with ML-KEM in the Internet Key Exchange Protocol Version 2 (IKEv2) | v5.4 | 2026-03-15, In Last Call (ends 2026-06-15)

### IPSECME Adopted and Related RFCs

_This table is a sorted merge of two tables._

_This table should track the "RFCs" and "Related RFCs" sections of the
IPSECME
[documents](https://datatracker.ietf.org/wg/ipsecme/documents/) page._

| Standard | Area | Description | Status | Comments |
|----------|------|-------------|--------|----------|
| [RFC 9867](https://datatracker.ietf.org/doc/rfc9867) | IKE | Mixing Preshared Keys in the IKE_INTERMEDIATE and CREATE_CHILD_SA Exchanges of the Internet Key Exchange Protocol Version 2 (IKEv2) for Post-Quantum Security | v5.2 | IKE_INTERMEDIATE: v5.2 <br/> CREATE_CHILD_SA: to-be-done
| [RFC 9838](https://datatracker.ietf.org/doc/rfc9838) | IKE | Group Key Management Using the Internet Key Exchange Protocol Version 2 (IKEv2)
| [RFC 9827](https://datatracker.ietf.org/doc/rfc9827) | IKE | Renaming the Extended Sequence Numbers (ESN) Transform Type in the Internet Key Exchange Protocol Version 2 (IKEv2) | v5.4
| [RFC 9611](https://datatracker.ietf.org/doc/rfc9611) | IKE | Internet Key Exchange Protocol Version 2 (IKEv2) Support for Per-Resource Child Security Associations (SAs) | in-progress | omoris
| [RFC 9593](https://datatracker.ietf.org/doc/rfc9593) | IKE | Announcing Supported Authentication Methods in the Internet Key Exchange Protocol Version 2 (IKEv2) | in-progress | fazzel vukasink
| [RFC 9478](https://datatracker.ietf.org/doc/rfc9478) | IKE | Labeled IPsec Traffic Selector Support for the Internet Key Exchange Protocol Version 2 (IKEv2) | v4.4
| [RFC 9464](https://datatracker.ietf.org/doc/rfc9464) | IKE | Internet Key Exchange Protocol Version 2 (IKEv2) Configuration for Encrypted DNS
| [RFC 9395](https://datatracker.ietf.org/doc/rfc9395) | IKE | Deprecation of the Internet Key Exchange Version 1 (IKEv1) Protocol and Obsoleted Algorithms
| [RFC 9370](https://datatracker.ietf.org/doc/rfc9370) | IKE | Multiple Key Exchanges in the Internet Key Exchange Protocol Version 2 (IKEv2) | v5.4 <br> in-progress | addke1: v5.4 <br/> IKE_INTERMEDIATE: v4.0 <br/> IKE_FOLLOW_UP_KE (IKE): v5.4 <br/> IKE_FOLLOW_UP_KE (Child): daiki
| [RFC 9349](https://datatracker.ietf.org/doc/rfc9349) | IKE | Definitions of Managed Objects for IP Traffic Flow Security
| [RFC 9348](https://datatracker.ietf.org/doc/rfc9348) | IKE | A YANG Data Model for IP Traffic Flow Security
| [RFC 9347](https://datatracker.ietf.org/doc/rfc9347) | IKE | Aggregation and Fragmentation Mode for Encapsulating Security Payload (ESP) and Its Use for IP Traffic Flow Security (IP-TFS) | v5.2
| [RFC 9329](https://datatracker.ietf.org/doc/rfc9329) | IKE | TCP Encapsulation of Internet Key Exchange Protocol (IKE) and IPsec Packets | v4.0 | | Updated RFC 8229?
| [RFC 9242](https://datatracker.ietf.org/doc/rfc9242) | IKE | Intermediate Exchange in the Internet Key Exchange Protocol Version 2 (IKEv2) | v4.0
| [RFC 9227](https://datatracker.ietf.org/doc/rfc9227) | IKE | Using GOST Ciphers in the Encapsulating Security Payload (ESP) and Internet Key Exchange Version 2 (IKEv2) Protocols
| [RFC 8983](https://datatracker.ietf.org/doc/rfc8983) | IKE | Internet Key Exchange Protocol Version 2 (IKEv2) Notification Status Types for IPv4/IPv6 Coexistence
| [RFC 8784](https://datatracker.ietf.org/doc/rfc8784) | IKE | Mixing Preshared Keys in the Internet Key Exchange Protocol Version 2 (IKEv2) for Post-quantum Security | v3.28
| [RFC 8750](https://datatracker.ietf.org/doc/rfc8750) | IKE | Implicit Initialization Vector (IV) for Counter-Based Ciphers in Encapsulating Security Payload (ESP)
| [RFC 8598](https://datatracker.ietf.org/doc/rfc8598) | IKE | Split DNS Configuration for the Internet Key Exchange Protocol Version 2 (IKEv2)
| [RFC 8420](https://datatracker.ietf.org/doc/rfc8420) | IKE | Using the Edwards-Curve Digital Signature Algorithm (EdDSA) in the Internet Key Exchange Protocol Version 2 (IKEv2) | v5.4 | Limited by NSS
| [RFC 8247](https://datatracker.ietf.org/doc/rfc8247) | IKE | Algorithm Implementation Requirements and Usage Guidance for the Internet Key Exchange Protocol Version 2 (IKEv2)
| [RFC 8229](https://datatracker.ietf.org/doc/rfc8229) | IKE | ~~TCP Encapsulation of IKE and IPsec Packets~~ | v4.0 | Updated by [RFC 9329](https://datatracker.ietf.org/doc/rfc9329)
| [RFC 8221](https://datatracker.ietf.org/doc/rfc8221) | IPsec | Cryptographic Algorithm Implementation Requirements and Usage Guidance for Encapsulating Security Payload (ESP) and Authentication Header (AH)
| [RFC 8031](https://datatracker.ietf.org/doc/rfc8031) | IKE | Curve25519 and Curve448 for the Internet Key Exchange Protocol Version 2 (IKEv2) Key Agreement | v3.25 | Curve25519 (dh31): v3.25 <br/> Curve448 (dh32): Needs NSS support
| [RFC 8019](https://datatracker.ietf.org/doc/rfc8019) | IKE | Protecting Internet Key Exchange Protocol Version 2 (IKEv2) Implementations from Distributed Denial-of-Service Attacks
| [RFC 7791](https://datatracker.ietf.org/doc/rfc7791) | IKE | Cloning the IKE Security Association in the Internet Key Exchange Protocol Version 2 (IKEv2)
| [RFC 7634](https://datatracker.ietf.org/doc/rfc7634) | IKE | "ChaCha20, Poly1305, and Their Use in the Internet Key Exchange Protocol (IKE) and IPsec" | v3.26
| [RFC 7619](https://datatracker.ietf.org/doc/rfc7619) | IKE | The NULL Authentication Method in the Internet Key Exchange Protocol Version 2 (IKEv2) | v2.x
| [RFC 7427](https://datatracker.ietf.org/doc/rfc7427) | IKE | Signature Authentication in the Internet Key Exchange Version 2 (IKEv2) | v3.26 | aka DIGSIG
| [RFC 7383](https://datatracker.ietf.org/doc/rfc7383) | IKE | Internet Key Exchange Protocol Version 2 (IKEv2) Message Fragmentation | v3.14
| [RFC 7321](https://datatracker.ietf.org/doc/rfc7321) | IPsec | Cryptographic Algorithm Implementation Requirements and Usage Guidance for Encapsulating Security Payload (ESP) and Authentication Header (AH)
| [RFC 7296](https://datatracker.ietf.org/doc/rfc7296) | IKE | Internet Key Exchange Protocol Version 2 (IKEv2) | yes
| [RFC 7018](https://datatracker.ietf.org/doc/rfc7018) | IPsec | Auto-Discovery VPN Problem Statement and Requirements
| [RFC 6989](https://datatracker.ietf.org/doc/rfc6989) | IKE | Additional Diffie-Hellman Tests for the Internet Key Exchange Protocol Version 2 (IKEv2) | N/A
| [RFC 6867](https://datatracker.ietf.org/doc/rfc6867) | IKE | An Internet Key Exchange Protocol Version 2 (IKEv2) Extension to Support EAP Re-authentication Protocol (ERP)
| [RFC 6631](https://datatracker.ietf.org/doc/rfc6631) | IKE | Password Authenticated Connection Establishment with the Internet Key Exchange Protocol version 2 (IKEv2)
| [RFC 6628](https://datatracker.ietf.org/doc/rfc6628) | IKE | Efficient Augmented Password-Only Authentication and Key Exchange for IKEv2
| [RFC 6617](https://datatracker.ietf.org/doc/rfc6617) | IKE | Secure Pre-Shared Key (PSK) Authentication for the Internet Key Exchange Protocol (IKE)
| [RFC 6479](https://datatracker.ietf.org/doc/rfc6479) | IPsec | IPsec Anti-Replay Algorithm without Bit Shifting | N/A | kernel
| [RFC 6467](https://datatracker.ietf.org/doc/rfc6467) | IKE | Secure Password Framework for Internet Key Exchange Version 2 (IKEv2)
| [RFC 6380](https://datatracker.ietf.org/doc/rfc6380) | IPsec | Suite B Profile for Internet Protocol Security (IPsec) | v
| [RFC 6379](https://datatracker.ietf.org/doc/rfc6379) | IPsec | Suite B Cryptographic Suites for IPsec | v | Not all ciphers are implemented
| [RFC 6311](https://datatracker.ietf.org/doc/rfc6311) | IKE | Protocol Support for High Availability of IKEv2/IPsec
| [RFC 6290](https://datatracker.ietf.org/doc/rfc6290) | IKE | A Quick Crash Detection Method for the Internet Key Exchange Protocol (IKE)
| [RFC 6071](https://datatracker.ietf.org/doc/rfc6071) | IKE | IP Security (IPsec) and Internet Key Exchange (IKE) Document Roadmap
| [RFC 6027](https://datatracker.ietf.org/doc/rfc6027) | IKE | IPsec Cluster Problem Statement
| [RFC 6023](https://datatracker.ietf.org/doc/rfc6023) | IKE | A Childless Initiation of the Internet Key Exchange Version 2 (IKEv2) Security Association (SA)
| [RFC 5998](https://datatracker.ietf.org/doc/rfc5998) | IKE | An Extension for EAP-Only Authentication in IKEv2 | v4.7 | server only
| [RFC 5996](https://datatracker.ietf.org/doc/rfc5996) | IKE | ~~Internet Key Exchange Protocol Version 2 (IKEv2)~~ | | Obsolete, see [RFC 7296](https://datatracker.ietf.org/doc/rfc7296)
| [RFC 5930](https://datatracker.ietf.org/doc/rfc5930) | IKE | Using Advanced Encryption Standard Counter Mode (AES-CTR) with the Internet Key Exchange version 02 (IKEv2) Protocol | v3.14
| [RFC 5903](https://datatracker.ietf.org/doc/rfc5903) | IKE | Elliptic Curve Groups modulo a Prime (ECP Groups) for IKE and IKEv2 | v3.20 | added to defaults in v3.28
| [RFC 5879](https://datatracker.ietf.org/doc/rfc5879) | IPsec | Heuristics for Detecting ESP-NULL Packets | N/A | kernel
| [RFC 5857](https://datatracker.ietf.org/doc/rfc5857) | IKE | IKEv2 Extensions to Support Robust Header Compression over IPsec
| [RFC 5840](https://datatracker.ietf.org/doc/rfc5840) | IPsec | Wrapped Encapsulating Security Payload (ESP) for Traffic Visibility | **X**
| [RFC 5739](https://datatracker.ietf.org/doc/rfc5739) | IKE | IPv6 Configuration in Internet Key Exchange Protocol Version 2 (IKEv2)
| [RFC 5723](https://datatracker.ietf.org/doc/rfc5723) | IKE | Internet Key Exchange Protocol Version 2 (IKEv2) Session Resumption | v5.2
| [RFC 5685](https://datatracker.ietf.org/doc/rfc5685) | IKE | Redirect Mechanism for the Internet Key Exchange Protocol Version 2 (IKEv2) | v3.28
| [RFC 5660](https://datatracker.ietf.org/doc/rfc5660) | IPsec | IPsec Channels: Connection Latching | **X**
| [RFC 5529](https://datatracker.ietf.org/doc/rfc5529) | IPsec | Modes of Operation for Camellia for Use with IPsec | v3.11
| [RFC 5282](https://datatracker.ietf.org/doc/rfc5282) | IKE | Using Authenticated Encryption Algorithms with the Encrypted Payload of the Internet Key Exchange version 2 (IKEv2) Protocol | v3.7
| [RFC 5114](https://datatracker.ietf.org/doc/rfc5114) | IPsec | Additional Diffie-Hellman Groups for Use with IETF Standards | v3.20 | secp256r1 (dh19): v3.20 <br/> secp384r1 (dh20): v3.20 <br/> secp521r1 (dh21): v3.20 <br/> dh22: v2.x <br/> dh23: v2.x <br/> dh24: v2.x <br/> dh25: to-be-done <br/> dh26: to-be-done
| [RFC 4868](https://datatracker.ietf.org/doc/rfc4868) | IPsec | Using HMAC-SHA-256, HMAC-SHA-384, and HMAC-SHA-512 with IPsec | v3.14
| [RFC 4806](https://datatracker.ietf.org/doc/rfc4806) | IKE | Online Certificate Status Protocol (OCSP) Extensions to IKEv2 | v3.19 | Uses NSS
| [RFC 4754](https://datatracker.ietf.org/doc/rfc4754) | IKE | IKE and IKEv2 Authentication Using the Elliptic Curve Digital Signature Algorithm (ECDSA) | v3.28 | Discouraged, use SECKEY<br/>still neded by Android and [microsoft](https://github.com/libreswan/libreswan/issues/659)?
| [RFC 4739](https://datatracker.ietf.org/doc/rfc4739) | IKE | Multiple Authentication Exchanges in the Internet Key Exchange (IKEv2) Protocol
| [RFC 4615](https://datatracker.ietf.org/doc/rfc4615) | IKE | The Advanced Encryption Standard-Cipher-based Message Authentication Code-Pseudo-Random Function-128 (AES-CMAC-PRF-128) Algorithm for the Internet Key Exchange Protocol (IKE) | v3.25
| [RFC 4555](https://datatracker.ietf.org/doc/rfc4555) | IKE | IKEv2 Mobility and Multihoming Protocol (MOBIKE) | v3.25 | "Additional Addresses" not supported
| [RFC 4543](https://datatracker.ietf.org/doc/rfc4543) | IPsec | The Use of Galois Message Authentication Code (GMAC) in IPsec ESP and AH | **X** | Kernel support is availble, ike support is not
| [RFC 4494](https://datatracker.ietf.org/doc/rfc4494) | IPsec | The AES-CMAC-96 Algorithm and Its Use with IPsec | **X**
| [RFC 4478](https://datatracker.ietf.org/doc/rfc4478) | IKE | Repeated Authentication in Internet Key Exchange (IKEv2) Protocol
| [RFC 4434](https://datatracker.ietf.org/doc/rfc4434) | IKE | The AES-XCBC-PRF-128 Algorithm for the Internet Key Exchange Protocol (IKE) | v3.25
| [RFC 4309](https://datatracker.ietf.org/doc/rfc4309) | IPsec | Using Advanced Encryption Standard (AES) CCM Mode with IPsec ESP | v3.7
| [RFC 4308](https://datatracker.ietf.org/doc/rfc4308) | IPsec | Cryptographic Suites for IPsec
| [RFC 4304](https://datatracker.ietf.org/doc/rfc4304) | IPsec | Extended Sequence Number (ESN) Addendum to IPsec DOI for ISAKMP | v3.17
| [RFC 4303](https://datatracker.ietf.org/doc/rfc4303) | IPsec | **IP Encapsulating Security Payload (ESP)** | v2.x | Obsoletes: [2406](https://datatracker.ietf.org/doc/rfc2406)
| [RFC 4302](https://datatracker.ietf.org/doc/rfc4302) | IPsec | **IP Authentication Header (AH)** | v2.x | Obsoletes: [2402](https://datatracker.ietf.org/doc/rfc2402)
| [RFC 4301](https://datatracker.ietf.org/doc/rfc4301) | IPsec | Security Architecture for the Internet Protocol | v2.x
| [RFC 4106](https://datatracker.ietf.org/doc/rfc4106) | IPsec | The Use of Galois/Counter Mode (GCM) in IPsec ESP | v3.17
| [RFC 3948](https://datatracker.ietf.org/doc/rfc3948) | IPsec | UDP Encapsulation of IPsec ESP Packets | v2.x
| [RFC 3686](https://datatracker.ietf.org/doc/rfc3686) | IPsec | Using Advanced Encryption Standard (AES) Counter Mode With IPsec Encapsulating Security Payload (ESP) | v
| [RFC 3602](https://datatracker.ietf.org/doc/rfc3602) | IPsec | The AES-CBC Cipher Algorithm and Its Use with IPsec | v2.x
| [RFC 3566](https://datatracker.ietf.org/doc/rfc3566) | IPsec | The AES-XCBC-MAC-96 Algorithm and Its Use With IPsec | v2.x
| [RFC 3526](https://datatracker.ietf.org/doc/rfc3526) | IKE | More Modular Exponential (MODP) Diffie-Hellman groups for Internet Key Exchange (IKE)
| [RFC 2451](https://datatracker.ietf.org/doc/rfc2451) | IPsec | The ESP CBC-Mode Cipher Algorithms | v2.x
| [RFC 2410](https://datatracker.ietf.org/doc/rfc2410) | IPsec | The NULL Encryption Algorithm and Its Use With IPsec | v2.x
| [RFC 2405](https://datatracker.ietf.org/doc/rfc2405) | IPsec | The ESP DES-CBC Cipher Algorithm With Explicit IV | v2.x
| [RFC 2404](https://datatracker.ietf.org/doc/rfc2404) | IPsec | The Use of HMAC-SHA-1-96 within ESP and AH | v2.x
| [RFC 2403](https://datatracker.ietf.org/doc/rfc2403) | IPsec | The Use of HMAC-MD5-96 within ESP and AH | v2.x
| [RFC 2104](https://datatracker.ietf.org/doc/rfc2104) | IKE | HMAC: Keyed-Hashing for Message Authentication | v2.x

### Active IPSECME Internet Drafts

_This table should track the "Active Internet-Drafts " section of the the IPSECME [documents](https://datatracker.ietf.org/wg/ipsecme/documents/) page._

| Standard | Area | Description | Status | Comments |
|----------|------|-------------|--------|----------|
| [draft](https://datatracker.ietf.org/doc/draft-ietf-ipsecme-ikev2-beet-mode) | IKE | IKEv2 negotiation for Bound End-to-End Tunnel (BEET) mode ESP
| [draft](https://datatracker.ietf.org/doc/draft-ietf-ipsecme-ikev2-reliable-transport) | IKE | Separate Transports for IKE and ESP
| [draft](https://datatracker.ietf.org/doc/draft-ietf-ipsecme-encrypted-esp-ping) | IPsec | Encrypted ESP Echo Protocol
| [draft](https://datatracker.ietf.org/doc/draft-ietf-ipsecme-child-pfs-info) | IKE | IKEv2 Support for Child SA PFS Policy Information | in-progress | paul
| [draft](https://datatracker.ietf.org/doc/draft-ietf-ipsecme-ikev2-prf-plus) | IKE | Use of Variable-Length Output Pseudo-Random Functions (PRFs) in the Internet Key Exchange Protocol Version 2 (IKEv2)
| [draft](https://datatracker.ietf.org/doc/draft-moskowitz-ipsecme-rfc7402-beet-update) | IPsec | A Bound End-to-End Tunnel (BEET) mode for ESP
| [draft](https://datatracker.ietf.org/doc/draft-ietf-ipsecme-ikev2-sa-ts-payloads-opt) | IKE | Optimized Rekeys in the Internet Key Exchange Protocol Version 2 (IKEv2) | in-progress | paul
| [draft](https://datatracker.ietf.org/doc/draft-ietf-ipsecme-hybrid-kem-ikev2-frodo) | IKE | Post-quantum Hybrid Key Exchange in IKEv2 with FrodoKEM
| [draft](https://datatracker.ietf.org/doc/draft-ietf-ipsecme-eesp) | IPsec | Enhanced Encapsulating Security Payload (EESP)
| [draft](https://datatracker.ietf.org/doc/draft-ietf-ipsecme-eesp-ikev2) | IKE | IKEv2 negotiation for Enhanced Encapsulating Security Payload (EESP)
| [draft](https://datatracker.ietf.org/doc/draft-ietf-ipsecme-esp-ping) | IPsec | ESP Echo Protocol
| [draft](https://datatracker.ietf.org/doc/draft-ietf-ipsecme-diet-esp) | IPsec | ESP Header Compression with Diet-ESP
| [draft](https://datatracker.ietf.org/doc/draft-ietf-ipsecme-ikev2-diet-esp-extension) | IKE | Internet Key Exchange version 2 (IKEv2) extension for Header Compression Profile (HCP)
| [draft](https://datatracker.ietf.org/doc/draft-ietf-ipsecme-sha3) | IKE | Use of SHA-3 in the Internet Key Exchange Protocol Version 2 (IKEv2) and IPsec

## RFCs from Other Working Groups and/or Sponsored by Area Directors

### IKEv2 Specific RFCs

| Standard | Area | Description | Status | Comments |
|----------|------|-------------|--------|----------|
| [RFC 7815](https://datatracker.ietf.org/doc/rfc7815) | IKE | Minimal Internet Key Exchange Version 2 (IKEv2) Initiator Implementation |  | This is a really just a subset of [RFC 7296](https://www.rfc-editor.org/info/rfc7296): Internet Key Exchange Protocol Version 2 (IKEv2)
| [RFC 7670](https://datatracker.ietf.org/doc/rfc7670) | IKE | Generic Raw Public-Key Support for IKEv2 | v3.26 | This defines the material used by [RFC 7427](https://www.rfc-editor.org/info/rfc7427): Signature Authentication in the Internet Key Exchange Version 2 (IKEv2)
| [RFC 7651](https://datatracker.ietf.org/doc/rfc7651) | | 3GPP IP Multimedia Subsystems (IMS) Option for the Internet Key Exchange Protocol Version 2 (IKEv2)
| [RFC 6954](https://datatracker.ietf.org/doc/rfc6954) | IKE | Using the Elliptic Curve Cryptography (ECC) Brainpool Curves for the Internet Key Exchange Protocol Version 2 (IKEv2)
| [RFC 6932](https://datatracker.ietf.org/doc/rfc6932) | | Brainpool Elliptic Curves for the IKE Group Description Registry

### EAP

| Standard | Area | Description | Status | Comments |
|----------|------|-------------|--------|----------|
| [RFC 9190](https://datatracker.ietf.org/doc/rfc9190) | EAP | EAP-TLS 1.3: Using the Extensible Authentication Protocol with TLS 1.3 | v4.7 | server only
| [RFC 5998](https://datatracker.ietf.org/doc/rfc5998) | EAP | An Extension for EAP-Only Authentication in IKEv2 | v4.7 | server only
| [RFC 5216](https://datatracker.ietf.org/doc/rfc5216) | EAP | The EAP-TLS Authentication Protocol | v4.7 | server only, Updated by [RFC 9190](https://datatracker.ietf.org/doc/rfc9190)
| [RFC 3748](https://datatracker.ietf.org/doc/rfc3748) | EAP | Extensible Authentication Protocol (EAP)
| [RFC 2716](https://datatracker.ietf.org/doc/rfc2716) | EAP | ~~PPP EAP TLS Authentication Protocol~~ | | Obsolete, see [RFC 5216](https://datatracker.ietf.org/doc/rfc5216)

### Certificates and PKIX

| Standard | Area | Description | Status | Comments |
|----------|------|-------------|--------|----------|
| [RFC 4945](https://datatracker.ietf.org/doc/rfc4945) | PKIX | The Internet IP Security PKI Profile of IKEv1/ISAKMP, IKEv2, and PKIX | v2.x | Changed to NSS in v3.14

### PF KEY V2

- FreeBSD and NetBSD implement a flavour of PF KEY v2 using the
  [KAME](https://www.kame.net/) code base as a starting point.

  OpenBSD's PF KEY v2's implementation does not.

- Linux, which implements XFRM, has borrowed concepts from PF KEY v2

| Standard | Area | Description | Status | Comments |
|----------|------|-------------|--------|----------|
| [RFC 2367](https://datatracker.ietf.org/doc/rfc2367) | PFKEYv2 | PF_KEY Key Management API, Version 2 | v4.7 | SADB messages to set up kernel state on BSD machines
| [draft-schilcher-mobike-pfkey-extension-01](https://datatracker.ietf.org/doc/draft-schilcher-mobike-pfkey-extension-01) | PFKEYv2 |MOBIKE Extensions for PF_KEY | v4.7 | also defines KAME's SPD extensions to set up kernel policy on BSD machine
| | PFKEYv2 | [PF_KEY Extensions for IPsec Policy Management in KAME Stack](https://www.kame.net/newsletter/20021210) | | Post to KAME mailing list about PF KEY

### Cryptography: AEAD, Public Keys (formats, standards, DNS records) ...

| Standard | Area | Description | Status | Comments |
|----------|------|-------------|--------|----------|
| [RFC 8813](https://datatracker.ietf.org/doc/rfc8813) | | Clarifications for Elliptic Curve Cryptography Subject Public Key Information
| [RFC 7468](https://datatracker.ietf.org/doc/rfc7468) | | Textual Encodings of PKIX, PKCS, and CMS Structures | v | `ipsec showhostkey --pem` outputs [Textual Encoding of Subject Public Key Info](href="https://datatracker.ietf.org/doc/rfc7468#section-13)
| [RFC 6605](https://datatracker.ietf.org/doc/rfc6605) | | Elliptic Curve Digital Signature Algorithm (DSA) for DNSSEC | | `ipsec --ipseckey` and `ipseckey --{left,right}` both dump ECDSA keys using the format described in [4. DNSKEY and RRSIG Resource Records for ECDSA](https://datatracker.ietf.org/doc/rfc6605#section-4)
| [RFC 5280](https://datatracker.ietf.org/doc/rfc5280) | | Internet X.509 Public Key Infrastructure Certificate and Certificate Revocation List (CRL) Profile | | See [4.1.2.7. Subject Public Key Info](https://datatracker.ietf.org/doc/rfc5280#section-4.1.2.7)
| [RFC 4648](https://datatracker.ietf.org/doc/rfc4648) | | The Base16, Base32, and Base64 Data Encodings | v | see `datatot()`
| [RFC 4034](https://datatracker.ietf.org/doc/rfc4034) | | Resource Records for the DNS Security Extensions
| [RFC 4025](https://datatracker.ietf.org/doc/rfc4025) | | A Method for Storing IPsec Keying Material in DNS | v | `ipsec showhostkey --ipseckey` outputs the text for an IPSECKEY RR record:<br/> Algorithm 1, DSA: [RFC 2536 2. DSA KEY Resource Records](https://datatracker.ietf.org/doc/rfc2536#section-2)<br/> Algorithm 2, RSA: [RFC 3110 2. RSA Public KEY Resource Records](https://datatracker.ietf.org/doc/rfc3110#section-2)<br/> Algorithm 3, ECDSA:[RFC 6605 4. DNSKEY and RRSIG Resource Records for ECDSA](https://datatracker.ietf.org/doc/rfc6605#section-4)<br/> Algorithm 4 will probably use [RFC 5280 4.1.2.7. Subject Public Key Info](https://datatracker.ietf.org/doc/rfc5280#section-4.1.2.7)
| [RFC 3110](https://datatracker.ietf.org/doc/rfc3110) | | RSA/SHA-1 SIGs and RSA KEYs in the Domain Name System (DNS) | v | `ipsec --ipseckey` and `ipseckey --{left,right}` dump RSA keys using the format described in [RFC 3112 2. RSA Public KEY Resource Records](https://datatracker.ietf.org/doc/rfc3110#section-2)
| [RFC 2536](https://datatracker.ietf.org/doc/rfc2536) | | DSA KEYs and SIGs in the Domain Name System (DNS) | | This won't be implemented.
| [RFC 1421](https://datatracker.ietf.org/doc/rfc1421) | | Privacy Enhancement for Internet Electronic Mail: Part I: Message Encryption and Authentication Procedures | | Origins of PEM format
| [draft-irtf-cfrg-aead-limits](https://datatracker.ietf.org/doc/draft-irtf-cfrg-aead-limits) | | Usage Limits on AEAD Algorithms | | Hopefully answers the question of what limits to place on AEAD.

### Obsolete IKEv1 RFCs

| Standard | Area | Description | Status | Comments |
|----------|------|-------------|--------|----------|
| [RFC 3947](https://datatracker.ietf.org/doc/3947) | IKEv1 | Negotiation of NAT-Traversal in the IKE | v | known as "NATT" or "ESPinUDP"
| [RFC 3706](https://datatracker.ietf.org/doc/rfc3706) | IKEv1 | A Traffic-Based Method of Detecting Dead Internet Key Exchange (IKE) Peers | v | known as "DPD"; IKEv2's equivalent is "liveness"
| [RFC 3526](https://datatracker.ietf.org/doc/rfc3526) | IKEv1 | More Modular Exponential (MODP) Diffie-Hellman groups | v
| [RFC 2409](http://datatracker.ietf.org/doc/rfc2409) | IKEv1 | **Internet Key Exchange (IKE)** | v | Revised Mode not implemented
| [RFC 2408](http://datatracker.ietf.org/doc/rfc2408) | IKEv1 | **Internet Security Association and Key Management Protocol (ISAKMP)** | v
| [RFC 2407](http://datatracker.ietf.org/doc/rfc2407) | IKEv1 | **IPsec Domain of Interpretation for ISAKMP (IPsec DoI)** | v
| [draft-dukes-ike-mode-cfg](http://datatracker.ietf.org/doc/draft-dukes-ike-mode-cfg) | MODECFG | The ISAKMP Configuration Method | v
| [draft-ietf-ipsec-isakmp-xauth](http://datatracker.ietf.org/doc/draft-ietf-ipsec-isakmp-xauth) | XAUTH | Extended Authentication within ISAKMP/Oakley (XAUTH) | v
| [draft-jenkins-ipsec-rekeying](http://datatracker.ietf.org/doc/draft-jenkins-ipsec-rekeying-06) | IKEv1 | IPsec Re-keying Issues | v | Implementation differs on some point but accomplishes the same
| [draft-ietf-ipsec-isakmp-hybrid-auth](http://datatracker.ietf.org/doc/draft-ietf-ipsec-isakmp-hybrid-auth) | IKEv1 | A Hybrid Authentication Mode for IKE | **X**
