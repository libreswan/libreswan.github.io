Antony's unsorted pages that I want to access quickly. These are mostly
related to IPsec/libreswan and when I think I know this page exist but
where is it.

- [XFRM pCPU](./Internals:-XFRM-pCPU)
- [XFRMi Development Notes 2018-2019](./Internals:-XFRM-Interface-Development-Notes)
- [Namespace Magic, 2019](./Testing:-Namespace-Magic)
- [IKEv2 State names proposal 2016 - 2019](./Internals:-IKEv2-Child-SA)
- [Cloud Opportunistic Encryption(OE)](./Internals:-Cloud-OE-ideas)
- [Linux Kernel Support related to libreswan](./Internals:-Libreswan-xfrm-kernel-support)

<!-- -->

- [Linux adopting Zinc](https://www.phoronix.com/scan.php?page=news_item&px=Crypto-API-Doing-Some-Zinc)
- [VPN Benchmark](https://www.net.in.tum.de/fileadmin/bibtex/publications/theses/2018-pudelko-vpn-performance.pdf)
- [Wiregaurd BenchMark](https://arstechnica.com/gadgets/2019/12/wireguard-vpn-is-a-step-closer-to-mainstream-adoption/)

# KVM/QEMU

## 9pfs

As of 2023 9pfs is seeing renewed interest among testers. It is probably
not ideal for production use, however, it is ideal for testing. It is
widely used NIX os testing. I imagine libreswan will stick with this for
a while more.

## virtio-fs is an alternative to 9pfs in KVM/QEMU:

In January 2021, I tried it on Fedora 33. I am happy with the initial
results. The performance was great. Building libreswan was quick 44/240
seconds. It might also possible to boot from a host directory. In
combination with btrfs could be a good choice. At the moment creating
and using virtio-fs is bit hard. It will get better.

- Missing features virt-install do not have necessary support to create
  VM with right options such as NUMA settings, big memory
  [libvirtd](https://libvirt.org/kbase/virtiofs.html).
- Systemd mount services seems to miss support.
- virtio-fs can also be [root
  fs](https://virtio-fs.gitlab.io/howto-boot.html). Then boot the KVM
  from kernel(vmlinuz) the host.
- As of 2023 "virtio-fs does not support accessmode='squash' (or mapped)
  (it only supports passthrough). This means that all created files and
  directories end up being owned by root!"
- virtifs would need an instance of daemon per qemu/kvm instance. That
  would create lot of overhead when testing with 10-12 instances.

Requirement: Fedora 33 - libvirt 6.2, qemu 5.0, kernel 5.4

- [libvirt 6.2](https://libvirt.org/news.html) Fedora 33.
  [F33](https://src.fedoraproject.org/rpms/libvirt)
- [RH BZ libvirtd
  merge](https://bugzilla.redhat.com/show_bug.cgi?id=1694166) tracking
  the request
- [QEMU 5.0](https://wiki.qemu.org/ChangeLog/5.0#virtio) added support
  for virtiofsd. [F33??](https://src.fedoraproject.org/rpms/qemu)
- [virtio-fs](https://virtio-fs.gitlab.io) Mainline kernel 5.4
- [virtiofs RFC
  patches](https://marc.info/?l=linux-kernel&m=154446243024251&w=2)

## KVM/QEMU + vsock NFS to replace 9pfs

KVM/QEMU support for vsock and nfs support over vsock could have a
better performance than 9pfs. vsock + nfd started
before[virtio-fs](https://libvirt.org/kbase/virtiofs.html). Currently,
as of Janury 2021, virtio-fs is popular. This work could be interesting
to libreswan KVM testing. It started in 2015. It is slowly picking up,
as of 2018 it used in AWS and AWS firecracker are pushing it. AWS is
using without nfsd support. Other distributions may need nfsd support.

- 2015 [LWN virtio](https://lwn.net/Articles/647516/)

# Linux Kernel developments

## XFRM Offload : starting 4.14

` * NAT support ??? `
` * What if the interface is a member of bridge? can libreswan/strongswan configure SA correctly? `[`bridge`](https://wiki.strongswan.org/issues/3454)
` * what if the packets arrive on different interface would that get decrypted correctly? would it be decrypted by CPU or the offload NIC? `
` * Bonded NIC card`

## XFRM and XDP

` * idea presentation `[`Steffen Klassert`](http://vger.kernel.org/netconf2019_files/xfrm_xdp.pdf)` Linux Netconf, Boston, June, 2019`

# Linux Per CPU efforts

- [Linux Kernel XFRM pCPU](./Internals:-XFRM-pCPU) and
  [Libreswan](https://libreswan.org) Nov 2019
- [Snabb](https://fosdem.org/2020/schedule/event/vita_high_speed_traffic_encryption_on_x86_64/)
  @ [FOSDEM](https://www.fosdem.org)2020
- [Cisco/VPP
  40Gbps](https://medium.com/fd-io-vpp/getting-to-40g-encrypted-container-networking-with-calico-vpp-on-commodity-hardware-d7144e52659a)
  May 2020

# Userspace IPsec Stacks

Over last few years specialized user space IPSec(ESP) stacks and IKE
implementations are becoming popular.

## VPP + DPDK (Userspace ESP + IKE)

VPP has its own IKEv2 and ESP implimentation.

- <https://wiki.fd.io/view/VPP/IPSec_and_IKEv2>
- [User-space Network Stacks (DPDK and
  friends)](https://archive.fosdem.org/2019/schedule/event/userspace_network_stacks)
  2019

## Snabb ESP userspace stack

Snabb as of 2020 has ESP. No IKE, it can easily use of the shelf IKE say
strongswan for IKE and and few command line calls to install snabb esp
[Snabb FOSDEM
2020](https://fosdem.org/2020/schedule/event/vita_high_speed_traffic_encryption_on_x86_64/)
[snabb ipsec
podcast](https://blog.ipspace.net/2019/02/high-speed-ipsec-on-snabb-switch-on.html)
[Strongswan inegeration](https://github.com/inters/vita/issues/68)

## OVS

<http://docs.openvswitch.org/en/latest/tutorials/ipsec/>

# iptable rule to drop IKEv2 message id X

<https://unix.stackexchange.com/questions/321252/drop-a-packet-depending-on-its-options-or-type>

    # drop ike message ID 6
    iptables -A INPUT -m u32 --u32 '0x6 & 0xFF = 0x11 && 0x30 & 0xFFFFFFFF = 0x4' -j DROP

# Hardware offload

## XFRM offload

- Mellonax Innova or ConnectX 6DX
- Intel

## Pensando - DSC ASIC. The PenAccel

Around 2017 - 2020 Pensand DSC(DPU) announced East-West IPsec line rate
100Gbps. It is also FIPS 140-2 certified [\| Oracle certified
it?](https://csrc.nist.gov/CSRC/media/projects/cryptographic-module-validation-program/documents/security-policies/140sp3335.pdf)
[\| Aurba CX
1000](https://packetpushers.net/aruba-puts-dpus-into-new-top-of-rack-switch-5-questions)

## Intel QAT

<https://www.servethehome.com/intel-quickassist-at-40gbe-speeds-ipsec-vpn-testing/>
[\|
DPDK](https://fast.dpdk.org/doc/perf/DPDK_19_11_Intel_crypto_performance_report.pdf)
crypto performance report.

## Intel AES NI

## Historic OCF

Back in the 90 there was alo

# RSS/RPS/RFS

- [RPS](https://garycplin.blogspot.com/2017/06/linux-network-scaling-receives-packets.html)

# Interesting Linux referecncs

## Linux packet path

<https://upload.wikimedia.org/wikipedia/commons/3/37/Netfilter-packet-flow.svg>

## Debugging Netlink

<https://jvns.ca/blog/2017/09/03/debugging-netlink-requests/>

Netlink extack plumbing work [extack first
patch](https://patchwork.kernel.org/project/linux-wireless/patch/20170408174900.12820-2-johannes@sipsolutions.net)
