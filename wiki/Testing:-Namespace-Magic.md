The namespaces have been around for long time however, it still feel
magic. So I start a page to enable magic, in 2019. As time pass it may
not be magic anymore or even may become obsolete. An [early attempt in
Libreswan](https://github.com/libreswan/libreswan/commit/16a97349952373734e41d9185d6b7c84b20d858c#diff-4f87e254860291fdfb0a76d4d2ea7f73)
with Paul.

# Design

The namespaces are named as host-testname e.g "east-basic-pluto-01" and
"west-basic-pluto-01". Networking is using bridges. Once we scale up we
can keep all tests running at the same time there won't be any
namespace, bridge, network link name collisons.

## Network bridge

The bridges on the host are named uniquely. brswan-<BC>-<csum> . csum is
16bit checksum of testname. The max length of bridge name is 15
characters.

    brswan-12-<csum>
      where csum is checksum of test name. So each test can have unique bridge on the system.
      note 12 is part of our IPv4 addressing. 192.1.2.x network. that connect east, west, and nic.
    e.g basic-pluto-01 192.1.2.0/24  brswan12-52501

No bridge for the second eth device on east, west, norht, eg. west eth0,
192.0.1.254/24 has no bridge associated because we don't have sunrise
and sunset yet. so eth0 is just hanging in there. this might save us
total bridges required on the host.

## Network links

Network links are veth type. On the host side they are named as
h<host>eX<csum>. e.g east's eth0 is heaste052501, eth1 of east
heaste152501. heaste152501 will join the bridge brswan12-52501

# FAQ

## How detect from inside the namespace

`* "ip netns identify" would return name of the namespace`
`* one way seems to look at eth0. inside namespace "eth1@if107" kvm "eth0:"`
`* detect from SUDO_CMDLINE `

    2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP mode DEFAULT group default qlen 1000
        link/ether 52:54:00:9e:81:71 brd ff:ff:ff:ff:ff:ff
    </rep>

    * How find veth's peer inside namespace from a host : link-netns

    <pre>
    on the host ip link output:

    107: hweste164512@if106: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master brswan12-64512 state UP mode DEFAULT group default qlen 1000
        link/ether 4a:34:cd:0e:0c:13 brd ff:ff:ff:ff:ff:ff link-netns west-ikev2-03-basic-rawrsa

    from inside the name space

    106: eth1@if107: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default qlen 1000
        link/ether 02:10:c8:8e:d2:7e brd ff:ff:ff:ff:ff:ff link-netnsid 0

    from the host you get the name space name: "link-netns west-ikev2-03-basic-rawrsa"
    for exaactly which interface from "ip link" you see "106: eth1@if107",  "107: hweste164512@if106"

# Scaling issues to navigate

## route cache filling up

    [2936616.607520] Route cache is full: consider increasing sysctl net.ipv[4|6].route.max_size.
    [2936616.607908] Route cache is full: consider increasing sysctl net.ipv[4|6].route.max_size.
    [2936616.609100] Route cache is full: consider increasing sysctl net.ipv[4|6].route.max_size.

    sysctl -a | grep "route.max_size"

    net.ipv4.route.max_size = 2147483647

google suggest flushing the route cache. That does not seems to help. I
think routes are stuck inside namespaces.

    ip route flush cache

    ip route show cache is empty

    ip -all netns exec ip link show
    show weired errors.

    ip -all netns exec ip link show

    netns: east-ikev2-mobike-06
    setting the network namespace "east-ikev2-mobike-06" failed: Invalid argument

## iptable fails -w 60 seems to help


    sudo /usr/bin/nsenter --mount=/run/mountns/west-nstest-4 --net=/run/netns/west-nstest-4 --uts=/run/utsns/west-nstest-4 /bin/bash -c 'cd /testing/pluto/nstest-4;iptables -I INPUT -m policy --dir in --pol ipsec -j ACCEPT
    '
    Another app is currently holding the xtables lock. Perhaps you want to use the -w option?

I tried putting less /root/.bashrc

    alias iptables="iptables --wait 60 --wait-interval=100000"

That seems to have reduced the failure rate from 50% to 2%, when running
500 tests 10 tests in parallel. Changing to --wait 120 still cause 1.3%
errror. Going above 120 seconds would skew tests. They usually timeout
in 120 seconds

# would this work on foo 7/CentOS7: not yet too old util-linux

unshare and or nsenter do not suppor --mount\[=file\] option.

seems to be some options.

    fedora 28
    unshare -V
    unshare from util-linux 2.32.1

    -m, --mount[=file]
       Unshare the mount namespace.  If file is specified, then a persistent namespace is cre‐ated
       by a bind mount

    ---- old one foo 7 -----
    unshare -V
    unshare from util-linux 2.23.2

    -m, --mount
       Unshare the mount namespace.

=== test using "sudo unshare --net=/run/netns/east-basic-pluto-01
/usr/bin/bash" ===

# outstanding issues

## reduce the use of iptables

This would go in steps. First make sure the swan-prep crate the LOGDROP
traget only when a test need it. grep in the test scripts for LOGDROP.
So mostly it will only run on the initiator.

## proxy arp route missing on east

See the 20 Sep 2019 post [extract MAC address from "ip -o link sow dev
eth0" -
awk](https://lists.libreswan.org/archives/list/swan-dev@lists.libreswan.org/thread/CTUXOYNU4NO5GX4EPH2OZDG7J5HQVKHZ/)?

## MAC address mismatch

the NICs, on east, west, road, north in KVM use a consistant MAC
address. Namespace does not have this yet. It can be done need more
work.

here is an example of diff testrun ikev2-xfrmi-06

      ip addr show dev eth0
    -2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default
    -    link/ether 12:00:00:ab:cd:02 brd ff:ff:ff:ff:ff:ff
    -    inet 192.1.3.209/24 brd 192.1.3.255 scope global eth0
    +X : eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    +    link/ether fa:79:7a:e3:fc:49 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    +    inet 192.1.3.209/24 scope global eth0
            valid_lft forever preferred_lft forever

## order of ip -o addr show scope global

the command "ip -o addr show scope global" very likely to produce
different order in kvm and namespace runs

    [root@west ikev2-xfrmi-08]# ip addr show scope global
    2: eth0: <BROADCAST,MULTICAST> mtu 1500 qdisc fq_codel state DOWN group default qlen 1000
        link/ether 12:00:00:ab:cd:ff brd ff:ff:ff:ff:ff:ff
    3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
        link/ether 12:00:00:64:64:45 brd ff:ff:ff:ff:ff:ff
        inet 192.1.2.45/24 brd 192.1.2.255 scope global eth1
           valid_lft forever preferred_lft forever
    4: ipsec17@eth1: <NOARP> mtu 1500 qdisc noop state DOWN group default qlen 1000
        link/none 12:00:00:64:64:45 brd ff:ff:ff:ff:ff:ff
        inet 192.0.1.254/24 scope global ipsec17

In namespace

    t ikev2-xfrmi-08]# ip addr show scope global
    2: ipsec17@eth1: <NOARP> mtu 1500 qdisc noop state DOWN group default qlen 1000
        link/none 12:00:00:64:64:45 brd ff:ff:ff:ff:ff:ff
        inet 192.0.1.254/24 scope global ipsec17
           valid_lft forever preferred_lft forever
    2053: eth0@if2054: <BROADCAST,MULTICAST> mtu 1500 qdisc noqueue state DOWN group default qlen 1000
    Error: Peer netns reference is invalid.
        link/ether 12:00:00:ab:cd:ff brd ff:ff:ff:ff:ff:ff link-netnsid 0
    2056: eth1@if2057: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
        link/ether 12:00:00:64:64:45 brd ff:ff:ff:ff:ff:ff link-netnsid 0
        inet 192.1.2.45/24 scope global eth1
           valid_lft forever preferred_lft forever

== "kernel:unregister_netdevice: waiting for eth1 to become free. Usage
count = 1" reboot host==

This error message seems to appear due a race condition when deleting
XFRMi and veth on the host. The xfrmi device, ipsec1 is deleted and
immediately deleting the veth device seem to cause this error? I think
that is the order.


    nsrunner 7.00/6.06: swantest # (/usr/sbin/ip link show | grep 'master brswan13-61314' || (/usr/sbin/ip link show brswan13-61314 && /usr/sbin/ip link set brswan13-61314 down && /usr/sbin/ip link del name brswan13-61314)) || true
    nsrunner 17.01/16.07: TIMEOUT (/usr/sbin/ip link show | grep 'master brswan13-61314' || (/usr/sbin/ip link show brswan13-61314 && /usr/sbin/ip link set brswan13-61314 down && /usr/sbin/ip link del name brswan13-61314)) || true
    nsrunner 17.01/16.07: swantest # /usr/sbin/ip link show hroade061314 && /usr/sbin/ip link set hroade061314 down && /usr/sbin/ip link del name hroade061314 || true

    Message from syslogd@swantest at Oct  8 12:42:54 ...
     kernel:unregister_netdevice: waiting for eth1 to become free. Usage count = 1

## "Error: Peer netns reference is invalid."

= It seems when the namespaces get mangled up any "ip" command would
output this error. For now I am sanitizing it.

## running the tests in parallel worker pool

=

## support bind mount installation using RPM or make install-base

This would help us test two versions of libreswan against each other.
Say interoperate between 3.28 - 3.25.

## can not attch gdb in side the namesapce??? gdb -p 'pidof pluto\` will not work

If your run "gdb -p 'pidof pluto\`" inside the namesapce gdb may attach
to wrong namesapce. Becuse pidof pluto will see all plutos on the host.

    gdbp -p `pidof pluto`
    warning: the debug information found in "target:/usr/lib/debug//lib64/ld-2.29.so.debug" does not match "target:/lib64/ld-linux-x86-64.so.2" (CRC mismatch).

    warning: the debug information found in "target:/usr/lib/debug/lib64//ld-2.29.so.debug" does not match "target:/lib64/ld-linux-x86-64.so.2" (CRC mismatch).

    Missing separate debuginfo for target:/lib64/ld-linux-x86-64.so.2
    Try: dnf --enablerepo='*debug*' install /usr/lib/debug/.build-id/bd/5e36f101b175755c7943105390078dff596657.debug
    0x00007fce108e249e in ?? ()

also "gdbp -p \$(cat /run/pluto/pluto.pid)" fails

## route cache filling up

So testruns appeared to fill up route cache and packets will not
forward.

## python threads locking up

It seems often the the workers, started using ProcessPoolExecutor seems
to lock up. They sit there doing nothinng I have been looking at them
using gdb

    gdb  /usr/bin/python3.7 -p <pid>
    (gdb) py-bt
    Traceback (most recent call first):
      File "/usr/lib64/python3.7/multiprocessing/synchronize.py", line 95, in __enter__
        return self._semlock.__enter__()
      File "/usr/lib64/python3.7/multiprocessing/queues.py", line 93, in get
        with self._rlock:
      File "/usr/lib64/python3.7/concurrent/futures/process.py", line 226, in _process_worker
        call_item = call_queue.get(block=True)
      File "/usr/lib64/python3.7/multiprocessing/process.py", line 99, in run
        self._target(*self._args, **self._kwargs)
      File "/usr/lib64/python3.7/multiprocessing/process.py", line 297, in _bootstrap
        self.run()
      File "/usr/lib64/python3.7/multiprocessing/popen_fork.py", line 74, in _launch
        code = process_obj._bootstrap()
      File "/usr/lib64/python3.7/multiprocessing/popen_fork.py", line 20, in __init__
        self._launch(process_obj)
      File "/usr/lib64/python3.7/multiprocessing/context.py", line 277, in _Popen
        return Popen(process_obj)
      File "/usr/lib64/python3.7/multiprocessing/process.py", line 112, in start
        self._popen = self._Popen(self)
      File "/usr/lib64/python3.7/concurrent/futures/process.py", line 593, in _adjust_process_count
        p.start()
      File "/usr/lib64/python3.7/concurrent/futures/process.py", line 569, in _start_queue_management_thread
        self._adjust_process_count()
      File "/usr/lib64/python3.7/concurrent/futures/process.py", line 615, in submit
        self._start_queue_management_thread()
      File "/home/build/libreswan/testing/utils/nsrun", line 3790, in run_ns_q_conc
        except KeyboardInterrupt:
      File "/home/build/libreswan/testing/utils/nsrun", line 3744, in do_test_list_new
        else:
      File "/home/build/libreswan/testing/utils/nsrun", line 3985, in main
        return
      File "/home/build/libreswan/testing/utils/nsrun", line 4069, in <module>

    gdb magic to get python bt
    dnf debuginfo-install python3
    dnf debuginfo-install python3-3.7.3-3.fc29.x86_64

# Further ideas

## Mixed KVM + namespace

One host, the you are debuggig is KVM and rest of the hosts are
namesapce. Quicker development and debugging

## isolate the bridges completley

create namesapces completely isolated. use bridge forwarding??

# Good to know

## nsenter alias/function

    NSENTER()
    {
     ns=$1
     nsargs="--mount=/run/mountns/${ns} --net=/run/netns/${ns} --uts=/run/utsns/${ns}"
     NSENTER_CMD="/usr/bin/nsenter ${nsargs} "
     sudo ${NSENTER_CMD} /bin/bash
    }

    # Then type

    NSENTER east-basic-pluto-01