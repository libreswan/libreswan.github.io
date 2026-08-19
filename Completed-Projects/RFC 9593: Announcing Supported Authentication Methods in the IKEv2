## Student Information

- **Name:** Osema Fadhel ([@OsemaFadhel](https://github.com/OsemaFadhel))
- **Project:** [Add Support For Announcing Authentication Methods To Libreswan](https://summerofcode.withgoogle.com/programs/2026/projects/vT6e1MsJ)
- **Mentor:** Vukašin Karadžić

## Introduction

During an IKEv2 negotiation, each peer independently selects its authentication method without knowing what the other side actually supports, which can lead to the IKE SA establishment failures when peers are configured with multiple credentials. The goal of this project is to implement RFC 9593, which introduces the SUPPORTED_AUTH_METHODS notification: each peer can announce its supported authentication methods during the IKE SA establishment, enabling Libreswan to adjust its authentication selection to a method both sides support. 

## Implementation

To make Libreswan RFC 9593 compliant, the following items have been
implemented:

1\. Extending authby struct

authby struct had one bit for rsasig and one for ecdsa; the specific hash (SHA2-256/384/512) was tracked separately in sighash_policy. With more than one allowed simultaneously (e.g. authby=rsa-sha2_256, ecdsa-sha2_512), authby only has rsasig and ecdsa set while sighash_policy only has SHA2-256 and SHA2-512 bits set, losing the pairing between algorithm and hash. To fix this, individual fields were added to struct authby for each concrete method (e.g., rsasig-sha2_256, ecdsa-sha2_512).

2\. send-supported-auth-methods Option

Added the send-supported-auth-methods option to decide whether or not to send the notification.

3\. SUPPORTED_AUTH_METHODS Notification

Notify payload of type SUPPORTED_AUTH_METHODS is sent inside the IKE_SA_INIT response and IKE_AUTH request. 
The supported authentication methods (e.g., RSA DIGITAL SIGNATURE, ECDSA-521 (11) or Digital Signature (14)) are exchanged by the initiator and responder in this notify payload. 
The receiving party may take this information into consideration when selecting an algorithm for its authentication (i.e., the algorithm used for calculation of the AUTH payload) if several alternatives are available.  
The decision of whether Libreswan sends the SUPPORTED_AUTH_METHODS notification is based on the send-supported-auth-methods option configured in ipsec.conf. 

4\. Test Suite changes

The Test Suite was extended by adding test cases to verify feature
functionality.

## Issues encountered

- Only one certificate can be configured per connection end (left/rightcert=). So even once the peer's supported authentication methods are known via the notification, Libreswan has no way to dynamically pick the right certificate for whichever method gets negotiated

## Future work

- Support multiple certificates, so Libreswan can load the right cert dynamically once the negotiated method is known

- Track the ordered list of CAs sent in the CERTREQ payload at the point each SUPPORTED_AUTH_METHODS announcement is built, so the Cert Link field in that announcement can be set to the real index of the trust anchor the method applies to, instead of always being sent as 0 ("any CA"). [RFC 9593 reference](https://datatracker.ietf.org/doc/html/rfc9593#name-3-octet-announcement:~:text=%C2%B6-,Cert%20Link%3A,%C2%B6,-This%20format%20is)

## Source code

Merged Pull Requests in order:

- [2842 - Extend struct authby to contain rsasig_sha2 and ecdsa_sha2 fields ](https://github.com/libreswan/libreswan/pull/2842)

- [2967 - Add send-supported-auth-methods option](https://github.com/libreswan/libreswan/pull/2967)

- [2968 - Generate certificates for SUPPORTED_AUTH_METHODS tests](https://github.com/libreswan/libreswan/pull/2968)

- [2950 - Add support for announcing supported authentication methods](https://github.com/libreswan/libreswan/pull/2950)

## Acknowledgments

I want to thank Vukašin for the continuous mentoring and the weekly calls reviewing and supporting the work. Thanks also to Andrew for the reviews and for always being available to answer questions.

This project work was sponsored by Google as part of the Google Summer
of Code 2026 Program. The implementation for this project is done by
Osema Fadhel (osemafadhel01@gmail.com) under the mentorship of Vukašin Karadžić.
