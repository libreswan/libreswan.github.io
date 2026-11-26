<!-- file-is-title -->

# Libreswan Currently has No Projects for GSoC.

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
Page](/FAQ/History).

The Project Ideas listed below have been selected by Libreswan's core
developers with this evolution in mind.  They provide both a technical
challenge, and a way to participate in The Internet's development.
The mentors also have a personal interest in seeing these projects
through to completion.

If you see a project that looks interesting, or you just have
questions, then see the [Contributor
Guidance](/GSoC/2026/Contributor-Guidance-FINAL) for next steps.

It isn't a requirement at you pick one of the ideas below - we also
welcome new ideas.  For instance, additional draft RFCs that could
form the basis of a project can be found
[here](https://datatracker.ietf.org/wg/ipsecme/documents/))!

## Title Goes Here

**Required Skills:** C, UNIX programming, GIT

**Preferred Skills:** Network protocols, Cryptographic fundamentals,
RFC interpretation

**Libreswan Mentors:** 

**Project size:** Lower-Bound - Upper-Bound

We expect the proposal to specify the size and include that in the GSoC submition.

**Difficulty:** Easy-Upper Bound

**RFC Draft:** [If it applies](https://datatracker.ietf.org/doc/...)

### Description

Overview goes here ...

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

Guidance here can sometimes help.

