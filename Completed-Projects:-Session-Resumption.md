## Introduction

[RFC 5723](https://tools.ietf.org/html/rfc5723) defines an extension to
IKEv2 (Internet Key Exchange v2) that allows a client to re-establish an
IKE Security Association with a gateway in a highly efficient manner,
utilizing a previously established IKE SA.

Resumption tickets solves the problem of re-establishing (many) IKE SAs
between IPSEC peers after a network failure at the end of a VPN gateway
which requires a lot of computational overhead, mostly in the
Diffie-Hellman claculations. The Session Resumption avoids these
expensive calculations.

## Implementation

To allow the use of Session Resumption in IKEv2, the following main
changes were made:

- Two new source code files were created:
  programs/pluto/ikev2_resume.{h,c} which defines the ticket by value
  structure and other helper functions for handling the session ticket.
- Added code in programs/pluto/ikev2_parent.c which deals with sending
  and processing of IKEv2 TICKET related Notify payloads.
- New state transitions were added in programs/pluto/ikev2.c to support
  the session Resumption Exchange.
- A new connection option **session-resumption=yes** was added that
  allows or disallows the session resumption.
- A new whack command was introduced which suspends a connection and
  delete states.

<!-- -->

    ipsec whack --suspend --name <connection name>

- The process of bringing a connection up was modified to check for a
  received resumption ticket. If available, it will automatically try
  Session Resumption.
- A new test case was added to test initiator and responder code for
  Session Resumption.

## Issues encountered

- The IKE_AUTH exchange following an IKE_SESSION_RESUMPTION exchange is
  slightly different from the regular IKE_AUTH exchange. A new kind of
  KDF was created as described by the RFC. Libreswan can be compiled
  using native KDF's or KDF functions from the NSS cryptographic
  library. Code was added for native KDF support, and the NSS developers
  were contacted about modifying the NSS crypto library to add this new
  Resumption KDF.

<!-- -->

- As the ticket does not have a fixed length and structure, it
  complicated receiving and parsing the ticket back on the responder
  side. After some discussion with other libreswan developers, this
  issue was resolved.

<!-- -->

- The RFC did not address the issue of what happens with Delete/Notify
  messages are sent. The document claims that tickets should not be
  re-used after the connection is deleted by either server or client,
  but is not clear that it should exclude connection deletions triggered
  by *liveness* probes. Since a network outage would otherwise cause the
  server to delete its resumption tickets during a brief outage, and
  this is exactly the scenario where a server would benefit from using
  resumption if lots of clients connect to the server at the same time
  when the network outage is resolved. This has been discussed at the
  *ietf* IPsec Working Group and might result in an ERRATA to be issued
  for the RFC.

## Current issues

- Code needs to be added to support connection instances, which
  typically happen for IKEv2 Exchanges with CP payloads (eg IKEv2 remote
  access clients). Once this support is added, interop testing can be
  done with ELVIS+
- The ikev2-resumption-01 test case is not completed, pending completion
  of the IKE_AUTH exchange modifications.
- The *suspend* command still needs to be modified to ensure it does not
  send Delete/Notify messages.

## Future Work

- For *ticket by value* resumption tickets, the ticket must be encrypted
  by the responder before sending it to initiator in order to protect
  the keys and other sensitive data present inside it. The responder
  would will need to keep two encryption keys covering the ticket
  lifetimes and needs to regenerate these encryption keys (for example
  every 8h). By using an AEAD like AES_GCM, the encryption is also
  authenticated.

<!-- -->

- Perform interop testing with ELVIS+

## Source Code

Main Code commit :
<https://github.com/murex971/libreswan/commit/4b0bdd0c0f019059fb8402079a8c3f76233620da>

Test commit :
<https://github.com/murex971/libreswan/commit/24b5ddb92881ebf50c9cf340f2328ce984c99308>

A few issues are still being addressed, so more commits will appear in
<https://github.com/murex971/libreswan>

The implementation of this feature is done by Nupur Agrawal
(nupur202000@gmail.com) under the mentorship of Paul Wouters, Sahana
Prasad and Tuomo Soini and sponsored by Google as part of Google Summer
of Code 2020 Program. The code is not merged yet as it is a POC (proof
of concept).