It's assumed that the test `basic-pluto-01` is is causing problems on
`east`.

_First, check that `Makefile.inc.local` **does not** contain
`KVM_RUN_POST_MORTEM=true`.  If it does, `./kvm` will shutdown `pluto`
and destroy the VMs._

## Core Dump During A Test

Run the test, then login and use GDB to examine the core dump:

```
./kvm install # only when a re-build is needed
./kvm check testing/pluto/basic-pluto-01`
./kvm sh east
east# gdb --core /tmp/core.pluto.NNN
(gdb) bt
(gdb) list
(gdb) up
(gdb) up
(gdb) list
(gdb) print variable
```

## Core Dump During Shutdown

Run the test, then login and attach to the running `pluto` process
using GDB.  Then, from the debugger, run the shutdown command in the
background:

```
./kvm install # only when a re-build is needed
./kvm check testing/pluto/basic-pluto-01`
./kvm sh east
east# gdb --args /usr/local/libexec/ipsec/pluto $(pidof pluto)
(gdb) shell ipsec shutdown &   # run command in background
(gdb) continue                 # let pluto process request
... crash happens ...
(gdb) bt
```

**Note the `&`. This causes `ipsec shutdown` to be run in the
background.**

## Disabling `systemd`'s watchdog timer

For more longer debugging sessions, where `pluto` may be paused while
you're pokeing around with the debugger, `systemd`'s watchdog timer
will need to be.  Otherwise it will fire, killing pluto.

### Temporarily disable `systemd`'s watchdog timer

First boot the test domains used by the test `basic-pluto-01`

```
./kvm boot testing/pluto/basic-pluto-01
```

Next modify `ipsec.service` so that the watchdog timer is disabled:

```
./kvm sh east
east# sed -i -e '/WatchdogSec=/ s/^/#/' /usr/lib/systemd/system/ipsec.service
```

Now the tests can be run manually using `east` and `west`'s consoles:

```
east# cd /testing/basic-pluto-01
east# ./eastinit.sh
east# gdb --args /usr/local/libexec/ipsec/pluto $(pidof pluto)
(gdb) continue
....
```

```
./kvm sh west
east# cd /testing/basic-pluto-01
east# ./westinit.sh
east# ./westrun.sh
```

**Note: because the test domains are transient, shutting down and then
  booting will loose this change.**

### Permanently disable `systemd`'s watchdog timer

`systemd`'s watchdog timer can be permanently disabled in the KVM
build by adding `KVM_USE_SYSTEMD_WATCHDOG=false` to
`Makefile.inc.local`.

## Interactively Debugging A Test

This time both `east` and `west` are used.  And pluto is started
manually (not via systemd).  Two terminals are required.

In the first terminal get pluto started on `east` with `connection`
loaded.  Notice how `ipsec add connection` is invoked by momentarily
halting pluto, running the command in the background, and then
continuing pluto:

```
./kvm install # only when a re-build is needed
```

```
./kvm sh east
east# /testing/guestbin/swan-prep ...
east# gdb --args /usr/local/libexec/ipsec/pluto --nofork --config /etc/ipsec.conf --stderrlog  --log-no-time
(gdb) run
^C
(gdb) shell ipsec add connection &
(gdb) continue
```

Next, in the second terminal, start pluto on west, load and then
initiate `connection`:

```
./kvm sh west
west# /testing/guestbin/swan-prep ...
west# gdb --args /usr/local/libexec/ipsec/pluto --nofork --config /etc/ipsec.conf --stderrlog  --log-no-time
(gdb) run
^C
(gdb) shell ipsec add connection &
(gdb) continue
^C
(gdb) shell ipsec up connection &
(gdb) continue
...crash...
```

## Finally

Once things seem to be fixed, be sure to run the test from scratch,
including post-mortem:

```
./kvm install check -pm testing/pluto/basic-pluto-01
```
