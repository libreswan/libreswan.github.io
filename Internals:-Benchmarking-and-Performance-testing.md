The performance of an IPsec system depends on CPU, RAM, NICs, switches,
kernel and configuration.

{{ ambox \| nocat=true \| type=important \| text = All tests were
performed using a network MTU setting of 9000 unless otherwise noted.
This is crucial when using 10GigE cards!}}

Note that the settings of the NIC and the settings for Replay Protction
(replay-window=) can greatly influence performance. It might be useful
to disable Replay Protection using replay-window=0 or to set it to a
very large value (eg 2048)

## The Alteeve Niche's Anvil RN2-M2 platform

Hardware used for this testing was supplied by [Alteeve
Niche's](https://alteeve.ca/).

The platform is based on a set of Fujitsu RX300 S8 servers
([specification](https://alteeve.ca/c/images/documents/AN%20Datasheet%20121001.pdf))
The machine has a number of Intel Corporation 82599ES 10-Gigabit cards
that are bonded. All NICs are connected to a set of Brocade ICX6610-24
switches. We picked one bonded pair of 10Gbps on interface bond1 for our
IPsec tests. The Anvil comes with an 8 core Intel(R) Xeon(R) CPU E5-2637
v2 @ 3.50GHz with AES-NI support. The MTU was left at the default 9k
setting. The kernel used was 2.6.32-504.1.3.el6.x86_64.

### IPsec performance measured with iperf

iperf used with default settings

- 9.78 Gbits/sec unencrypted without IPsec

<!-- -->

- 5.25 Gbits/sec IPsec AES_GCM128 (esp=aes_gcm128-null)

<!-- -->

- 1.78 Gbits/sec IPsec NULL-SHA1 (esp=null-sha1)

<!-- -->

- 1.19 Gbits/sec IPsec NULL-AES_XCBC (esp=null-aes_xcbc)

<!-- -->

- 1.39 Gbits/sec IPsec AES128-SHA1 (esp=aes128-sha1)

<!-- -->

- 1.27 Gbits/sec IPsec AES256-SHA1 (esp=aes256-sha1)

<!-- -->

- 904 Mbits/sec IPsec AES256-AES_XCBC (esp=aes256-aes_xcbc)

<!-- -->

- 197 Mbits/sec IPsec 3DES-SHA1 (esp=3des-sha1)

We did some additional tests, but those are less accurate. using
protoport= we could use multiple IPsec SA's (in the hope that it would
distribute better) or have encrypted and unencrypted streams going.

- two streams, one plaintext 8.64 Gbits/sec plaintext plus 1.24
  Gbits/sec AES256-SHA1

<!-- -->

- two streams AES256-SHA1: 819 Mbits/sec plus 615 Mbits/sec (possibly
  was aes128)

{{ ambox \| nocat=true \| type=important \| text = We were surprised
that using an AEAD operation versus an NULL-ENCR+INTEG would cause such
slowdown - use AES_GCM when you can!}}

### CPU/crypto performance measured with openssl

(AES-NI disabling done via *export OPENSSL_ia32cap=~0x200000200000000*)

Without AES-NI, no multi: openssl speed -evp aes-256-cbc

type 16 bytes 64 bytes 256 bytes 1024 bytes 8192 bytes

aes-256-cbc 241508.56k 266220.03k 273663.06k 276314.11k 275479.81k

With AES-NI, no multi: openssl speed -evp aes-256-cbc

type 16 bytes 64 bytes 256 bytes 1024 bytes 8192 bytes

aes-256-cbc 502470.66k 528580.69k 532890.45k 535901.87k 536368.47k

Without AES-NI, no multi: openssl speed -evp aes-128-cbc

type 16 bytes 64 bytes 256 bytes 1024 bytes 8192 bytes

aes-128-cbc 320425.43k 366515.97k 377561.00k 383643.99k 383777.51k

With AES-NI, no multi: openssl speed -evp aes-128-cbc

type 16 bytes 64 bytes 256 bytes 1024 bytes 8192 bytes

aes-128-cbc 688604.26k 732936.83k 742459.28k 748241.92k 748756.99k

Without AES-NI, using all cores : openssl speed -multi 8 -evp
aes-256-cbc

evp 3729202.24k 4009617.79k 4053305.43k 4065434.97k 4068764.33k

With AES-NI, using all cores : openssl speed -multi 8 -evp aes-128-cbc

evp 5033772.55k 5494390.59k 5632183.30k 5668856.15k 5679707.48k

### NIC settings

    #ethtool eth1
    Settings for eth1:
        Supported ports: [ FIBRE ]
        Supported link modes:   10000baseT/Full
        Supported pause frame use: No
        Supports auto-negotiation: No
        Advertised link modes:  10000baseT/Full
        Advertised pause frame use: No
        Advertised auto-negotiation: No
        Speed: 10000Mb/s
        Duplex: Full
        Port: Other
        PHYAD: 0
        Transceiver: external
        Auto-negotiation: off
        Supports Wake-on: umbg
        Wake-on: g
        Current message level: 0x00000007 (7)
                       drv probe link
        Link detected: yes

    # ethtool -k eth1
    Features for eth1:
    rx-checksumming: on
    tx-checksumming: on
        tx-checksum-ipv4: on
        tx-checksum-unneeded: off
        tx-checksum-ip-generic: off
        tx-checksum-ipv6: on
        tx-checksum-fcoe-crc: on [fixed]
        tx-checksum-sctp: on [fixed]
    scatter-gather: on
        tx-scatter-gather: on
        tx-scatter-gather-fraglist: off [fixed]
    tcp-segmentation-offload: on
        tx-tcp-segmentation: on
        tx-tcp-ecn-segmentation: off
        tx-tcp6-segmentation: on
    udp-fragmentation-offload: off [fixed]
    generic-segmentation-offload: on
    generic-receive-offload: on
    large-receive-offload: on
    rx-vlan-offload: on
    tx-vlan-offload: on
    ntuple-filters: on
    receive-hashing: on
    highdma: on [fixed]
    rx-vlan-filter: on [fixed]
    vlan-challenged: off [fixed]
    tx-lockless: off [fixed]
    netns-local: off [fixed]
    tx-gso-robust: off [fixed]
    tx-fcoe-segmentation: on [fixed]
    tx-gre-segmentation: off [fixed]
    tx-udp_tnl-segmentation: off [fixed]
    fcoe-mtu: off [fixed]
    loopback: off [fixed]

## IBM x3550m4

[Specifications from
IBM](http://www-03.ibm.com/systems/x/hardware/rack/x3550m4/specs.html)

- 12x Intel(R) Xeon(R) CPU E5-2630 0 @ 2.30GHz
- 32GB RAM
- Intel Corporation Ethernet Controller 10-Gigabit X540-AT2 (rev 01)
  cross cabled using ixgbe eth0: NIC Link is Up 10 Gbps, Flow Control:
  RX/TX
- MTU set to 9000 unless specified otherwise
- RHEL 6.6 running 2.6.32-504.el6.x86_64
- AESNI supported and used for all IPsec operations

### IPsec performance measured with iperf

iperf used with default settings

- 9.41 Gbits/sec unencrypted without IPsec
- 4.03 Gbits/sec IPsec AES_GCM128 (esp=aes_gcm128-null)
- 903 Mbit/sec IPsec AES_GCM128 (esp=aes_gcm128-null) on MTU 1500
- 1.26 Gbits/sec IPsec NULL-SHA1 (esp=null-sha1)
- 733 Mbits/sec IPsec NULL-AES_XCBC (esp=null-aes_xcbc)
- 643 Mbits/sec IPsec AES128-SHA1 (esp=aes128-sha1) at MTU 1500
- 935 Mbits/sec IPsec AES128-SHA1 (esp=aes128-sha1)
- 870 Mbits/sec IPsec AES256-SHA1 (esp=aes256-sha1)
- 656 Mbits/sec IPsec AES256-AES_XCBC (esp=aes256-aes_xcbc)
- 127 Mbits/sec IPsec 3DES-SHA1 (esp=3des-sha1)
- 1.10 Gbits/sec IPsec AES128_CTR-SHA1 (esp=aes_ctr128-sha1)
- 919 Mbits/sec IPsec AES256_CTR-SHA1 (esp=aes_ctr256-sha1)

### CPU/crypto performance measured with openssl

(AES-NI disabling done via export OPENSSL_ia32cap=~0x200000200000000)

Without AES-NI, no multi: openssl speed -evp aes-256-cbc

type 16 bytes 64 bytes 256 bytes 1024 bytes 8192 bytes

aes-256-cbc 181371.98k 202129.30k 207514.37k 208667.99k 210778.24k

With AES-NI, no multi: openssl speed -evp aes-256-cbc

type 16 bytes 64 bytes 256 bytes 1024 bytes 8192 bytes

aes-256-cbc 369217.05k 390857.40k 393860.01k 394961.58k 395264.00k

Without AES-NI, no multi: openssl speed -evp aes-128-cbc

type 16 bytes 64 bytes 256 bytes 1024 bytes 8192 bytes

aes-128-cbc 231156.81k 275887.45k 285929.05k 289998.17k 293098.25k

With AES-NI, no multi: openssl speed -evp aes-128-cbc

type 16 bytes 64 bytes 256 bytes 1024 bytes 8192 bytes

aes-128-cbc 506361.18k 542297.64k 549176.92k 551389.53k 553905.23k

Without AES-NI, using all cores : openssl speed -multi 11 -evp
aes-256-cbc

evp 1101164.44k 1207916.80k 1230362.03k 1242882.62k 1242842.52k

With AES-NI, using all cores : openssl speed -multi 11 -evp aes-128-cbc

evp 3918149.13k 5065989.57k 5471001.60k 5583504.38k 5609387.35k

### NIC settings

    # ethtool eth0
    Settings for eth0:
        Supported ports: [ TP ]
        Supported link modes:   100baseT/Full
                                1000baseT/Full
                                10000baseT/Full
        Supported pause frame use: No
        Supports auto-negotiation: Yes
        Advertised link modes:  100baseT/Full
                                1000baseT/Full
                                10000baseT/Full
        Advertised pause frame use: No
        Advertised auto-negotiation: Yes
        Speed: 10000Mb/s
        Duplex: Full
        Port: Twisted Pair
        PHYAD: 0
        Transceiver: external
        Auto-negotiation: on
        MDI-X: Unknown
        Supports Wake-on: d
        Wake-on: d
        Current message level: 0x00000007 (7)
                       drv probe link
        Link detected: yes

## x86_64 NUMA Xeon with Intel QuickAssist PCIe

This RHEL7 Xeon system has 6 Xeon E5-2630 CPU's @ 2.60GHz. The NIC is
a 10Gbps Intel 82599ES with 6 RSS channels (ixgbe). The interesting
bit about this system is that is uses a [Intel QuickAssist
PCIe](https://www-ssl.intel.com/content/www/us/en/ethernet-products/gigabit-server-adapters/quickassist-adapter-for-servers.html)
crypto accelerator card. This device shows up in lspci as "Intel
Corporation Coleto Creek PCIe Endpoint". The kernel modules for this
card required are the *icp_qat_netkey.ko* and *icp_qa_al.ko* modules.

The system seems to max out at about 7Gbps IPsec traffic using
AES_CBC. The accelerator does not support AES_GCM, so using AES_GCM
caused a reduction in performance. It used between 10-20 IPsec SA's at
once. Without the QuickAssist card, the performance is only half -
around 3 Gbps.

It was noticed that only two CPU's are loaded without moving load onto
further CPU's. The XFRM crypto implementation uses a single workqueue
for encrypt and a single workqueue for decrypt, resulting in seeing two
CPUs pinned on SoftIRQ processing. Therefor adding more IPsec SA's to
distribute the crypto load over the other CPU's has no effect - the
limitation is in the decapsulation that for a single IPsec SA is always
limited to a single CPU.

The pcrypt kernel module adds more work queues distributed over more
CPU's, but does not actually improve the performance. The problem is
that a lot of packets then arrive out of order and with the IPsec reply
protection with a standard replay-window it actually reduces the overall
throughput. (and it seems Linux currently doesn't allow setting a
replay-window \> 32)