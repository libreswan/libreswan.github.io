# Introduction

IPSec standards are produced and maintained by [Internet Engineering
Task Force](https://ietf.org/) which are implemented by many software
including Libreswan. [OpenIKED](https://www.openiked.org/) is one such
native implementation of [IKEv2](https://tools.ietf.org/html/rfc7296) on
OpenBSD. My project’s purpose is to enable Interop tests where one end
is Libreswan on Linux and the other is the native IKE daemon on OpenBSD.
This helps us test Linux kernel to BSD kernel and understand several
issues with Linux when inter-operating with with Non-Linux Operating
Systems.

# Implementation

The libreswan [KVM Testsuite](./Testing:-KVM) libvirt/qemu testing
system auto-installs Linux and then compiles libreswan on these
virtual machines. It then fires up these machines for individual tests
and verifies the expected results with reference output. The test
suite also supports strongswan on Linux. To add OpenBSD to this, the
following tasts we completed:

## Perform a Non-interactive OpenBSD Base installation

OpenBSD’s autoinstall only allows unattended installation by
automatically responding to installer questions with answers through a
response file
([auto_install.conf](https://man.openbsd.org/autoinstall.8)). But this
installation system is not fully working to complete the entire install
non-interactively. To solve this, a pexpect script using python was
written which adds install.conf to the OpenBSD installer image by
modifying the ISO image directly.

## Mounting the testing directory over NFS

The Libreswan’s testing system uses a 9P File System with Libvirt/Qemu
to mount the testing directory. Unfortunately, OpenBSD's 9P filesystem
was incompatibility with Linux and failed to work. It was therefor
decided to use NFS instead. This has a disadvantage that if the
openBSD's IPsec is not working properly, it could make the NFS mounts
unreachable to the host, and log files would be lost and the /testing
directory would fail to work during part of the test and cause the test
case to fail.

Using NFS for OpenBSD means that the Linux host operating system that
launches all the testing virtual machines also needed to be configured
as an NFS server.

## Cloning the base install image

To provide support for OpenBSD being a responder (like the linux "east"
machine) and being an initiator (like the linux "west" machine), after
the initial openbsd install, the base image is clone into "openbsde"
(OpenBSD East) and "openbsdw" (OpenBSD West) virtual machines. There was
some unexpected behaviour when the openbsd machines used the "east" or
"west" names in the individual tests, which is why the alternative names
are used. This also needed some support in the base testing setup
because until now, every test always had the machine "east" booted
first. Now this can be either "east" (linux) or openbsde (openbsd).

## Adding OpenBSD specific tests

Iniitally, two tests were created (interop-ikev2-openbbsd-01 and 02)
that perform a basic standard IKEv2 PSK based connection. One test has
openbsd initiating and one test has openbsd responding.

# Issues encountered

OpenBSD’s documentation is very scarce and incomplete. This caused a lot
of problems at the start of the project.

The 9P filesystems of Linux and OpenBSD turned out to be incompatible
and could not be made to work together. To mount the 9P File system on
OpenBSD, the Plan9port port package needs to be installed but this one
does not work with the 9P filesystem of Qemu. This is because Qemu's 9p
is not the same as Plan9port. Plan 9's 9p is 9p2000 which transports a
subset of plan 9 system calls over the network while Qemu's 9p is
9p2000.L and transports a subset of Linux system calls over the network.
Significant time was spend in attempting to make this work before
falling back to using NFS.

When the NFS server was up and running, the NFS mount were not working
initially on OpenBSD. After analysis of logs and network traces using
tcpdump, it became clear that Fedora’s firewall was blocking the
packets. Disabling the firewall made the NFS mount work as intended.
This was challenging as it was difficult to figure out whether the issue
was with OpenBSD or Linux - especially due to the lack of documentation
and lack of user experiences for OpenBSD. It seems most OpenBSD users
work only with OpenBSD machines, resulting in hardly any information or
documentation on interoperability with Linux.

# Possible Future Work

Additionals tests that cover a lot more features of the OpenBSD IKE
daemon should be added. X.509 certificates, ECDSA, IKE fragmentation are
examples of test cases that still need to be written.

See if FreeBSD can be added similarly to how OpenBSD has been added.

A separate project would be to port libreswan to OpenBSD natively and
then test interop of libreswan on Linux with libreswan on openbsd. While
libreswan was recently re-ported to NetBSD, it has not yet been
re-ported to OpenBSD of FreeBSD.

# Source code

The Source code for this project is merged into the main branch of
[Libreswan Repository](https://github.com/libreswan/libreswan) and will
be released with libreswan version 4.0. The commits associated with this
project are :

- [testing: Add OpenBSD support to the KVM testing
  infrastructure](https://github.com/libreswan/libreswan/commit/c8f24944ff34f023623fe6b3f1a313107827030e)
- [testing: added first Openbsd interop test
  interop-ikev2-openbsd-01](https://github.com/libreswan/libreswan/commit/5fad89ba87447bcdc27fbe432fbc37a5be2ce636)
- [testing: added interop-ikev2-openbsd-01 to
  TESTLIST](https://github.com/libreswan/libreswan/commit/90509ff3c0226700d58fbdd0e01ce91a84356f2e)

This project work was sponsored by Google as part of the [Google Summer
of Code](https://summerofcode.withgoogle.com/) 2020 Program. The
implementation for this project is done by [Ravi
Teja](https://github.com/RaviTejaCMS)(hello@rtcms.dev) under the
guidance of Paul Wouters, Tuomo Soini, and Andrew Cagney.

# License

This project is Licensed under [GNU General Public License
v2.0](https://github.com/libreswan/libreswan/blob/master/LICENSE).