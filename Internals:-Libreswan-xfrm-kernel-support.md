Here are gory details for Linux kernel support that you may run into.
One recurring theme when Linux Kernel IPsec get a new feature usually
the default is "N". And the distributions take that. However, when
librewan start using the new feature we or someone often need to chase
the various distributions get this feature enabled. The challenge of
this model, as far as I see, is the libreswan, a userland application,
has no easy way to require a kernel config option to be enabled or
disabled.

# Linux XFRM support

## Recommended for modern generic kernel, say 4.14 or later

## XFRMI 4.19 or later (libreswan 3.28)

    # CONFIG_NET_KEY is not set
    # CONFIG_NET_KEY_MIGRATE is not set

    CONFIG_NFT_XFRM=y
    CONFIG_INET_XFRM_MODE_TRANSPORT=y
    CONFIG_INET_XFRM_MODE_TUNNEL=y
    CONFIG_INET_XFRM_TUNNEL=y

    CONFIG_XFRM=y
    CONFIG_XFRM_ALGO=y
    CONFIG_XFRM_INTERFACE=y
    CONFIG_XFRM_IPCOMP=y
    CONFIG_XFRM_MIGRATE=y
    CONFIG_XFRM_OFFLOAD=y
    CONFIG_XFRM_STATISTICS=y
    CONFIG_XFRM_USER=y
    CONFIG_XFRM_SUB_POLICY=y
    CONFIG_INET6_XFRM_TUNNEL=y

    CONFIG_CRYPTO_GCM=y
    CONFIG_CRYPTO_CHACHA20POLY1305=y
    CONFIG_CRYPTO_SEQIV=y
    CONFIG_CRYPTO_CBC=y
    CONFIG_CRYPTO_CMAC=y
    CONFIG_CRYPTO_XCBC=y
    CONFIG_CRYPTO_POLY1305=y
    CONFIG_CRYPTO_SHA1_SSSE3=y
    CONFIG_CRYPTO_SHA256_SSSE3=y
    CONFIG_CRYPTO_SHA512_SSSE3=y
    CONFIG_CRYPTO_SHA512=y
    CONFIG_CRYPTO_SHA3=y
    CONFIG_CRYPTO_CHACHA20=y
    CONFIG_CRYPTO_SEED=y
    CONFIG_CRYPTO_ANSI_CPRNG=y
    CONFIG_ASYMMETRIC_KEY_TYPE=y

    CONFIG_NET_IPIP=y
    CONFIG_NET_IP_TUNNEL=y

    CONFIG_INET_IPCOMP
    CONFIG_XFRM_ESPINTCP # may be

    CONFIG_INET_ESP=y
    CONFIG_INET_IPCOMP=y

    CONFIG_INET_ESP_OFFLOAD=y #not only for XFRM HW but also for GRO layer 2 offload

    CONFIG_INET6_ESP=y
    CONFIG_INET6_IPCOMP=y

## known issues

### CONFIG_XFRM_STATISTICS 3.28

Some distributions, as of may 2019, \#CONFIG_XFRM_STATISTICS is not set.
This cause a run time error with libreswan "No XFRM kernel interface
detected". You need a couple of patches or enable this in kernel. This
is specific to libreswan 3.28. 3.29 has fixes for this issue. However,
it is really good idea to enable

### Mobike CONFIG_XFRM_MIGRATE does not work on Ubuntu

Linux kernel support mobike for ages possibly since 2.x. However some
distributions has CONFIG_XFRM_MIGRATE disabled. One could argue mobike
is securtiy risk hence it should be disabled. However, it is a risk
probably fora a group of enviroments. And possibly the group that need
mobike disabled is tweaking the kernel to their needs. So I think the
major distributions should enable it. It is not enabled for historic
reasons. Debian 10, Buster default kernels support mobike. There is open
[feature request
1835891](https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1835891)

#### Mobike possible security issue

A possible security issue - some one create a IPsec connection to a LAN
while physically(or wifi) connected to an administratively allowed
network. Say special project allows VPN only when you present at a site.
When MOBIKE is administratively allowed in kernel and libreswan, one
could move this IPsec/VPN to their 3G connection and take the IPsec/VPN
connection outside the permitted LAN, say home. Now this VPN keeps
connection from any where. Many users don't have such setup. Because of
that I argue the default kernel of distributions should allow MOBIKE.

## Distribtions Default .cofig or the fragments

- [Debian
  config](https://salsa.debian.org/kernel-team/linux/blob/master/debian/config/config)
- [Fedora
  Snippet](https://src.fedoraproject.org/rpms/kernel/blob/84dd8fe88279144ddb82168d1cc44117073ff07e/f/configs/fedora/generic/CONFIG_XFRM_INTERFACE)
- [CentOS
  8x86_64](https://git.centos.org/rpms/kernel/blob/c8-sig-centosplus-kernel/f/SOURCES/kernel-x86_64.config)
- OpenWRT MIPS [rejected merge
  request](https://github.com/openwrt/openwrt/pull/2142)
- [Ubuntu
  Eon](https://git.launchpad.net/~ubuntu-kernel/ubuntu/+source/linux/+git/eoan/tree/debian.master/config/annotations)
- [Ubuntu
  Eon](https://git.launchpad.net/~ubuntu-kernel/ubuntu/+source/linux/+git/eoan/tree/debian.master/config/config.common.ubuntu)

## xfrm Kernel git repositories

- [ipsec](https://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec.git)
- \[//git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec-next.git
  ipsec-next\]
- [Steffen Klassert ipsec
  private](git://git.kernel.org/pub/scm/linux/kernel/git/klassert/linux-stk.git)
- [net - David
  Miller](https://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git)
- [net-next \| David
  Miller](https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git)
- [linux stable
  Greg](git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git)

## Kernel configuration related bug reports and commits

### Debian

- [\#929938](https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=929938)
  implemented
- [CONFIG_XFRM_MIGRATE in Debian Buster,
  2010](https://salsa.debian.org/kernel-team/linux/commit/6b33069da4907e2364b904b7a00201e2c62461c9)
- [CONFIG_XFRM_STATISTICS July
  2019](https://salsa.debian.org/kernel-team/linux/commit/4aa88e41fda04669b5ec198f4c095b5cfbb0a2a4)

### Ubuntu

- [CONFIG_XFRM_MIGRATE Ubutu Feature request July
  2019](https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1835891)
- [Ubuntu CVE against
  CONFIG_XFRM_MIGRATE](https://people.canonical.com/~ubuntu-security/cve/2017/CVE-2017-11600.html)

### OpenWRT

- Not supported yet, closed Feature request
  [1](https://github.com/openwrt/openwrt/pull/2142)