# Introduction

## IKE acceleration

The IKE protocol uses encryption that can be accelerated. But since IKE
only generates a few packets per hour per IPsec connection, compared to
the thousands or millions of IPsec packets per hour, this is not worth
any extra overhead to talk to some kind of hardware driver. The
exception is on-CPU special instructions, such as AESNI or the VIA
Padlock instructions. Acceleration of these happen via the NSS crypto
library and does not require specific libreswan support.

## Obsoleted IPsec accelerations

Libreswan (for now) still supports its own older KLIPS IPsec stack that
comes with its own OCD based acceleration. It is not recommended to use
KLIPS anymore. KLIPS has no support for AES_GCM and its OCF acceleration
does not support modern NICs that can do 1gbps to 400Gbps.

Similarly, the pcrypt module provides additional parallelism but it
predates some modern Linux kernel network stack and crypto stack
implementatios and should not be used anymore.

Information about these two older hardware accelerations are left at the
end of this document.

## IPsec (ESP) acceleration

libreswan as of version 3.23 supports the new cryptographic hardware
offload as implemented by Linux 4.11 and up using the native (XFRM)
IPsec stack.

Libreswan autodetects supports for any hardware supporting this crypto
offload API. However, it might require that some hardware driver modules
are loaded before libreswan is started. The "ipsec _stackmanager start"
command, which is typically run before the pluto IKE daemon is started,
attempts loads all known hardware modules. If you know of any module not
loaded, please contact the libreswan developers. These hardware modules
include CPU specific ones (eg AESNI or VIA Padlock) as well as NIC card
modules. Although usually the IPsec offload support is integrated into
the NIC card driver and will not require specific hardware crypto
modules to be loaded.

The crypto API comes with defaults that are suitable for generic
machines. If your machine is a dedicated IPsec server, you might want to
change some default parameters. This is especially important for the
crypto API queue length parameter. This was hardcoded to 100 for most
kernels and changed to 1000 in 2017 but recent kernels allow you to
increase that value by (re)loading the crypd module:

    modprobe cryptd cryptd_max_cpu_qlen=2048

Even when using regular 1gbps NIC cards with only AESNI acceleration,
the value of 100 is not enough and will cause your machine to idle
instead of fully using its CPUs for IPsec.

libreswan auto-detects PCI card nic offload support (enabled since 3.23
with the option nic-offload=auto). This option can be set to "yes" (or
"no") to override the default auto-detection. Note that when failing to
add IPsec SA's into the kernel are automatically retried without
offload. This can happen for a number of reasons. The selected algorithm
(eg 3DES) has no hardware offload support. Or the hardware could have
reached the maximum number of IPsec SA's it can support for offloading.

There are two typical deployment scenario's that require hardware
acceleration.

### site to site VPNs

These deployments involves only one or very few IPsec connections
transporting anywhre from 1 to 400 Gbps. Especially on multi-CPU
machines, this can lead to unused resources as an IPsec SA is typically
tied to one CPU's resources. A workaround can be to split the IPsec
connection into artificial smaller IPsec connections. Libreswan will
soon have populate-from-packet (PFP) support to make this easy.

### Remote Access VPNs

These are deployments with thousands of IPsec connections and clients
are continuously being added and removed. Some NIC cards are limited in
their offload capacity, so not all connections might be accelerated.
Since there are still a number of bottlenecks in the kernel for this
scenario, it is important to remove unused IPsec SA's from the kernel.
Typically, that means using DPD/liveness to kill of inactive clients
that have vanished, and cleaning out replaced IPsec SA's more quickly.
When possible, use libreswan 3.24 as it no longer keeps replaced IPsec
SA's around for 20 minutes.

# Supported hardware

The below list is hardware that The Libreswan Project knows about that
supports to new Linux 4.11 crypto hardware offload API. If you know of
others, or are a vendor that would like to be listed, please contact the
libreswan developers.

- Mellanox Innova (mlx5) -
  <http://www.mellanox.com/page/products_dyn?product_family=249&mtag=programmable_network_adapters>
- Chelsio (cxgb4) - <https://www.chelsio.com/crypto-solution/>
- Intel (ixgbe / ixgbevf) - Intel 540 and 82599 Limited to 1024 sessions
  maximum and 128 IP address maximum -
  <https://blogs.oracle.com/linux/tips-and-tricks-for-ipsec-on-intel-10-gbe-nics-v2>
