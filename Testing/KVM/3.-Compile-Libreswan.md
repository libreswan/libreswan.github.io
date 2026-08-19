## TL;DR

To compile and install Libreswan on the LINUX VM (the default), run:

```
./kvm install
```

(By default, Libreswan is only built on the LINUX VM (a stable version
of Fedora)).

## Compiling Libreswan

To compile libreswan ready for VM testing, use:
```
./kvm install
```
Should the build fail, the VM's console can be accessed using:

```
./kvm sh linux
linux# gmake
linux# vi problem-file.c
```

(Should the build fail, VM is left running making this quick)

Finally, to compile from scratch, first uninstall the build VM(s)
using:

```
./kvm uninstall
```

typically this isn't needed.

## Building On Other Platforms

To compile and install Libreswan on other platform run:

```
./kvm install PLATFORM
```

where PLATFORM is alpine, debian, fedora, freebsd, netbsd, openbsd.

for instance:

```
./kvm install alpine
```

like for LINUX, the build can be debugged by accessing the platform's console:

```
./kvm sh alpine
```

Note: it may take some time as the platform's VM will need to first be built.

To make PLATFORM part of the default build (included in `./kvm
install`) enable it in `Makefile.inc.local` with lines like:

```
KVM_ALPINE=true
KVM_DEBIAN=true
KVM_FEDORA=true
KVM_FREEBSD=true
KVM_NETBSD=true
KVM_OPENBSD=true
```
