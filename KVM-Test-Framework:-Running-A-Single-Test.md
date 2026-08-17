There are two ways to run an individual test.  We'll refer to this as single-test mode.

### specify the test explicitly on the command line:

```
./kvm check testing/pluto/basic-pluto-01
```

`./kvm check basic-pluto-01` also works.

### run `./kvm` from the test directory in question

```
cd testing/pluto/basic-pluto-01
../../../kvm
../../../kvm diff
```

## Single-test mode skips post-mortem

In normal mode (i.e., running more than one test) `./kvm` performs
additional post-mortem steps as each test completes.  These steps
helps to flush out common problems such as core dumps and memory leaks
that often occur while `pluto` is shutting down.  The steps include:

- shutdown down pluto
- check for core files
- destroy the VMs

In single-test mode `./kvm` skips the post-mortem steps, and instead:

- leaves `pluto` running
- leaves the test domains running

This way, once the test has completed, it is possible to login, look
around, and even debug `pluto`.  Here's an example where `pluto` is
shutdown from the debugger:

```
./kvm sh east
east# ipsec status
east# gdb --pid $(pidof pluto)
(gdb) shell ipsec stop &
(gdb) continue
```

## Forcing post-mortem in single-test mode

To force post-mortem when running a single test, add `-pm` vis:

```
./kvm check -pm testing/pluto/basic-pluto-01
```

Alternatively, add

```
KVM_RUN_POST_MORTEM=true
```

to `Makefile.inc.local`.

_Think of having `./kvm` skip post-mortem in single-test mode as the least worst option._
