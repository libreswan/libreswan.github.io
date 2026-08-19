## Current Network Topology

### Network:

Each host and network is assigned a unique number:

|          |    |           | RENAME TO | contains | Notes |
|----------|----|-----------|-----------|----------|-------|
| DARKNET  |  1 | 198.18.1  |           | rise set | it's dark between sunset and sunrise
| INTERNET |  2 | 192.1.2   | 198.18.2  | nic east west | Owned by: raytheon.com
| NICNET   |  3 | 192.1.3   | 198.18.3  | nic north road | Owned by: raytheon.com
| NORTHNET | 66 | 198.18.66 |           | north pole | inside the arctic circle
| EASTNET  | 20 | 192.0.2   | 198.18.20 | east rise | Rename TEST-NET-1; .23 is the ipsec interface subnet
| WESTNET  | 40 | 192.0.1   | 198.18.40 | west set | Owned by: elevatedcomputing.com; .45 ipsec interface subnet

| Host | IP suffix |
|------|-----------|
| EAST | 23
| WEST | 45
| RISE | 12
| SET  | 15
| POLE | 90
| NIC  | 254
| ROAD | 209

The test framework tries to use the benchmarking network
`198.18.0.0/15`.  It's divided into:

- 198.19/16: gateway to the web
  + assigned to `swandefault`
  + handed out using DHCP

- 198.18/16: is available for internal networks

  + `198.18.N.N/24` and `2001:db8:N::N/64` are used for ipsec
  interfaces

  + `198.18.?.N/24` and `2001:db8:?::N/64` are used as host interfaces

  + `198.18.?.254/24` and `2001:db8:?::254/64` are used for EAST's,
  WEST's, NIC's, and NORTH's private networks

Unfortunately it also uses several assigned address ranges (see below)
which needs to be fixed.