- Intel QuickAssist (QAT) -
  <http://dpdk.org/doc/guides/cryptodevs/qat.html>
- CAAM / NXP i.MX6 SoC -
  <http://events17.linuxfoundation.org/sites/events/files/slides/2017-02%20-%20ELC%20-%20Hudson%20-%20Linux%20Cryptographic%20Acceleration%20on%20an%20MX6.pdf>
- mediatek
- atmel
- Broadcom SPU driver
- Cavium Nitrox / Octeon-tx CPT Engine

# Obsoleted OCF Hardware Crypto Acceleration (KLIPS and XFRM)

In general, cryptographic acceleration is mostly useful for embedded and
low power systems. High end systems tend to have a CPU that is fast
enough, especially when using AES_GCM on a multi-CPU system with AESNI
support. Although if you are trying to get 5gbps or higher throughput,
you might want to use a dedicated crypto acceleration card on top of the
CPUs (such as the Intel QuickAssist PCIe)

There are a few methods for crypto hardware acceleration. The most
complete one is the Open Cryptographic Framework ("OCF"), a port of the
OpenBSD code. A newer more native implementation is the CryptoAPI async
interface. The latter implementation is still extremely limited. It does
not have as many drivers as OCF. But it just works without needing to do
anything on the system. There is also the pcrypt kernel module that uses
multiple CPUs for parallel processing.

Libreswan supports OCF using the KLIPS IPsec stack and using the
XFRM/NETKEY stack. The latter needs the OCF cryptosoft.ko kernel module.

On an IPsec gateway, almost all the encryption is done inside the kernel
when doing the actual IPsec encryption and decryption. The IKE
negotiations also use encryption, but since this only involves a few
packets per hour, there isn't really much point in accelerating these.
While some acceleration might be available to the userland, support for
that would be automatically enabled in the NSS crypto library when
supported. The overhead of sending IKE packets to the kernel accelerator
for encryption/decryption is not worth it and might actually slow things
down.

## OCF: Kernel and Userland crypto acceleration

OCF provides kernel crypto acceleration for IPsec (ESP and AH) as well
as userland crypto acceleration via the /dev/crypto interface. Libreswan
has removed OCF support for IKE, as the overhead is simply not worth the
efforts even on embedded systems. It also required OCF patches to the
TTY subsystem and thus an entire kernel recompile. If only kernel level
acceleration is needed, OCF can be build as a kernel module without
requiring a recompile of the entire base kernel. The userland
/dev/crypto interface can however be used by other userland based
applications that use openssl. For example, if the system also supports
OpenVPN, it will be very useful to have OCF userland support in openssl.

