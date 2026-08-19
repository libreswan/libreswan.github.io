# Introduction

The Intermediate Exchange, or IKE_INTERMEDIATE, is an addition to the
IKEv2 protocol to enable the use of quantum computer (QC) resistant
algorithms. It is expected that these algorithms require the transfer of
large amounts of data before the peers can complete a quantum safe
encryption and authentication. However, the IKE_SA_INIT exchange does
not allow fragmentation and thus cannot carry this additional data. And
the IKE_AUTH exchange already requires a working encryption algorithm.
The IETF draft proposal is to add support for an unlimited number of
INTERMEDIATE exchanges that take place between the IKE_SA_INIT and the
IKE_AUTH exchange. These new INTERMEDIATE exchanges enable message
fragmentation via the standard IKEv2 Fragmentation mechanism specified
in RFC 7383. All data required to setup a quantum safe encryption
algorithm can then be transferred before the IKE_AUTH exchange.

While the Intermediate Exchange was originally designed to support new
Quantum Safe algorithms, it can also be used for other large amounts of
data that might need to be exchanged. Another such example is the data
required for Remote Attestation of VPN clients before these are allowed
to connect to VPN servers and the remote network.

Both NIST and the IETF have not yet defined any quantum safe algorithms
to use. So any implementation of the intermediate exchange cannot yet
support any specific post-quantum algorithm.

The Intermediate Exchange draft document is available at
[draft-ietf-ipsecme-ikev2-intermediate](https://tools.ietf.org/html/draft-ietf-ipsecme-ikev2-intermediate-05).

# Implementation

To allow the use of Intermediate Exchange in libreswan, the following
modifications were made:

- The Early Code point allocations of the draft (value 43 for the new
  exchange type IKE_INTERMEDIATE, and the value 16438 for the new Notify
  payload INTERMEDIATE_EXCHANGE_SUPPORTED) were added.

<!-- -->

- Changes were made to the source files (programs/pluto/*ikev2_\*.c*)
  where IKEv2 is implemented. For now, only a single round of
  Intermediate Exchanges is supported.

<!-- -->

- New state transitions were added in programs/pluto/*ikev2.c* to
  support the Intermediate Exchange.

<!-- -->

- A new connection option **intermediate=yes** was added that allows or
  disallows the intermediate exchange. This option is mainly used for
  testing and might be removed later as the intermediate exchange has
  not exchanged any ID yet, it cannot be correctly mapped to one of many
  connections loaded. And thus, the intermediate exchange cannot be
  enabled or disabled as a per-connection option.

<!-- -->

- Test suite changes.

The current implementation successfully interoperated with Elvis Plus.

# Issues encountered

- Incorporating new exchange into existing implementation caused
  significant problems. As new state transitions were added, it caused
  some difficulties to ensure that the program flow is correct and the
  correct packets are used for the authentication.

<!-- -->

- The authentication of the intermediate exchange packets is very
  complicated. All packets must be hashed into a PRF for authenticating.
  Fragmented packets are encrypted separately. Thus, the PRF outcome
  would be different if one peer accepted the unfragmented or fragmented
  packet. Therefore, the current draft requires pulling only certain
  payloads from the packet to add to the PRF. To create an AUTH payload,
  and to verify the peer's AUTH payload, all these payloads have to used
  separately even after the packet has been sent (and received). This is
  very complicated to do with the libreswan code base.

# Future work

- Keep track of changes of the current draft and keep the code up to
  date with the latest draft (and finally with the RFC).

# Source code

This code was merged into libreswan 4.0

Code commit:
<https://github.com/libreswan/libreswan/commit/6b3b669ef08793ef7ea1a6b4e483d78bd5e97bfc>

Testing commit:
<https://github.com/libreswan/libreswan/commit/d609e4aaeabdb59d5df1c608cb45da565f380e4a>

The implementation for this project is done by Yulia Kuzovkova
(ukuzovkova@gmail.com) under the mentorship of Sahana Prasad and Paul
Wouters and sponsored by Google as part of Google Summer of Code 2020
Program.