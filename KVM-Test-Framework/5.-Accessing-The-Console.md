## Accessing the build domains (`linux`, `fedora`, `debian`, `netbsd`, `openbsd`, `freebsd)

The command

```
./kvm sh <build-domain>
```

can be used to access any of the build domain consoles.

This command will:

- boot and log into HOST, as needed

- handle $(KVM_PREFIX) (`linux` becomes an alias for
  $(KVM_PREFIX)linux)

- configures the terminal (setting width, height, et.al. so VI works)

For instance:

```
$ ./kvm sh linux
[...]
Escape character is ^]
[linux@linux ~]# printenv TERM
xterm
[linux@linux ~]# stty -a
...; rows 52; columns 185; ... 
[linux@linux ~]#
```

Limitations:

- no file transfer but files can be transfered using mount points such
  as `/pool`, `/testing`, and `/source`.

- only one terminal per VM

- `./kvm shutdown` may be needed to shutdown any running test domains

### Remember to shutdown

While the build domain is running the test domains can't boot.

### Also apples to `base` and `upgrade` domains

It's possible to log into the base and upgrade domains vis:

```
./kvm sh linux-base
./kvm sh fedora-upgrade
```

## Accessing test domains (`east`, `west`, `rise`, `set`, `road`, `north`, `nic`)

Unlike the build domains, the test domains first need to be booted by
specifying a test.

_The problem is that the domain `east` could be any of `linuxeast`,
`debianeast`, et.al..  The test is what specifies this mapping._

To boot the test domains, either:

- run an individual test, for instance:

  `./kvm check testing/pluto/basic-pluto-01`

  Once the test is completed the domains are left running.

- explicitly boot a test case's domains, for instance:

  `./kvm boot testing/pluto/basic-pluto-01`

  It will start the necessary test domains, but not run the test.

  **Note: Trying to `./kvm boot`, login and make changes, and then run
    `./kvm check` won't work as expected.  The domains are transient
    (nothing is saved) and `./kvm check` always boots domains from
    scratch.**

Once the domains are booted they can be accessed like above:

```
./kvm sh east
[linux@east ~]#
```