See [Special-Purpose IP Address
Registries](https://www.rfc-editor.org/rfc/rfc6890):

- [IPv4 Address Blocks Reserved for
  Documentation](https://www.rfc-editor.org/rfc/rfc5737) reserves
  192.0.2.0/24 (TEST-NET-1), 198.51.100.0/24 (TEST-NET-2), and
  203.0.113.0/24 (TEST-NET-3)

  + with `/24` or 256 addresses each, these ranges are too small; just
  `swandefault` hands out 1000s of addresses.

- [IPv6 Address Prefix Reserved for
  Documentation](https://www.rfc-editor.org/rfc/rfc3849) reserves
  2001:DB8::/32

  + already in use, ya!

- [Benchmarking Methodology for Network Interconnect
  Devices](https://www.rfc-editor.org/rfc/rfc2544) reserves
  198.18.0.0/15.

  + where we're going

### File access:

- the Linux domains use 9p

- the BSD domains use NFS to access the HOST via an extra bonus
  interface

### Host naming

- the Linux domains (except Alpine) use kernel systemd boot parameters

- the rest use boot scripts

### Default routes

- the `<`, `>`, `^` and `v` characters point towards the default route
  typically in the direction of NIC

### The Diagram

```
LEFT                                                              RIGHT

                           POLE--(eth1)198.19/16
                          (eth0)
                  2001:db8:66::90/64
                    198.18.66.90/24
                            |
                            v
198.18.66.0/24 -------------+----NORTHNET---------+---- 2001:db8:66::/64
                                                  v
                                                  |
                                      2001:db8:66::254/64
                                         198.18.66.254/24
                                                (eth0)
                 ROAD-[eth1]                    NORTH-[eth2]
                (eth0)                          (eth1)
     2001:db8:1:3::209/64            2001:db8:1:3::33/64  Owned by: raytheon.com
           192.1.3.209/24                  192.1.3.33/24  Owned by: raytheon.com
       2001:db8:3::209/64              2001:db8:3::33/64  NEW
          198.18.3.209/24                 198.18.3.33/24  NEW
                  |                               |
                  v                               v
192.1.3.0/24 -----+-----NICNET-----+----NICNET----+---- 2001:db8:1:3::/64  Owned by: raytheon.com
198.18.3.0/24 ----+-----NICNET-----+----NICNET----+------ 2001:db8:3::/64  NEW
                                   v
                                   |                                                  
                      2001:db8:1:3::254/64  Owned by: raytheon.com
                            192.1.3.254/24  Owned by: raytheon.com
                        2001:db8:3::254/64  NEW
                           198.18.3.254/24  NEW
                                 (eth2)
                                  NIC-[eth0]
                                 (eth1)
                      2001:db8:1:2::254/24  Owned by: raytheon.com
                            192.1.2.254/64  Owned by: raytheon.com
                        2001:db8:2::254/24  NEW
                           198.18.2.254/64  NEW
                                   |
                                   ^
192.1.2.0/24 -----+----------------+------INTERNET------+----- 2001:db8:1:2::/64  Owned by: raytheon.com
198.18.2.0/24 ----+----------------+------INTERNET------+------- 2001:db8:2::/64  NEW
                  ^                                     ^
                  |                                     |                         
     2001:db8:1:2::45/64                   2001:db8:1:2::23/64  Owned by: raytheon.com
           192.1.2.45/24                         192.1.2.23/24  Owned by: raytheon.com
       2001:db8:2::45/64                     2001:db8:2::23/64  NEW
          198.18.2.45/24                        198.18.2.23/24  NEW
               (eth1)                                (eth1)
         [eth2]-WEST-(ipsec)198.18.45.45/24    [eth2]-EAST-(ipsec)198.18.23.23/24
               (eth0)    2001:db8:45::45/64          (eth0)    2001:db8:23::23/64
     2001:db8:0:1::254/64                  2001:db8:0:2::254/64   Owned by: raytheon.com
           192.0.1.254/24                        192.0.2.254/24    Owned by: raytheon.com
      2001:db8:40::254/64                    2001:db8:2::254/64  NEW
         198.18.40.254/24                      198.182.2.254/24  NEW
                  |                                     |
                  |                                     ^
                  |       192.0.2.0/24 --EASTNET--------+-+---- 2001:db8:0:2::/64 Rename TEST-NET-1:
                  |       198.18.20.0/24 --EASTNET------+-+---- 2001:db8:20::/64  NEW
                  |                                       ^
                  ^                                       |
192.0.1.0/24 -----+-+- WESTNET--- 2001:db8:0:1::/64       |                       Owned by: elevatedcomputing.com
198.18.40.0/24 ---+-+- WESTNET--- 2001:db8:40::/64        |
                    ^                                     |
                    |                                     |
       2001:db8:0:1::15/64                   2001:db8:0:2::12/64   Owned by: elevatedcomputing.com TEST-NET-1
             192.0.1.15/24                         192.0.2.12/24   Owned by: elevatedcomputing.com TEST-NET-1
        2001:db8:40::15/64                    2001:db8:20::12/64   NEW
           198.18.40.15/24                       198.18.20.12/24   NEW
                 (eth1)                                (eth1)
            [eth2]-SET-(ipsec)198.18.15.15/24    [eth2]-RISE-(ipsec)198.18.12.12/24
                 (eth0)    2001:db8:15::15/64          (eth0)     201:db8:12::12/64
         2001:db8:1::15/64                     2001:db8:1::12/64
            198.18.1.15/24                        198.18.1.12/24
                    |                                     |
198.18.1.0/24 ------+-----------DARKNET-------------------+----- DARKNET -- 2001:db8:1::/64  (OK)
```

### Additional old diagrams

#### Hand sketch of network

![Hand Sketch of the Test Network](/images/Testnet-sketch.png)

#### Older diagram

![Network Diagram](/images/Testnet-20201027.png)

![Also](/images/Testnet-20240524.png)

#### FreeSWAN's Test Network

![FreeSWAN Network Diagram](/images/Testnet-FreeSWAN.png)

[FreeSWAN Network FIG](/images/Testnet-FreeSWAN.fig)