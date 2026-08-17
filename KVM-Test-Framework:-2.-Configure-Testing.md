The KVM test framework, with a bit of tweaking, supports having
multiple source trees, each running tests independently.

## TL;DR?

Try running:

```
./kvm install check testing/pluto/ikev2-05-psk
```

It will use a very simple configuration; but is likely sufficient for
running one or two tests manually.

## Create Makefile.inc.local

`Make` variables set in the file `Makefile.inc.local` control how KVM
is configured to run tests.

If you haven't already, create a local clone of libreswan:

```
git clone https://github.com/libreswan/libreswan
cd libreswan
```

and create an empty `Makefile.inc.local`:

```
touch Makefile.inc.local
```

(packaging systems should not use this, and instead explicitly pass
the make variables to the make command)

## Create `$(KVM_POOLDIR)` for storing VM disk images

The pool directory is used used to store:

- common objects such as

  + install CD/DVD images
  + downloaded packages for installation into the VMs

  that can be shared between test setups

- per test VM specific objects such as:

  + VM disk images
  + scratch files

The directory can get large.  It can and should be shared between build
trees (this reflects libvirt which has a single name space for
domains).

The default is `../pool`.  i.e., adjacent
to your source tree. It will need to be created:

```
cd libreswan
mkdir -p ../pool
```

To change the pool directories location, set `$(KVM_POOLDIR)`
in `Makefile.inc.local`.

## Configure $(KVM_PREFIX) to allow allow multiple build trees on a machine

Optional, but highly recommended.

By default the domains and networks are assigned names such as linux,
east, 198_18_1, et.al..  The problem is that these names are not
unique between build trees, and as a result, all build trees try to
use the same domains and networks.

The "fix" is to set `$(KVM_PREFIX)` to a unique (but short) value in `Makefile.inc.local`
in each build tree.  All test specific files will then use that as a prefix, vis:

```
$ cat libreswan-alpha/Makefile.inc.local
KVM_PREFIX=a.
$ cat libreswan-beta/Makefile.inc.local
KVM_PREFIX=b.
```

The first build tree `libreswan-alpha` will use the prefix `a.`, for instance `a.linux`;
and the second build tree `libreswan-beta` will use `b.linux` et.al.

For convenience, commands such as:

```
libreswan-a$ ./kvm sh linux
```

will log into the current build tree's domain (here a.linux).

Note: due to limitations in the network stack (interfaces have a limit
of 16 characters) (the prefix needs to be really short).

## Configure `$(KVM_$(PLATFORM))` to enable additional Platforms

By default, `./kvm` builds and tests using a generic Linux platform
(it just happens to be Fedora).

Normally this is sufficient.

To help fix build problems, aid BSD development, and performing more complex interop tests, the following additional platforms are available:

| Make Variable | Runs | Main Use |
|---------------|------|----------|
| KVM_APLINE    | Latest 32-bit Alpine | Building 32-bit <br> Building against MUSL libc
| KVM_DEBIAN    | Debian 64-bit LTS, as old as possible | Trailing edge builds (for instance, acient NSS) <br/> Trailing edge linux kernel
| KVM_FREEBSD   | Latest 64-bit FreeBSD | Building (`clang`) <br/> Interop testing with strongSwan
| KVM_FEDORA    | Latest 64-bit Fedora release | Bleading edge builds <br/> Leading edge linux kernel
| KVM_LINUX     | Generic Linux | **Enabled by Default** <br/> Generic Testing (the linux flavour happens to be Fedora)
| KVM_OPENBSD   | Latest 64-bit | Building (`clang`) <br/> Interop testing with `iked`
| KVM_NETBSD    | Latest 64-bit | Building (`gcc`) <br/> Interop testing with `racoon` and `racoon2`

To include these additional platforms in the defaults when building and testing, set the corresponding Make variable to `true` in `Makefile.inc.local`.  For instance,
```
KVM_NETBSD=true
```

To override the defaults, specify the platforms on the command line  For instance:
```
./kvm install check netbsd
```
will only install on, and limit tests to those requiring NetBSD.

## Tuning

The following tweaks, while not necessary, speed up test runs.

### Configure \$(KVM_WORKERS) to run things in parallel

By default all operations (building and testing) is serialized (even
the VMs are given only one CPU!).  If the host has plenty of cores
then the parallelism can be increased using $(KVM_WORKERS).  It does
the following:

- assigns `$(KVM_WORKERS)` CPUs to the build VMs
- builds using `make -j $(KVM_WORKERS)`
- creates `$(KVM_WORKERS)` instances of the test VMs and runs them in parallel

For instance:

```
KVM_PREFIX=a.
KVM_WORKERS=3
```

(the prefixes `a.`, `a2`, `a3` are used to make test VMs unique).

**Note: there's a diminishing return on adding cores.  The
rule-of-thumb (we do have data) is two-cores and 2gb per worker.**

### Configure `$(KVM_LOCALDIR)` store disks in tmpfs (`/tmp/pool`)

**DANGER: this assumes you're using a dedicated machine (look up
  problems with /tmp and security).**

**Note: it isn't clear if this option improves testsuite performance.**

By default, all KVM disk images are stored in $(KVM_POOLDIR)
which is assumed to be permanent storage.

Since the build and test VMs are transient, their disk images can
instead be kept in temporary storage, namely `/tmp`.

In `Makefile.inc.local`, point the `make` variable `$(KVM_LOCALDIR)` at `/tmp/pool` vis:
```
echo KVM_LOCALDIR=/tmp/pool >> Makefile.inc.local
```

This helps eliminate some of the physical disk IO.
