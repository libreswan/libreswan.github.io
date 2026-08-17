## Shell access using SSH

While requiring more effort to set up, it provides full shell access to
the domains.

Since you will be using ssh a lot to login to these machines, it is
recommended to either put their names in /etc/hosts:

`# /etc/hosts entries for libreswan test suite`
`192.1.2.45 west`
`192.1.2.23 east`
`192.0.3.254 north`
`192.1.3.209 road`
`192.1.2.254 nic`

or add entries to .ssh/config such as:

`Host west`
`       Hostname 192.1.2.45`

If you wish to be able to ssh into all the VMs created without using a
password, add your ssh public key to
**testing/baseconfigs/all/etc/ssh/authorized_keys**. This file is
installed as /root/.ssh/authorized_keys on all VMs

Using ssh becomes easier if you are running ssh-agent (you probably are)
and your public key is known to the virtual machine. This command, run
on the host, installs your public key on the root account of the guest
machines west. This assumes that west is up (it might not be, but you
can put this off until you actually need ssh, at which time the machine
would need to be up anyway). Remember that the root password on each
guest machine is "swan".

`ssh-copy-id root@west`

You can use ssh-copy for any VM. Unfortunately, the key is forgotten
when the VM is restarted.

Limitations:

- this only works with the default east, et.al. (it does not work with
  \$(KVM_PREFIX) and/or multiple test directories)
