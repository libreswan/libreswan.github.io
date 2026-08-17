Sometimes it is necessary to build and test old code (for instance,
when determining the oldest release that has a bug).

Here are some hints (they worked once):

## Building and testing an old branch

Old branches have two problems:

- the KVM codebase is out-of-date
- the OS releases are gone

Here are two ways to get around it:

### Using a test-bench

This workflow works best when working on an old branch (lets say v4.11)

Two repositories are used:

1.  Repo Under Test aka `RUTDIR`

    this contains both the sources and the tests

2.  The Testbench aka `BENCHDIR`

    this contains the test scripts used to drive `${RUTDIR}`

Start by checking out the two repositories (existing repositories can
also be used, carefully):

```
RUTDIR=$PWD/v4_maint ; export RUTDIR
git clone https://github.com/libreswan/libreswan.git`](https://github.com/libreswan/libreswan.git -r v4_maint ${RUTDIR}
git clone https://github.com/libreswan/libreswan.git`](https://github.com/libreswan/libreswan.git testbench
```

Next, configure `testbench` so that it compiles, installs, and runs
tests from `${RUTDIR}` by setting the `$(KVM_RUTDIR)` make variable:

```
echo KVM_RUTDIR=$(realpath $RUTDIR)           >> testbench/Makefile.inc.local
```

_`$(KVM_SOURCEDIR)` and `$(KVM_TESTINGDIR)` default to
`$(KVM_RUTDIR)`; you can also set `$(KVM_SOURCEDIR)` and
`$(KVM_TESTINGDIR)` explicitly._

Now, (re-)transmogrify the `testbench` so that, within the domains,
`/source` points at `${RUTDIR}` and `/testing` points at
`${RUTDIR}/testing`:

```
./testbench/kvm transmogrify
```

in the command building the fedora domain look for output like:

```
--filesystem=target=bench,type=mount,accessmode=squash,source=/.../testbench \
--filesystem=target=source,type=mount,accessmode=squash,source=${RUTDIR} \
--filesystem=target=testing,type=mount,accessmode=squash,source=${RUTDIR}/testing \
```

Finally install and then run a test:

```
./testbench/kvm install check diff $RUTDIR/testing/pluto/basic-pluto-01
```

If you prefer you can run `testbench/kvm`:

- from the `testbench` directory as `./kvm`
- from the `${RUTDIR}` directory as `../testbench/kvm`

just do not run `$RUTDIR/kvm`.

### Reviving the dead OS

Again looking at v4_maint branch. Check it out:

```
git checkout ... -b v4_maint
```

add the following to Makefile.inc.local:

```
KVM_PREFIX=v4
KVM_FEDORA_ISO_URL = https://archives.fedoraproject.org/pub/archive/fedora/linux/releases/35/Server/x86_64/iso/Fedora-Server-dvd-x86_64-35-1.2.iso
```

build fedora-base:

```
./kvm base-fedora
```

login to the base domain:

```
./kvm sh fedora-base
```

and edit the repos per:

```
/etc/yum.repos.d/fedora.repo:name=Fedora $releasever - $basearch
/etc/yum.repos.d/fedora.repo:baseurl=https://archives.fedoraproject.org/pub/archive/fedora/linux/releases/35/Everything/x86_64/os
/etc/yum.repos.d/fedora.repo:name=Fedora $releasever - $basearch - Debug
/etc/yum.repos.d/fedora.repo:baseurl=https://archives.fedoraproject.org/pub/archive/fedora/linux/releases/35/Everything/x86_64/debug/tree/
/etc/yum.repos.d/fedora.repo:name=Fedora $releasever - Source
/etc/yum.repos.d/fedora.repo:baseurl=https://archives.fedoraproject.org/pub/archive/fedora/linux/releases/35/Everything/source/tree/
/etc/yum.repos.d/fedora-updates.repo:name=Fedora $releasever - $basearch - Updates
/etc/yum.repos.d/fedora-updates.repo:baseurl=https://archives.fedoraproject.org/pub/archive/fedora/linux/updates/35/Everything/x86_64/
/etc/yum.repos.d/fedora-updates.repo:name=Fedora $releasever - $basearch - Updates - Debug
/etc/yum.repos.d/fedora-updates.repo:baseurl=https://archives.fedoraproject.org/pub/archive/fedora/linux/updates/35/Everything/x86_64/debug/
/etc/yum.repos.d/fedora-updates.repo:name=Fedora $releasever - Updates Source
/etc/yum.repos.d/fedora-updates.repo:baseurl=https://archives.fedoraproject.org/pub/archive/fedora/linux/updates/35/Everything/source/tree/
```

after that:

```
./kvm install check
```

might work

