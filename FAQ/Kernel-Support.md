Here's a brief list showing which kernel features are supported.

Since the feature may require modifications to both the kernel and
Libreswan, the version field can contain the following:

- `kN.M` is the first kernel to support the feature

- `vN.M` is the first Libreswan release to support the feature

  `v?.?` means that libreswan needs changes

- `YYYY` the year the feature was added to the kernel

Blank just means no one has tested this.

| RFC | Feature | Linux | FreeBSD | NetBSD | OpenBSD | Comments |
|-----|---------|-------|---------|--------|---------|----------|
||
| | ipsec interface | k4.19 <br/> 2018 | k11.1 <br/> 2017 | k8.0 <br/> 2018 | k7.4 <br/> 2023
| | ipsec-interface w/ IPv4+IPv6 through single SA | Yes | Yes | [**No**](https://gnats.netbsd.org/59070) | Yes |
| | All combinations of IPv4, IPv6, IPCOMP, TRANSPORT, TUNNEL | k6.3? | | [10.0](https://gnats.netbsd.org/56836) | |
| | Kernel NAT keepalive | Yes <br> v?.? | | | | Libreswan needs changes |
| | Hardware Offload (i.e., ConnectX-7) | Yes | 15.1 <br/> 2026 | No
| | Host-Host | Yes | v5.4 | v5.4 | v5.4 | Remember `vN.M` is the Libreswan version
||
| | **Kernel Algorithms**
| | AES_GCM | Yes | Yes | Yes | Yes
| | CHACHA | Yes | Yes | [**No**](https://gnats.netbsd.org/58726) | Yes
| [draft](https://datatracker.ietf.org/doc/html/draft-ietf-ipsecme-sha3-01) | Use of SHA-3 in the Internet Key Exchange Protocol Version 2 (IKEv2) and IPsec | | | | | It's comming
||
| | **Sequence Numbers and Sliding Windows**
| | ESP without sliding window | | | | | w/ Hardware it can be cheaper to decrypt packets
| [RFC 4302](https://datatracker.ietf.org/doc/html/rfc4303#appendix-B) | Appendix B: Extended (64-bit) Sequence Numbers (AH) | Yes | Yes | [**No**](https://gnats.netbsd.org/56588) | Yes |
| [RFC 4303](https://datatracker.ietf.org/doc/html/rfc4303#appendix-A) | Appendix A: Extended (64-bit) Sequence Numbers (ESP) | Yes | Yes | [**No**](https://gnats.netbsd.org/56588) | Yes |
| [RFC 6479](https://datatracker.ietf.org/doc/html/rfc6479) | IPsec Anti-Replay Algorithm without Bit Shifting | | | | | Interesting Idea
| | Large Sliding Window | Yes | Yes | **No** |
||
| [RFC 3948](https://datatracker.ietf.org/doc/html/3948) | UDP Encapsulation of IPsec ESP Packets | Yes | Yes | Yes | Yes
| [RFC 4302](https://datatracker.ietf.org/doc/html/rfc4302) | IP Authentication Header (AH) | Yes | Yes | Yes | Yes
| [RFC 4303](https://datatracker.ietf.org/doc/html/rfc4303) | IP Encapsulating Security Payload (ESP) | Yes | Yes | Yes | Yes
||
| [RFC 9329](https://datatracker.ietf.org/doc/html/rfc9329) | TCP Encapsulation of Internet Key Exchange Protocol (IKE) and IPsec Packets | k5.1 | | [**No**](https://gnats.netbsd.org/56869)
| [draft](https://datatracker.ietf.org/doc/html/draft-ietf-ipsecme-ikev2-reliable-transport/) | Separate Transports for IKE and ESP | | | | | Motivated by PQ
||
| [RFC 9347](https://datatracker.ietf.org/doc/html/rfc9347) | Aggregation and Fragmentation Mode for Encapsulating Security Payload (ESP) and Its Use for IP Traffic Flow Security (IP-TFS) | k6.14 | |
| [RFC 9478](https://datatracker.ietf.org/doc/html/rfc9478) | Labeled IPsec Traffic Selector Support for the Internet Key Exchange Protocol Version 2 (IKEv2) | Yes | | | | Does anyone care?
| [draft](https://datatracker.ietf.org/doc/html/draft-ietf-ipsecme-eesp) | Enhanced Encapsulating Security Payload (EESP)