For more information about OCF, see
[ocf-linux.sourceforge.net](http://ocf-linux.sourceforge.net). To get an
idea of the crypto acceleration see these [OCF
benchmarks](http://ocf-linux.sourceforge.net/benchmarks.html)

## Supported hardware via OCF

- Safenet SafeXcel 1741 and SafeXcel 1142
- Intel IXP465, IXP425 and IXP422
- Freescale SEC (Talitos) (this is also the bsec driver used on Linksys
  WRT54g, AsusWL500g)
- PA Semi PWRficient DMA Crypto Engine
- Intel EP80579 (Intel QuickAssist enabled EP80579 Integrated Processor
  Product Line)
- PMC Sierra MSP-8520 (requires vendor-supplied source code for OCF)
- Cavium Octeon (requires vendor-supplied source code for OCF)
- Hifn 7951 and Hifn 7956

## Supported hardware via cryptosoft.ko kernel module

The OCF subsystem can interface with the XFRM Linux kernel crypto
acceleration system. It does so via the OCF *cryptosoft* kernel module.

- VIA Padlock (via cryptosoft)
- AMD Geode LX (via cryptosoft)
- SMP (multi-core) support (via cryptosoft)

## Supported algorithms and ciphers with libreswan

- 3DES and 1DES
- AES
- SHA1
- MD5

Note that SHA2 support for OCF with KLIPS is missing from the list!

Note that not all hardware implementations support all these algorithms
and ciphers. Libreswan no longer supports 1DES because it is too
insecure.

## SMP support

The Linux NETKEY/XFRM native IPsec stack does not load balance a single
IPsec SA over multiple CPU cores. Using the OCF cryptosoft driver, a
single IPsec SA can be offloaded over multiple CPU's

### Building libreswan with OCF support

Some OCF kernel builds are made available at
[libreswan.org](https://downloads.libreswan.org/), usually in the form
of source and binary .deb or .rpm packages. the kernel packages provided
support both kernel and userland OCF acceleration. You will also find
patched openssl packages there which can be used in combination with
openvpn to support hardware acceleration in userland.

### Building kernel only OCF support as a module for running kernel

    tar zxf ocf-linux-20120127.tar.gz
    cd ocf-linux-20120127/ocf
    make ocf_modules
    sudo make ocf_install
    OCF_DIR=`pwd`

You can test the OCF acceleration using a special benchmark module
called ofc-bench. This is a kernel module that performs benchmarking
when modprobe'd into the kernel. It will also fake an error to unload
itself

    modprobe ocf
    modprobe cryptosoft
    modprobe ocf-bench
    dmesg | tail -5

You should see something along the lines of:

    [  583.128741] OCF: 45133 requests of 1488 bytes in 251 jiffies (535.122 Mbps)

### Building KLIPS with OCF support

To build libreswan KLIPS with OCF support, instead of using *make
module*, use:

    make KBUILD_EXTRA_SYMBOLS=$OCF_DIR/Module.symvers \
         MODULE_DEF_INCLUDE=`pwd`/packaging/ocf/config-all.hmodules \
         MODULE_DEFCONFIG=`pwd`/packaging/ocf/defconfig \
         module
    sudo make KBUILD_EXTRA_SYMBOLS=$OCF_DIR/Module.symvers \
         MODULE_DEF_INCLUDE=`pwd`/packaging/ocf/config-all.hmodules \
         MODULE_DEFCONFIG=`pwd`/packaging/ocf/defconfig \
         minstall

### Building userland OCF support for IKE

OCF support for IKE has been removed, as it is faster to use the CPU
instruction support via the userland CPU instructions these days.
Support for those instructions come in via the NSS library that
libreswan uses. It has the advantage of not requiring a kernel patch.

### Generate the kernel patches and apply the appropriate one

If you want OCF random support, you cannot just build the ocf as module,
you also need to patch the kernel.

    cd ocf
    make patch

This will provide four files:

- linux-2.4-ocf.patch
- linux-2.6-ocf.patch
- linux-3.1-ocf.patch
- ocf-linux-base.patch

Depending on your kernel, pick the appropriate patch and apply it to
your kernel, for example for a 3.1 kernel use:

    cd linux-3.1
    patch -p1 < linux-3.1-ocf.patch

{{ ambox \| type = alert \| text = For Linux 2.4 kernels on non-x86, you
might need to issue: cp linux-2.X.x/include/asm-i386/kmap_types.h
linux-2.X.x/include/asm-YYY }}

To compile userland applications with OCF support, the cryptodev.h file
needs to be installed on the system, for example in
/usr/include/crypto/cryptodev.h

The OCF source code comes with openssl patches as well, please see the
OCF source for further instructions.

### How to load the OCF modules into the kernel

Libreswan comes with the *_stackmanager* script that loads all kernel
modules and sets various parameters. These include all the native
CryptoAPI acceleration modules. It does not auto-detect OCF support on
disk, so before starting _stackmanager, ensure that the system has
loaded the OCF core kernel module:

    modprobe ocf

Libreswan will detect OCF support and load the userland (cryptodev) and
software driver (cryptosoft)

To load any of the OCF hardware drivers, ensure you load the appropriate
hardware driver, eg one of:

    modprobe safe
    modprobe hifn7751
    modprobe ixp4xx
    ...

{{ ambox \| type = alert \| text = You might wish to change
_stackmanager to not load the cryptosoft module if you have native OCF
hardware driver support. In some cases the software driver has
accidentally gained preference over a hardware driver }}

### Debugging OCF

To enable debugging (which will ruin your acceleration gains!) you can
issue some of the following commands based on your hardware/software:

        echo 1 > /sys/module/ocf/parameters/crypto_debug
        echo 1 > /sys/module/cryptodev/parameters/cryptodev_debug
        echo 1 > /sys/module/cryptosoft/parameters/swcr_debug
        echo 1 > /sys/module/hifn7751/parameters/hifn_debug
        echo 1 > /sys/module/safe/parameters/safe_debug
        echo 1 > /sys/module/ixp4xx/parameters/ixp_debug

### OCF benchmarking

The ocf-bench driver accepts the following parameters:

\- request_q_len - Maximum number of outstanding requests to OCF -
request_num - run for at least this many requests - request_size - size
of each request (multiple of 16 bytes recommended) - request_batch -
enable OCF request batching - request_cbimm - enable OCF immediate
callback on completion

An example benchmark use:

    modprobe ocf-bench request_size=1024 request_cbimm=0
    dmesg |tail -5

### OCF KLIPS tuning

The following parameters are managed by _stackmanager but can be
changed to suit your specific need based on the hardware capabilities of
your platform:

- /sys/module/ocf/parameters/crypto_q_max
- /sys/module/ipsec/parameters/ipsec_irs_cache_allocated_max
- /sys/module/ipsec/parameters/ipsec_ixs_cache_allocated_max

Additional parameters that can be tuned manually:

- /sys/module/ocf/parameters/crypto_all_kqblocked
- /sys/module/ocf/parameters/crypto_verbose
- /sys/module/ocf/parameters/crypto_debug
- /sys/module/ocf/parameters/crypto_q_cnt
- /sys/module/ocf/parameters/crypto_userasymcrypto
- /sys/module/ocf/parameters/crypto_all_qblocked
- /sys/module/ocf/parameters/crypto_usercrypto
- /sys/module/ocf/parameters/crypto_max_loopcount
- /sys/module/ocf/parameters/crypto_devallowsoft

<!-- -->

- /sys/module/ipsec/parameters/ipsec_ocf_batch
- /sys/module/ipsec/parameters/ipsec_ocf_cbimm

#### ipsec_ocf_cbimm

The OCF layer will call back on completion immediately rather than
calling back from a work queue (softirq) context. Your callbacks need to
be very careful and re-entrant safe to use this mode. KLIPS is typically
safe to use in this mode.

#### ipsec_ocf_batch

Instruct OCF to batch requests if possible. Typically this should be
enabled.

# The (obsoleted) pcrypt kernel module

The pcrypt and tcrypt kernel module allows the Linux kernel CryptoAPI to
spread the crypto load of single IPsec SA's over multiple CPU's. If your
VPN server has many hunderds of IPsec connections, these will already be
spread out over the CPU's and pcrypt does not gain you much. However, if
you have only one or a few IPsec tunnels that run at a high capacity,
the pcrypt module might help you better use all your available CPU
power. Also, if you are looking at increasing the throughput, it is very
important to pick an ESP algorithm that is fast. Currently, AES_GCM
outperforms everything (including esp=null-md5 !!) so that should be the
algorithm used when trying to use pcrypt.

{{ ambox \| nocat=true \| type=speedy \| text = The pcrypt module is
VERY UNSTABLE. Please be careful. If you have stability tips, please let
us know at swan-dev@lists.libreswan.org }}

The documentation of the pcrypt / tcrypt module is very limited. The
pcrypt module has to be enabled per algorithm:

    modprobe pcrypt
    modprobe tcrypt alg="pcrypt(rfc4106(gcm(aes)))" type=3
    # optionally accelerate aes-sha1 and aes-sha2
    modprobe tcrypt alg="pcrypt(authenc(hmac(sha1),cbc(aes)))" type=3
    modprobe tcrypt alg="pcrypt(authenc(hmac(sha256),cbc(aes)))" type=3

Note that it has been reported that a system may crash if these commands
are activated before any IPsec tunnel has been established. Similarly,
we have reports that these commands must be run before starting any
tunnels or otherwise it crashes. And we have had reports that after
running the modprobe commands, the IPsec tunnel should be re-established
to activate the acceleration.

Using multiple CPU's can cause packets to become encrypted out-of-order.
It is important to either increase the replay-window to a value of 64 or
128, or to disable replay protection by setting replay-window to 0.

There is a tool called `crconf` that is supposed to make this easier,
but it seems to not be working for those who have tried to use it.
