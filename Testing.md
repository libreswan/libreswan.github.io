## Nightly Test Tesults

Libreswan's testsuite is run nightly. The results are published
[here](https://testing.libreswan.org/), with the most recent result
[here](https://testing.libreswan.org/current). The tests are categorized
as:

- `good`: these tests are expected to pass
  <br>Unfortunately, some still have timing problems and occasionally fail; something to work on?
- `wip`: these tests require further work
  <br>For instance the result may not be deterministic, or the bug they demonstrate hasn't yet been fixed
- `skiptest`: these tests require manual intervention to run
  <br>For instance, a test requiring a custom NSS build.

To run tests locally, read on.

## Running tests

The libreswan tests, in testing/pluto, can be run using several
different mechanisms:

|Framework|[KVM](/KVM-Test-Framework)|[Namespaces](./Testing/Namespaces)|
|-|-|-|
|Full Test Run|Yes<br>Under 5 fails|No<br>100+ fails
|Individual Tests|Yes|Most
|Interop Testing|Yes<br/>Linux: strongSwan, Libreswan<br>FreeBSD: strongswan, Libreswan<br>NetBSD: racoon, racoon2, Libreswan<br>OpenBSD: iked, Libreswan|Limited<br>Linux: strongSwan, Libreswan
|Init System Testing|yes|no
|FIPS testing|yes|no
|Post-mortem<br>(core, memory leak, shutdown)|yes|support missing
|all.*.sh tests|yes|support missing
|Speed|slower|fast
|Host OS|Fedora, Debian|Linux (but a Fedora VM is strongly recommended)
|Notes|gold standard</b><br/>ideal for building on obscure platforms<br/>idea for testing custom kernels<br/>used by the [testing machine](https://testing.libreswan.org)<br/>requires 9p (virtio anyone?)|Creating a per-build Fedora VM is strongly recommended; and on iOS and Windows it is a requirement

## How tests work

Consider the test:

```
$ ls -1F testing/pluto/ikev2-05-basic-psk
description.txt   OUTPUT/
east.conf         west.conf
east.console.txt  west.console.txt
eastinit.sh       westinit.sh
east.secrets      westrun.sh
final.sh          west.secrets
```

which can be run using:
```
./kvm install # only once
./kvm check testing/pluto/ikev2-05-basic-psk
```
The following happens:

- the domains needed by the test are booted

  For a diagram of the test network, see [topology](/Testing/Topology).

- config files are installed

- each command from the `.sh` scripts is fed to the domain

  output from the commands are captured and saved in
  `OUTPUT/${HOSTNAME}.console.verbose.txt` and `OUTPUT/all.console.verbose.txt`

- post-mortem is performed

  See `testing/guest/bin/post-mortem.sh`.

- the captured output is sanitised, removing non-deterministic details

  The result is saved in `OUTPUT/${HOSTNAME}.console.txt`

- the reference (`${HOSTNAME}.console.txt`) and sanitised output is compared

  The result is saved in `OUTPUT/${HOSTNAME}.console.diff`

- the lack of differences, along with other checks, determine when a test passes

### Test Files

Each test case consists of a few files:

- `description.txt` to explain what this test case actually tests
- `ipsec.conf` files - for host west is called west.conf. This can also
  include configuration files for strongswan or racoon2 for interop
  testig
- `ipsec.secret` files - if non-default configurations are used. also uses
  the host syntax, eg west.secrets, east.secrets.
- `.sh` files containing the commands to run
- Known good (gold) output for each VM (eg `west.console.txt`,
  `east.console.txt`)
- `testparams.sh` if there are any non-default test parameters

### Commands to Run

The domains to use, and the scripts to run, are determined by the file names in the test directory.
There's several options.

#### Simple scripts: `nicinit.sh`, `eastinit.sh`, `westinit.sh`, `westrun.sh`, `final.sh` et.al.

_This is the original script structure and is used by most tests.
It turns out it isn't sufficient for robustly testing IKEv1's
three message Quick mode exchange._

Most often a test involves a simple interop
from a domain such as `west` to `east`.

For the above, the scripts are run in the order:

- `nicinit.sh`, `eastinit.sh`, `westinit.sh`
- `westrun.sh`
- `final.sh` - on all domains except `nic`

Technical nit: the scripts `nicinit.sh` then `eastinit.sh` are always run first, the others are ordered alphabetically.

#### Numbered scripts: `00-nic-init.sh`, `01-east-init.sh`, `02-west-init.sh`, `03-west-run.sh`, `04-east-up.sh`, `final.sh`

_This is the second attempt at script structure.
It should be used by IKEv1 tests._

Sometimes more complex sequences are required.  For instance:

- a test needing to initiate both ends (almost) simultaneously

- a test needing to confirm that the peer completed an operation

  for instance, that the responder processed the final IKEv1 Quick Mode packet

Scripts, matching `NN-*.sh` are run in lexicographic order of the files.
As a bonus, `final.sh` is also run on all test machines except `nic`.

#### Multi-platform: `all.netbsdwest-linuxeast.sh`

_This is the fourth script framework (the third attempt was removed).
It should be used when testing OS interops._

Sometimes tests need to run on different platforms (OS, ...).
For instance:, an interop between `NetBSD` and `Linux`.

These tests use a file matching `all.*.sh`.
The files name defines which hosts and platforms to use.
Each line of the file specifies where the command should be run.

For instance, the file `all.netbsdwest-linuxeast.sh` may contain: 

```
east# ipsec start
west# ipsec up
```

so `linuxeast` runs `ipsec start`, then `netbsdwest` runs `ipsec up`.

#### Draft: Multi-platform single test: all.east-west.sh, all.linuxeast-netbsdwest.txt, all.netbsdwest-linuxeast.txt

_This is is a proposal for a fifth script framework.  The testsuite has a growing list of tests which, other than the platforms they run between, are identical.  Currently this is achieved by generating the tests using scripts.  The proposal is to instead have a single test containing a reference output for each platform that the test should be run on._

## Adding A Test

There are several steps to adding a test:

- create, and populate, a new directory under `testing/pluto/`

  While copying a similar looks like a shortcut, it must be updated; here's a check list:
  + update `description.txt`
  + update `*.sh` files to use `ipsec ...` and not `ipsec auto --...`
  + update `{east,west,ipsec}.conf` removing any unnecessary fields

- add an entry to `testing/pluto/TESTLIST`

  + while the test is being developed it should be marked as `wip`

    A `wip` test can be run manually using `./kvm check testing/pluto/new-test`

  + once the test has become stable, change that to `good`

    All good tests are run by default with `./kvm check`;
    and we like to keep all good tests passing.

- the expected test output can be update using `./kvm patch testing/pluto/new-test`

  See also `./kvm modified`.

## Sanitizers

The raw output from each domain is sanitized (removing non-deterministic output such as NONCES and timers) before being compared to the expected output.

For instance, the raw output from `east` is written to `new-test/OUTPUT/east.console.verbose.txt`.  It is then sanitized creating `new-test/OUTPUT/east.console.txt` and finally it is compared against the reference output `new-test/east.console.txt`.

Occasionally new sanitizers need