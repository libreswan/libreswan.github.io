

## NetBSD (and OpenBSD)

Build the the kernel per upstream documentation and then copy it to either of:

```
/pool/$(KVM_PREFIX)netbsd-kernel.$(uname -r)
/pool/netbsd-kernel.$(uname -r)
```

During upgrade the stock kernel will be replaced with the above.

## Linux, Fedora, Debian

These systemd assimilated distros all boot the test kernel directly from:

```
$(KVM_POOLDIR)/$(KVM_PREFIX)linux-upgrade.vmlinuz
$(KVM_POOLDIR)/$(KVM_PREFIX)linux-upgrade.initramfs
```

These files are re-created whenever `./kvm transmogrify` is run.  To
boot a different kernel, replace the above (but remember, rerunning
`./kvm transmogrify` (also `./kvm clean` and `./kvm uninstall`) will
revert things to the old kernel.

_Would a better approach be to install the custom kernel into the
`linux-upgrade` domain?_
