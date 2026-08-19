Requirements to extend testing, test suite and tests themslef as of Fall
2017 =

## Test specifications

Test run scripts in the test directory and support single domain(guest
vm) test and multi-domain tests

#### single domain test


    <hostnamae>.sh

#### multi domain test

    00-<host name>.sh Each host that is part of this test need one of these. These scripts could run in parallel on each test host.
    nn-<host name>.sh will be executed serially on the  <host> ordered by <nn> or <nnn>.

### Output

#### Reference output:

#### verbose output

=

#### tcpdump output

=

#### gdb output

=

#### iptables

Ideally no iptables rules on the host. It could interfear with host xfrm
rules and may interfear with conntrack rules. Such rules shoild be on
the nic. This is deviation from the current model of east-west tests.
Where I think we see iptable influencing the tests.

### Installing libreswan

The testing could install libreswan in various ways. Each would support
a specific use case.

#### Install with "make install-base"

= This is the most simple one. It will be useful for automated test runs
ad developers to quickly test something.

#### Install using rpm

=

for e.g. "make kvm-rpm" can create appropriate rpm files from the git
repository for testing. These could be installed on each host.

The console output sanitizers are capable of distinguishing run from
/usr/local/libexec/ipsec or rpm installed location.

If is useful to test interoperatbility with older versions. In such case
you may want to able to specify rpm per host. So one or more host, say
east and west would run, with different rpm.

#### Some tests support its own Makefile.inc.local file

Then there is are odd tests which need specific compile time options set
or unset. For example DNSEC defined or not, AUDIT is enabled or not. One
solution that comes to mind is add a <host>.Makefile.inc.local in the
directory. If you see that then rebuild on this specific host. However
after the test run you may have rebuild the whole vm from clone image to
reset.

Possibly this could be hard to combine with rpms.

One way this could be supported is specify a custom rpm package.