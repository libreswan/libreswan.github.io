Please go to [Google Summer of
Code](https://github.com/libreswan/libreswan/blob/main/docs/GSoC.md)

**Previous Student projects**

See [Student projects](./Completed-Projects) for completed student
projects (sponsored by GSoC and others).

**Proposal submissions**

Submissions must comply to all GSoC rules. We strongly urge any
interested students to read up on the previous student projects and the
below project ideas. It is not required to big one of these ideas - we
welcome new ideas too! Submissions that tend to be accepted and
successful are those that show from the start that the student is
putting in the time to understand the concepts. You don't have to be an
expert already, and you can contact us at gsoc at libreswan dot org for
questions. Mentors like to see students that have put in some work to
understand and try things. It is the only reliable metric we have for
new people to indicate how serious they are to take on a project for the
summer. If implementing an RFC, read the RFC and ask us any questions
you have. Have a look at the code base structure in general, look at our
testing/ directory. If you don't have VPN/IPsec experience, we are happy
to give you a client configuration to gain experience using libreswan to
a real VPN server.

**Google Summer of Code Ideas Page**

While IKE and IPsec have been around for almost 20 years, like
SSL/TLS, the protocols are still evolving and getting new features to
deal with an ever changing world. The Libreswan Project's core
developers have come up with a list of projects that they believe
would be interesting for students to work on. The mentors have a
personal interest in these projects as well. If any of these projects
look interesting to you, feel free to contact the developers either on
the [developer
mailinglist](https://lists.libreswan.org/mailman3/lists/swan-dev.lists.libreswan.org/)
or the **\#libreswan** channel on the **LiberaChat IRC** network. You
can also email **gsoc@libreswan.org** with any questions you have or
if you would like to introduce yourself.

A quick overview and history of The Libreswan Project was presented by
Paul Wouters as part of the Opportunistic IPsec presentation at the
[2016 Linux Security
Summit](http://events.linuxfoundation.org/events/linux-security-summit)
and there is a [video
recording](https://www.youtube.com/watch?v=Me_rl6N1m7c&list=PLbzoR-pLrL6pq6qCHZUuhbXsTsyz1N1c0&index=17)
of the presentation.

# Implement varlink status reporter

**Required Skills:** C programming, writing documentation and test cases

**Libreswan Mentors:** Paul Wouters, Tuomo Soini

**Project size** 350 hours

**Difficulty** Medium

**Description**

There is a demand to monitor for status changes and reconfiguration
commands using a [varlink](https://varlink.org/) API. The varlink API is
kind of like a successor to dbus. It would replace the ipsec whack
command that is too expensive to fire up all the time. The whack command
is also a "pull" method whereas the varlink API will be a push method to
anyone who wants (and is allowed) to listen on the right channel.

Additionally, another varlink channel will be used to send commands to
the daemon, which are currently done by the ipsec whack command (or if
configurations are used, via ipsec addconn into whack commands). The
idea here is that varlink is an existing channel where anyone (with
permission) can send commands to the pluto daemon (add connection, up
connection, down connection, etc)

The student is expected to first get an idea of what is involved in
adding and bringing up a VPN tunnel. Then the "status channel" needs to
be defined for varlink messages, and then the pluto code needs to be
updated to send varlink status messages over this channel.

The "ipsec whack --status" command should then be rewritten to use the
new varlink channel and provide the status information.

Once that is working, the command channel can be specified for varlink
for per connection commands (add,up,down,delete,status). This would
replace the "ipsec whack --name connection" code and within the pluto
daemon, the responses would go to the varlink channel instead of the
regular whack fd.

If there is enough time, whack commands that work on the global daemon
state, and not on a single connection, can be implemented as well.

The deliverable would be a varlink enabled libreswan pluto daemon and a
varlink enabled ipsec whack command.

# Implement static IP assignments and support for Radius / AAA backend

**Required Skills:** C programming, writing documentation and test cases

**Libreswan Mentors:** Paul Wouters, Tuomo Soini

**Project size** 170 hours

**Difficulty** Easy to Medium

**Description**

Currently, the libreswan pluto IKE daemon can only use a builtin
addresspool= range. There is demand for handing out static leases for
specific users. A new file similar to ipsec.secrets should be supported
that contains a list of IDs and IP addresses to hand out. This should
override the regular addresspool= IP allocation.

This solution does not scale very well though and is not compatible with
common IP address requests via protocols such as Radius or Diameter. For
the second part of this project, the student implements a call to ask a
Radius/Diameter server for an IP address based on the received IKE ID.
This solution replaces the addresspool= support entrely.

The deliverable would be two methods for assigning static IP addresses
in the libreswan pluto daemon to connecting clients.

# Improve the ACQUIRE to IKE policy lookup by making use of the reqid

**Required Skills:** C programming, RFC interpretation

**Libreswan Mentors:** Paul Wouters, Tuomo Soini

**Project size** 170 hours

**Difficulty** Easy to Medium

**Description**

IPsec policies can be installed in the kernel to be "on demand". Once a
packet hits the IPsec subsystem, if it matches a %trap policy, the
userland IKE daemon is informed about this so it can initiate an IKE
connection to the target destination. Currently, all the installed %trap
policies use a "reqid" number of 0. This means that when the IKE daemon
receives the message from the kernel, it has to do its own source/dest
based lookup to determine which connection got triggered. The goal of
this project is to change this by using unique reqid numbers for each
connection with a %trap policy. The complication arises from connections
with %trap policies that are part of a group. These connections clone
themselves into new connections. The clones cannot have the same reqid,
so these policies need to be modified before being resend to the kernel.
While the coding is likely to be straightforward, getting to understand
the connection structure and kernel structures involved will be the
harder part.

The deliverable is a pluto daemon that sends and receives unique reqids
from kernel messages and that uses these reqids for its connection
matching mechanism.

# Implement Announcing Supported Authentication Methods in IKEv2

**Required Skills:** BSD networking, C, shell scripting, RFC
interpretation

**Libreswan Mentors:** Andrew Cagney, Paul Wouters

**Project size** 170 hours

**Difficulty** Easy

**Description**

Implement the IKEv2 extension for multiple supported authentication
modesls, see
<https://tools.ietf.org/html/draft-smyslov-ipsecme-ikev2-auth-announce>

Currently, both peers will present their authentication method
independently. These authentication methods might not be the same.
Depending on the received authentication method support received from
the peer, adjust the authentication if multiple are supported.
Additionally, if the authentication method uses certificates, filter the
allowed authentication methods based on the algorithms used in the
certificate chain. The internet standards draft is still in the early
stage of discussion at the IETF, so someone implementing this might find
issues with the draft protocol for which they would need to communicate
with the author of the draft to resolve.

# Extend MOBIKE support to allow it to be used as server failover mechanism

**Required Skills:** BSD networking, C, shell scripting, RFC
interpretation

**Libreswan Mentors:** Andrew Cagney, Paul Wouters

**Project size** 350 hours

**Difficulty** Hard

**Description**

See [RFC 4555](https://tools.ietf.org/html/rfc4555) and
<https://www.ietf.org/mail-archive/web/ipsec/current/msg11844.html> on
details of how this should work. The reason this project is marked as
hard is that there is a lot of userland \<-\> kernel communciation and
changes that need to be sync'ed between the kernel and the userland
states.

The deliverable would be a pluto daemon that can generate and respond to
MOBIKE requests and a few test cases to show the failover procedure.

# Support for RFC 6290: Quick Crash Recovery

**Required Skills:** BSD networking, C, shell scripting, RFC
interpretation

**Libreswan Mentors:** Andrew Cagney, Paul Wouters

**Project size** 170 hours

**Difficulty** Easy

**Description**

Add support for [RFC 6290](https://tools.ietf.org/html/rfc6290).

This document describes an extension to the Internet Key Exchange
Protocol version 2 (IKEv2) that allows for faster detection of Security
Association (SA) desynchronization using a saved token.

When an IPsec tunnel between two IKEv2 peers is disconnected due to a
restart of one peer, it can take as much as several minutes for the
other peer to discover that the reboot has occurred, thus delaying
recovery. In this text, we propose an extension to the protocol that
allows for recovery immediately following the restart.

This RFC might not be enough for the entire GSoC period. If done early,
the student is expected to start work on another small RFC.

The deliverable is a test case that demonstrates the implemented RFC is
working properly.

# Support for RFC 7670: Generic Raw public key support

**Required Skills:** BSD networking, C, shell scripting, RFC
interpretation

**Libreswan Mentors:** Andrew Cagney, Tuomo Soini

**Project size** 350 hours

**Difficulty** Hard

**Description**

Add support for [RFC 7670](https://tools.ietf.org/html/rfc7670).

The Internet Key Exchange Version 2 (IKEv2) protocol did have support
for raw public keys, but it only supported RSA raw public keys. In
constrained environments, it is useful to make use of other types of
public keys, such as those based on Elliptic Curve Cryptography.

# Extend Libreswan's support for FreeBSD

**Required Skills:** BSD networking, C, kernel coding, python, shell
scripting

**Libreswan Mentors**: Andrew Cagney

**Project size** 170 hours

**Difficulty** Medium

**Description**

The goal of this project is to extend Libreswan's support for FreeBSD
adding missing functionality and tests.

The deliverable are:

- a gap analysis to identify Libreswan features missing on FreeBSD
- modifications to Libreswan adding at least two missing features
- testsuite additions demonstrating the added features

# Re-port the libreswan code for Microsoft Windows

**Required Skills:** Windows / PowerShell, C, python, shell scripting

**Libreswan Mentors**: Andrew Cagney, Antony Antony

**Project size** 350 hours

**Difficulty** Medium - Hard

**Description**

Re-add the Windows IPsec stack support in libreswan using the Windows
"native" powershell ipsec commands, such as Set-VpnServerConfiguration
and Set-VpnServerIPsecConfiguration. While the libreswan developers have
used Windows, they are not experts in Windows and the student will have
to work fairly indepdently in finding out how to drive the powershell
commands from a libreswan Windows binary.

The deliverable is a compile of libreswan that can be used to setup VPN
connections that runs on Windows

# Cleanup / maintenance / code deduplication

**Required Skills:** Windows / PowerShell, C, python, shell scripting

**Libreswan Mentors**: Tuomo Soini, Paul Wouters

**Project size** 170 hours

**Difficulty** Easy

**Description**

Everyone wants features, no one wants maintenance :)

The codebase has too many comments that point to an issue needing
maintenance in some way. A code rewrite, a corner case handling, an
oddity. A pointer to code duplication. Refactoring long functions.

This could combine with better splitting IKEv1 and IKEv2 code, so that
ikev1 can be not compiled in for the future (via a new
USE_IKEv1=true\|false compile time option)

Similarly, a code cleanup could be started to remove KLIPS support (but
not PF_KEY support)

The deliverable here are a number of commits that clean up various items
in our code base

# Implement IKEv2 Group Key Management

\[ this project is not ready yet, as the draft has not seen much
development lately \]

Add Group Key Management as per
<https://tools.ietf.org/html/draft-ietf-ipsecme-g-ikev2>

# Use of a VPNonly namespace

**Required Skills:** systemd, kernel name-spaces, podman/toolbox, C,
python, shell scripting

**Libreswan Mentors**: Tuomo Soini, Paul Wouters

**Project size** 350 hours

**Difficulty** Hard

**Description**

A fedora or debian/ubuntu based proof of concept to run applications in
a VPNonly namespace, which only allows those applications network access
if a VPN connection is up. This will use the new XFRMi interface ipsecX.

Some gnome based interaction to mark applications VPNonly. For example,
only allow firefox and thunderbird to send traffic via VPN, not outside
VPN.

This idea requires some brainstorming and coming up with an architecture
that works to support these kind of namespace handlings. This project
requires a lot of independent thinking of the student, and a wide
generic knowledge of Linux on the dekstop and a lot of knowledge on
systemd and virtualization.

The deliverable is a Linux desktop where an application such as firefox
can be started in a vpnonly namespace.

# Implement the INTERNAL_DNSSEC_TA support

\[ project currently not available \]

See <https://tools.ietf.org/html/draft-ietf-ipsecme-split-dns-16>

# Integrate libreswan into OSS-Fuzz project

**Required Skills:** C, code reading

**Libreswan Mentors**: Tuomo Soini, Paul Wouters

**Project size** 350 hours

**Difficulty** Hard

**Description**

[OSS-Fuzz](https://google.github.io/oss-fuzz/) is Google's project for
fuzz testing the code of various open source projects. In order to
integrate libreswan into OSS-Fuzz, one should first identify the
potential pieces of code that would be suitable and desirable for fuzz
testing. Then the fuzzing targets for the identified code should be
implemented. Final step would be to request admission of libreswan to
OSS-Fuzz and fulfill (implement) the requirements of OSS-Fuzz project.

More about fuzz testing, fuzzing engines and OSS-Fuzz can be found on
OSS-Fuzz project page.

There are some related open source projects that can be used as an
example of successful project integration into OSS-Fuzz, e.g.:

\- strongswan: [project section on
OSS-Fuzz](https://github.com/google/oss-fuzz/tree/master/projects/strongswan)
and [fuzzing
targets](https://github.com/strongswan/strongswan/tree/master/fuzz).

\- Mozilla's NSS: [project section on
OSS-Fuzz](https://github.com/google/oss-fuzz/tree/master/projects/nss)
and [fuzzing targets](https://github.com/nss-dev/nss/tree/master/fuzz).

The deliverable is a test case inside the libreswan testing
infrastructure that runs a number of fuzzing tests.