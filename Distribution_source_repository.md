On this page you can find collection of links to libreswan in various
distributions, and libreswan related software repositories.

# Libreswan Source repositories

## Alpine Linux ![alpine linux logo](/images/Alpine-linux-logo.png)

**git**:
<https://git.alpinelinux.org/cgit/aports/tree/community/libreswan>

## CentOS ![Centos logo](/images/Centos_logo.png)

**package**: <https://git.centos.org/rpms/libreswan/>

## Debian ![Debian logo](/images/Debian-logo.png)

**package**: <https://packages.qa.debian.org/libr/libreswan.html>
<https://tracker.debian.org/pkg/libreswan>

**binary package** : <https://packages.debian.org/unstable/libreswan>

**git**: <https://anonscm.debian.org/git/collab-maint/libreswan.git>

**bugs**:
<https://bugs.debian.org/cgi-bin/pkgreport.cgi?repeatmerged=no&src=libreswan>

## Fedora ![Fedora logo](/images/Fedora-logo.png)

**package**: <https://src.fedoraproject.org/rpms/libreswan>

**git**: <https://src.fedoraproject.org/rpms/libreswan>

**bugs**: <https://apps.fedoraproject.org/packages/libreswan/bugs>

## gentoo ![gento logo](/images/Gentoo-logo.png)

**package**: <https://packages.gentoo.org/packages/net-vpn/libreswan>

## OpenWRT

**git**: <https://github.com/openwrt/packages/tree/master/net/libreswan>

**bugs**: <https://github.com/openwrt/packages>

## Ubuntu ![Ubuntu logo](/images/Ubuntu-logo.png)

**bin package**' : <https://packages.ubuntu.com/bionic/libreswan>

**src package**: <https://launchpad.net/ubuntu/+source/libreswan/>

**bugs**:
<https://bugs.launchpad.net/ubuntu/+source/libreswan/+bugs?field.status:list=NEW>

**questions**:
<https://answers.launchpad.net/ubuntu/+source/libreswan/+questions?field.status=OPEN>

## Libreswan Upstream

**home**: <https://www.libreswan.org>

**git**: <https://github.com/libreswan/libreswan>

**bugs**: <https://github.com/libreswan/libreswan/issues>

# Bugs

- Libreswan Github: <https://github.com/libreswan/libreswan/issues>
- Red Hat Bugzilla:
  [RHBZ](https://bugzilla.redhat.com/buglist.cgi?bug_status=NEW&bug_status=VERIFIED&bug_status=ASSIGNED&bug_status=MODIFIED&bug_status=ON_DEV&bug_status=ON_QA&bug_status=RELEASE_PENDING&bug_status=POST&field0-0-0=product&field0-0-1=component&field0-0-2=alias&field0-0-3=short_desc&field0-0-4=status_whiteboard&field0-0-5=content&list_id=8255857&order=component%2Cproduct%2Cbug_id&query_based_on=&query_format=advanced&type0-0-0=substring&type0-0-1=substring&type0-0-2=substring&type0-0-3=substring&type0-0-4=substring&type0-0-5=matches&value0-0-0=libreswan&value0-0-1=libreswan&value0-0-2=libreswan&value0-0-3=libreswan&value0-0-4=libreswan&value0-0-5=%22libreswan%22)
- Debian bugs :
  <https://bugs.debian.org/cgi-bin/pkgreport.cgi?repeatmerged=no&src=libreswan>
- Ubuntu bugs :
  <https://bugs.launchpad.net/ubuntu/+source/libreswan/+bugs?field.status:list=NEW>

# Related packages

## Strongswan

- Fedora <https://src.fedoraproject.org/rpms/strongswan/>

## Unbound

- Debian: <https://tracker.debian.org/pkg/unbound>
- Centos 7:
  <http://vault.centos.org/centos/7/os/Source/SPackages/unbound-1.4.20-28.el7.src.rpm>
- Centos git: <https://git.centos.org/summary/rpms!unbound.git> 1.4.2 no
  libevent support
- Fedora: <https://src.fedoraproject.org/rpms/unbound>
- Ubuntu libunbound:
  <https://code.launchpad.net/~usd-import-team/ubuntu/+source/unbound/+git/unbound>

# 2017 closed : ~~libunbound2 + libevent bug/feature requests~~

- Libreswan upstream:
  ~~<https://github.com/libreswan/libreswan/issues/117>~~ Closed
- Debian: ~~<https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=871675>~~
  Closed
- Debian: ~~<https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=859584>~~
  Closed
- RH 6.10: ~~<https://bugzilla.redhat.com/show_bug.cgi?id=1434662>~~
  Closed
- RH 7.4: ~~<https://bugzilla.redhat.com/show_bug.cgi?id=1434661>~~ no
  libevent support
- Unbound upstream discussion :
  <https://lists.nlnetlabs.nl/pipermail/unbound-users/2017-April/004718.html>

# Kernel source repositories

- ipsec Steffen Klassert
  <https://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec.git>
- ipsec-next Steffen Klassert
  <https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git>
- net David Miller
  <https://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git>
- net-next David Miller
  <https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git>

<!-- -->

- Linux Stable
  <https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git>

<!-- -->

- Debian <https://salsa.debian.org/kernel-team/linux>
- CentOS <https://git.centos.org/rpms/kernel>
- Fedora <https://src.fedoraproject.org/rpms/kernel>
- Ubuntu
  <https://git.launchpad.net/~ubuntu-kernel/ubuntu/+source/linux/>

# Kernel CONFIG_XFRM_MIGRATE disabled

XFRMA_MIGRATE require CONFIG_XFRM_MIGRATE=y\|m. Libreswn Mobike support
need. Mainline kernel CONFIG_XFRM_MIGRATE is not set. Many
distributions, Debian, Fedora, CentOS... has it enabled. However, there
are few with CONFIG_XFRM_MIGRATE disabled. Here is a list of feature
requests to track the missing ones.

- Ubuntu [feature
  request](https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1835891)
  [config](https://git.launchpad.net/~ubuntu-kernel/ubuntu/+source/linux/+git/focal/tree/debian.master/config/config.common.ubuntu)

<!-- -->

- OpenWRT Pull requrest <https://github.com/openwrt/openwrt/pull/2142>

# Libreswan in Downstream releases

- <https://repology.org/project/libreswan/versions>