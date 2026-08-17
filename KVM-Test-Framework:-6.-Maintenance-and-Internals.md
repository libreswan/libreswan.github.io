## TL;DR?

Run:

- `./kvm clean`

  To start afresh (clean build, new results, new keys).

- `./kvm keys`

  The generated X.509 keys have a limited lifetime so occasionally they need to be refreshed.
  (there'll be an error when this needs to happen).

- `./kvm upgrade`

  To refresh the packages.

  Since test output is sensitive to package versions, an occasional
  refresh of the packages is needed to keep things in sync.

  The upgrade process may also hold back packages, and install
  custom packages.

## Some Background

To make maintenance easier, and reduce network requirements, the build VMs are constructed from a sequence of intermediate domains (here, linux is used, same applies to other platforms).

- the base domain: `linux-base`

  The base VMs have one disk and one network interface.

  It will contain a minimal install using only files from the ISO; but with the following tweaks:

  + password set to "swan" or just blank
  + prompt modified so that exit status appears
  + mount points for `/pool` and `/bench` added
  + dhcp configured

  **It should not be upgraded.  That's the next step.** If something goes wrong during the upgrade, things are wound back to this domain.

  (yea, debian seems to upgrade some packages; ulgh!)

- the upgrade domain: `linux-upgrade`

  This is a shallow clone of `linux-base` with the packages needed to build and install libreswan added:

  + the packaging system is tweaked so that /pool/??? contains a cache of downloaded packages
  + packages required by libreswan are installed/upgraded
  + where applicable, packages are disabled (e.g., systemd and network manager)

  _Incremental upgrades are not supported.
  However, if you were to log into this domain,
  make a mess, shut it down, and then run
  `./kvm transmogrify`, you might end up with the desired result..._

- the build domain: `linux`

  This is a _transmogrified_ shallow clone of `linux-upgrade`.
  Transmogrification consists of:

  + add network configuration and scripts to set test hostnames based on network interfaces (ulgh)
  + add mounts for /source and /testing
  + populate the /root account

  It is used to incrementally build libreswan (i.e., no `make clean`) using `/var/tmp`, and installed into `/usr/local`.
  It is then cloned to create test domains.

  To force a scratch build, first run either `./kvm uninstall` or `./kvm clean`.
  It will delete and then rebuild the VM from `linux-upgrade`, so truly from scratch!.

- the test domains: `linuxeast`

  (old) the test domains are defined as transient clone of the build domain

  (new) the transient domains are created on the fly using `linuxeast` et.al. as the xml

## Maintenance

There's no need to delete a domain before rebuilding it. For instance `./kvm upgrade` does not first require `./kvm downgrade`.

There are two variants of each command. The first creates all the
domains, the second only creates the specified domain.

<table>
<tbody>
<tr>
<th>common name</th>
<th>domain name</th>
<th>create<br/>destroy</th>
<th>mounts</th>
<th>networks</th>
</tr>
<tr>
<td></td>
<td>ISO</td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>base domain</td>
<td>linux-base<br>alpine-base<br>...</td>
<td>./kvm base [linux]<br/><br/>./kvm destroy [linux]</td>
<td>/pool<br/>/bench</td>
<td>gateway</td>
</tr>
<tr>
<td>upgrade domain</td>
<td>linux-upgrade<br/>alpine-upgrade<br/>...</td>
<td>./kvm upgrade [linux]<br/><br/>./kvm downgrade [linux]</td>
<td>/pool<br/>/bench</td>
<td>gateway</td>
</tr>
<tr>
<td>build domain</td>
<td>linux<br/>alpine<br/>...</td>
<td>./kvm transmogrify [linux]<br/>./kvm install [linux]<br/><br/>./kvm uninstall [linux]<br>./kvm clean</td>
<td>/pool<br/>/bench<br/>/source<br/>/testing</td>
<td>gateway</td>
</tr>
<tr>
<td>test domain</td>
<td>east<br/>west<br/>...</td>
<td>./kvm install</td>
<td>/source<br/>/testing<br/>/pool</td>
<td><p>test networks<br/>gateway?</td>
</tr>
</tbody>
</table>

### Mount Points

In normal operation, the only mount points of interest within a domain
are `/source` and `/testing`. These are configured to point at the
current source tree.

Internally, the following additional mount points are used:

|          |                   |                   |                |                                      |
|----------|-------------------|-------------------|----------------|--------------------------------------|
| mount    | variable          | default           | use when ...   | notes                                |
| /testing | \$(KVM_TESTDIR)   | libreswan/testing | running tests  | the tests to run                     |
| /source  | \$(KVM_SOURCEDIR) | libreswan/        | during install | the source code to build and install |
| /bench   | \$(KVM_BENCHDIR)  | libreswan/        | building VMs   | the scripts driving the tests        |
| /pool    | \$(KVM_POOLDIR)   | pool/             | building VMs   | KVMs and caches                      |

It is possible, although unusual, to point these at different source
trees. For instance: testing.libreswan uses benchdir (/bench) for the
scripts, and rutdir (/source, /testing) for the directory being tested;
when testing old code /source can be pointed at an alternative directory
that contains the sources that are to be built and tested.
