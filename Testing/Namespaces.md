This is a crib-sheet for using Namespace testing.

## Disclaimer

This, along with some quick hacks, and thanks to GSoC candidate
feedback, were knocked up during GSoC in 2026.

Please remember that the original author of this page **does not
normally use namespaces**.

## Limitations

- The reference output, for most tests, is generated using the current
  Fedora release (inside a VM).

  _Think of this choice as an historic accident._

  This means that the test output when run on other distros (Debian
  say) and even other Fedora releases will have differences.

- Namespace testing is really only supports one build tree.

  Pluto is run from /usr/local, and test namespaces point into the
  build tree.

  It is much easier to have one VM per build.

- Test results are incomlete

  This is because the test's namespace isn't complete when compared to
  a real (virtual) machine.

  In many cases fixing it is just a matter of programming, so patches
  welcome.

**Hence, creating a dedicate Fedora VM is strongly encouraged.**

## Create a Fedora VM?

Per above, you're encouraged to create a dedicated VM.  Here's the
`virsh` command that was used on Debian to build a text-only VM.  It
was used when writing up the below:

```
sudo virt-install \
     --extra-args="console=ttyS0,115200 inst.notmux" \
     --graphics=none  \
     --virt-type=kvm  \
     --console=pty,target_type=serial  \
     --network=default \
     --vcpus=2 \
     --memory=4096 \
     --name=libreswan \
     --disk=path=libreswan.qcow2,size=15,bus=virtio,format=qcow2 \
     --location=Fedora-Server-dvd-x86_64-43-1.6.iso
```

From here on in, it's assumed you're logged into Fedora.

## Add yourself to `sudo`

Some of the test scrips need to be run as root.  The test environment
assumes this can be done using `sudo` without a password vis:

```
sudo pwd
```

This is setup by adding an entry under /etc/sudoers.d/ specifying that
your account does not need a password to become root:

```
echo "$(id -u -n) ALL=(ALL) NOPASSWD: ALL" | sudo dd of=/etc/sudoers.d/$(id -u -n)
```

## Download and Build Libreswan

### Install Build Dependencies

```
sudo dnf install -y cc make flex bison xmlto
sudo dnf install -y nss-devel nss-tools nss-util-devel
sudo dnf install -y libevent-devel unbound-devel audit-libs-devel pam-devel libselinux-devel libseccomp-devel ldns-devel libcurl-devel
sudo dnf install -y git
```

also useful:

```
sudo dnf install -y pretty-git-prompt
```

### Download Libreswan

```
git clone --origin libreswan https://github.com/libreswan/libreswan.git
cd libreswan
```

### Build and Install Libreswan

```
make -j base
sudo make install-base
```

`base` builds just the programs needed for testing (a full install includes documentation and is much slower).

## Run a Test

### Install Test Dependencies

Assuming a minimal install of Fedora Server:

```
sudo dnf install -y diffstat
sudo dnf install -y valgrind
sudo dnf install -y strongswan
sudo dnf install -y openssl
sudo dnf install -y bind bind-dnssec-utils
sudo dnf install -y python3-pexpect
sudo dnf install -y socat
sudo dnf install -y netcat
sudo dnf install -y net-tools # ifconfig route
sudo dnf install -y rsync
sudo dnf install -y ocspd
sudo dnf install -y nsd
sudo dnf install -y patch
sudo dnf install -y unbound
sudo dnf install -y fping
sudo dnf install -y jq
sudo dnf install -y checksec
sudo dnf install -y ansible-playbook
sudo dnf install -y linux-system-roles
sudo dnf install -y sshpass
sudo dnf install -y strongswan-sqlite
```

### Generate the PKI keys and signed DNSSEC zones

Many tests expect a PKIX X.509 keys i.e., private keys and
certificates.  And to test DNSSEC signed zones are needed:

```
make -C testing/x509
./testing/dnssec/generate-dnssec.sh
```

The commands to generate keys can be heavily dependent on the platform
they are run.  This is why `./kvm` runs the commands inside a Fedora
VM; and why the notes say to use Fedora.  _Remember, the choice is an
historic accident._

This needs to happen once every few weeks.

### Try running a single test

```
cd testing/pluto/basic-pluto-01
../../utils/nsrun --ns
```

If you're lucky you'll get the final output:

```
nsrunner 22.01: stop testing basic-pluto-01 after 21.6 seconds
nsrunner 22.08: sanitizer output
 east Consoleoutput matched
west Consoleoutput matched
result basic-pluto-01 passed 
```

To check differences, either look at `OUTPUT/*.diff`, or run:

```
../../../kvm diff
```

Yes, using `./kvm` to get the diff.

### Accessing the test namespace from a terminal

This magic

```
NSENTER () {
    ns=$1;
    nsargs="--mount=/run/mountns/${ns} --net=/run/netns/${ns} --uts=/run/utsns/${ns}";
    NSENTER_CMD="/usr/bin/nsenter ${nsargs} ";
    sudo ${NSENTER_CMD} /bin/bash
}
NSENTER east-basic-pluto-01
```

from [Namespace Testing](/Testing/Namespaces) (almost) works!

Just note that scripts expect a magic environment variable to be set;
see scripts for details.

## Run the entire Testsuite ...

### Run all `good` tests

Here's a quick and dirty command.  It extracts a list of `good` tests
to run from TESTLIST, and then feeds them all to
`namespace-runner.py`:

```
./testing/utils/namespace-runner.py $(awk '/^kvmplutotest.*good/ {print $2}' testing/pluto/TESTLIST )
```

The problem is that the command assumes namespaces can run all tests.
Which is impossible for tests requiring BSD, say.

### Run all `good` `linux` tests

This uses `kvmresults.py` (yes the irony) to limit things to just
`linux` tests:

```
./testing/utils/namespace-runner.py $(/testing/utils/kvmresults.py --test-platform linux --result untested --test-status good  --print test-name testing/pluto/TESTLIST)
```

The problem, this time, is that namespaces don't know about the hosts
`rise` and `set` (and `kvmresults.py` isn't the fastest) and re-runs
all tests.

### Run all `good` `linux` failing/untested tests

This version skips tests that have passed:

```
./testing/utils/namespace-runner.py $(/testing/utils/kvmresults.py --quick --test-platform linux --skip passed --test-status good  --print test-name testing/pluto/TESTLIST)
```

### Run all modified tests

Possibly the most useful:

```
./testing/utils/namespace-runner.py $(/kvm modified | cut -d/ -f3)
```

which will run just the tests that have uncommitted modifications.

## Expected results

```
total: 1362
total/failed: 236
total/ignored: 235
total/passed: 878
total/unresolved: 13
```

after some [fixes](https://github.com/orgs/libreswan/projects/12)
things have improved:

```
total  tests: 1135
passed tests: 946
failed tests: 189
```

but still dismal (KVM can get 0 fails).
