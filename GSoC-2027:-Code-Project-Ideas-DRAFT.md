[Libreswan](http://github.com/libreswan) is an [Internet Key
Exchange](https://www.rfc-editor.org/rfc/rfc7296.html) (IKE)
implementation that runs on Linux, FreeBSD, NetBSD
and OpenBSD.

While the original IKE and IPsec protocols were drafted in 1998, the
need to deal with an ever changing and increasingly hostile world,
drives the continuous evolution of these standards.  New features,
such as hybrid post-quantum key exchange, are being added; while old
features, such as support for weak cryptographic algorithms are been
removed.  For more background on Libreswan see the [History
Page](./FAQ:-History).

The Project Ideas listed below have been selected by Libreswan's core
developers with this evolution in mind.  They provide both a technical
challenge, and a way to participate in The Internet's development.
The mentors also have a personal interest in seeing these projects
through to completion.

If you see a project that looks interesting, or you just have
questions, then see the [Contributor
Guidance](./GSoC-2026:-Contributor-Guidance-FINAL) for next steps.

It isn't a requirement at you pick one of the ideas below - we also
welcome new ideas.  For instance, additional draft RFCs that could
form the basis of a project can be found
[here](https://datatracker.ietf.org/wg/ipsecme/documents/))!

## Use all exchanged messages when computing the authentication MAC

**Required Skills:** C, UNIX programming

**Preferred Skills:** Network protocols, Cryptographic fundamentals,
RFC interpretation, GIT

**Libreswan Mentors:** Andrew Cagney

**Project size:** 90 hours

**Difficulty:** Easy

**Draft RFC:** [Downgrade Prevention for the Internet Key Exchange
Protocol Version 2
(IKEv2)](https://datatracker.ietf.org/doc/draft-ietf-ipsecme-ikev2-downgrade-prevention)

### Description

IKEv2, when authenticating a peer, computes the MAC (message
authentication code) using only two of the four messages that have
been exchanged during the IKE negotiation.  This proposed RFC adds an
extension so that an authenticated peer uses all four of the exchanged
messages in the MAC calculation.

Please note that this is an internet standards draft.  Someone
implementing this might find issues with the draft protocol for which
they would need to communicate with the author of the draft to
resolve.

The deliverables are:

- addition to Libreswan's configuration (ipsec.conf), including
  documentation (ipsec.conf.8)

- modifications to negotiate the new mechanism

- modifications to (conditionally) compute the new MAC

- additions to the test-suite

The proposal should address each of these areas.

### Implementation

#### Add connection parameter `ike-sa-init-full-transcript-auth=...` to keywords

This should be boiler plate code adding the field to host_config in
connections.h et.al.

Functionality (minimum):

- auto - negotiate
- no - do not negotiate
- yes - require

Commits (minimum):

- keyword addition
- documentation addition
- addconn-NN- test demonstrating value reaching pluto

Exension: add additional keywords (no clue what) to specify

- propose, but choose NO regardless
- do not propose, but choose YES regardless

Idea: refactor code to use a generic table

- all negotiated notifications should have these values
- have repeated rfc=... or notification=... that accumulate notifications
- left/right?

#### Negotiate IKE_SA_INIT_FULL_TRANSCRIPT_AUTH

This should be boiler plate code adding the field state.h.

Commits (minimum):

- code implementing negotiation
- test, they should show:
  + result of negotiation in `ipsec showstate`? output
  + failed negotiation

Idea: follow-up above table so this is also generic

#### Modify IKE_SA_INIT to compute the new signed octets

Need to search these directions:

- inbound
- outbound

- initiator->responder
- responder->initiator

One code path contains extract_v2AUTH_blobs(), another contains
submit_v2_auth_signature().

PSK and PKI may also have different code paths

The code doing the calculation can already be found in
IKE_INTERMEDIATE.

Commits (minimal):

- code adding calculation when negotiated
- test demonstrating:
  + successful authentication
  + rejected authentication due to tampering (in both directions)

- if possible demo exchange with one alternative implementation

Either `impair` or extensions to config parameter may help here.

#### modify IKE_SESSION_RESUME paths to compute the new hash

The trick here is that the decision is determined by the resume blob.

Commits (minimal):

- save/restore decision
- compute hash
- tests demonstrating success/fail

#### here's a tentative patch for adding the fields

no clue if it works

```
diff --git a/programs/pluto/connections.h b/programs/pluto/connections.h
index 6871bb4280..d02b2d3fff 100644
--- a/programs/pluto/connections.h
+++ b/programs/pluto/connections.h
@@ -229,6 +229,8 @@ struct host_config {
                bool nm;                /* Network Manager support */
                bool split;
        } cisco;
+       /* See https://datatracker.ietf.org/doc/draft-ietf-ipsecme-ikev2-downgrade-prevention/ */
+       enum yna_options ike_sa_init_full_transcript_auth;
 };
 
 struct child_config {
diff --git a/programs/pluto/state.h b/programs/pluto/state.h
index b5ce735917..e5a70f2631 100644
--- a/programs/pluto/state.h
+++ b/programs/pluto/state.h
@@ -703,6 +703,7 @@ struct state {
        generalName_t *st_v1_requested_ca;      /* collected certificate requests */
        uint8_t st_reply_xchg;
        bool st_peer_wants_null;                /* We received IDr payload of type ID_NULL (and we allow auth=NULL / authby=NULL */
+       bool st_v2_ike_sa_init_full_transcript_auth_enabled;    /* See https://datatracker.ietf.org/doc/draft-ietf-ipsecme-ikev2-downgrade-prevention/ */
 
        /* IKEv2 IKE SA only */
        struct {
```


Loosely based on Shahrin Fatima's proposal.
