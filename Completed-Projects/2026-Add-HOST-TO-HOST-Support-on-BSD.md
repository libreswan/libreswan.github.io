# Google Summer of Code 2026 Final Report

## Student Information

- **Name:** Amrinder Singh ([@aamrindersingh](https://github.com/aamrindersingh))
- **Organization:** [The Libreswan Project](https://libreswan.org)
- **Project:** Add HOST-TO-HOST Support on BSD
- **Mentor:** Andrew Cagney

## Project Goals

Libreswan is an IPsec VPN implementation with a 25 year lineage, shipped in major Linux distributions. Its IKE daemon (pluto) also runs on FreeBSD, NetBSD and OpenBSD, but the simplest possible setup, two machines talking to each other over IPsec, did not work on any of them. The reason turned out to be almost funny: the encryption policies pluto installs were catching pluto's own negotiation packets. It could not finish setting up a connection because its own messages needed the connection that did not exist yet.

My job for the summer was to fix that on all three BSDs, add tests upstream so it stays fixed, and start closing the gap between the BSD kernel code and the Linux side, which gets far more attention.

Everything below is merged into libreswan main and ships with the regular releases. There is no separate branch.

## Merged Pull Requests

Full list: [all my merged PRs in libreswan](https://github.com/libreswan/libreswan/pulls?q=is%3Apr+author%3Aaamrindersingh+is%3Amerged). The story, in order:

The bypass fix, one platform at a time:

- [#2816](https://github.com/libreswan/libreswan/pull/2816) is the first real fix: on FreeBSD, pluto now pokes a policy hole for its own IKE socket, so its negotiation packets stop getting caught by the very policies it installs. Ships with the first host-to-host transport test, which fails without the fix and passes with it
- [#2867](https://github.com/libreswan/libreswan/pull/2867) ports the fix to NetBSD, same idea and mostly shared code since both stacks are KAME based. Also renames the test dirs per platform to make room for the rest of the family
- [#2892](https://github.com/libreswan/libreswan/pull/2892) does OpenBSD. Its IPsec stack is not KAME based, so this version lives in its own file and uses OpenBSD's socket options instead. With this one merged, host-to-host worked on all three BSDs

On-demand connections:

- [#2903](https://github.com/libreswan/libreswan/pull/2903) fixes the first on-demand bug I hit. On NetBSD an on-demand tunnel would negotiate fine and then die at the very last step: the outbound policy install used SADB_X_SPDADD while the trap policy still sat in that slot, so the kernel returned EEXIST and pluto tore the whole connection down. The fix picks SADB_X_SPDUPDATE when the routing state says a policy is already there

Tests:

- [#2901](https://github.com/libreswan/libreswan/pull/2901) adds IPv6 host-to-host tunnel tests for the three BSDs, so tunnel mode is covered next to transport mode
- [#2932](https://github.com/libreswan/libreswan/pull/2932) replaces the hand-written tests with a generator script that produces the whole host-to-host family, moves the tests to the east/west topology so the rise/set hosts are free to act as end hosts, and adds the missing linux variants
- [#2939](https://github.com/libreswan/libreswan/pull/2939) uses that freedom: the forward tests, where end host rise pings end host set through the east=west tunnel, on all four platforms. Real forwarded traffic through the tunnel, something the test suite had never covered. These tests also answer an open question: on Linux the forwarded packet passes through the extra "forward" kernel policy Linux installs, the BSDs have no such thing and forward fine without one

## Current Status and Future Work

Host-to-host transport (IPv4), host-to-host tunnel (IPv6) and subnet-to-subnet tunnel with forwarded end-host traffic (IPv4) work and are tested on FreeBSD, NetBSD, OpenBSD and Linux.

Still in progress:

- an on-demand test family (host-to-host-{transport,tunnel}-ondemand per platform) replacing the old pfkeyv2-ondemand pair. This will be the first time the ACQUIRE path runs on FreeBSD and OpenBSD at all, so it will probably surface new bugs, which is the point
- acquire combined with ipsec-interface (IPv4 only)

## Challenges Faced and Lessons Learned

- Most of my time went into research, not code. The actual fixes are small, knowing which five lines to change is the work. Three kernels I had never touched before meant a lot of reading, a lot of tcpdump, and a lot of waiting for VMs to boot
- The PFKEYv2 interface is specified in an RFC from 1998 that is marked informational and was never updated. It also never covered policy management at all, so each kernel invented its own private extensions for that half of the job, all different. The real documentation is the kernel source. All three of them
- "BSD" is not one operating system. FreeBSD and NetBSD share the KAME IPsec stack and mostly took the same fix. Then OpenBSD turned out to have rewritten its whole IPsec stack years ago, so the third port of a shared fix became a separate implementation in its own file. I now check which BSD before saying BSD
- Test topology can lie to you. The two end hosts in the forward tests also share a private back network, so if you ping the wrong address of the same machine, the packet goes over that wire and your tunnel test passes without ever using the tunnel. Caught before it shipped, remembered forever
- Rebuilding pluto in the test VMs does not refresh the VM configuration itself. I spent a day chasing a routing failure through my own test when the real problem was a stale VM image missing a month old upstream change
- Write down what you verify even when there is nothing to fix. When my mentor noticed traceroute goes silent at the far gateway of a tunnel, I chased it with tcpdump on all four platforms: expected behaviour on every one of them, for two different reasons, now documented instead of being a mystery for the next person

## Acknowledgments

Thanks to Andrew Cagney for the weekly calls, the honest reviews, and for trying to break my tests before merging them
