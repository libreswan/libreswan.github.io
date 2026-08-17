This GSOC 2017 project aimed at implementing the RFC 8229 - TCP
Encapsulation of IKE and IPsec Packets. According to this, support was
added for TCP encapsulation of packets in Pluto(Libreswan IKE daemon) to
route out of stringent networks allowing only TCP traffic.

## Introduction

The RFC was in the draft stage when the project was started, but as of
now, has been accepted as RFC 8229. There weren't any major changes
between the draft and the final RFC. The problem addressed is that when
UDP is blocked on networks behind strict NATs, IKE should fall back to
using TCP encapsulation and route out. The RFC specifies various
standards for implementing this. It was ensured that the MUSTs in the
RFC are implemented, so that Libreswan could be used as a client or a
server with other standard implementations. Important thing to note is
that kernel changes are yet to be made, so as of now Pluto ends up just
negotiating the IPsec SA details, but installs an ESP/ESPinUDP SA. Three
new ipsec.conf parameters were introduced and they direct the
implementation of these changes:-

1.  listen-tcp: The TCP port to listen on. TCP will keep listening on
    the port number specified in this option. The default value is 0,
    indicating not to open any TCP ports for listening. Any specified
    port other than 0 means listen on that port number.
2.  tcp-remoteport : The remote port number to which the TCP connection
    will be initiated . This option is set to 0 by default indicating
    that TCP encap is not enabled and IKE shouldn't fall back to TCP.
    Any specified port other than 0 means initiate a TCP connection to
    that port number.
3.  tcponly : Use TCP encapsulation immediately when connection goes up.
    This makes sure Pluto doesn't even try over UDP. The default value
    is **no**. Acceptable values are **no** and **yes**.

The last two are per conn options to be defined in a connection on the
client side when required.

## Implementation

These features have been implemented during the project duration:-

- Add the above options in ipsec.conf for enabling TCP encapsulation
- On the client, Fall back to trying TCP if UDP fails or directly try
  TCP if tcponly option is there
- On the server, create a TCP socket and keep listening on it for
  connections
- Send a stream prefix at the start of a new connection
- Add a TCP packet length field in the header
- Create bufferevents and set their read, write and event callbacks as
  necessary.

All the listening, receiving and sending logic for TCP was implemented
using callbacks in libevent's evconnlistener and bufferevent structures.
Some core structures had to be updated to have new members. Few new test
cases were added specific to these changes. The different test cases
test different functionalities - fallback to TCP from UDP, direct TCP,
NAT and rekey.

A side task was adding of IPsec policy holes for IKE packets. Pluto
initially used socket bypass options for these, but now bypass policies
are added for the IKE ports and also for ICMPv6 neighbor discovery
packets.

Some extras in the RFC that weren't implemented due to time and
difficulty constraints:-

- Kernel support. This will be done by the kernel people and when this
  happens, a few changes will have to be made to Libreswan for this.
- Listening on multiple TCP ports. This isn't a very difficult
  implementation but since the basics were being addressed as of now,
  this can be tackled easily later
- TLS support. Again time constraints were there for this to be
  implemented.
- Probing over UDP even after TCP is established, so that Pluto can
  ditch the TCP connection and go back to UDP improving performance.
- MOBIKE support, it has yet to be implemented in Libreswan as well

These things comprise the future tasks that could be implemented to have
a robust support for TCP.

The current implementation successfully interoperated with an unreleased
implementation by Apple Inc.

## Code Changes

All the relevant changes were made in three commits:

1.  [All the changes for RFC
    implementation](https://github.com/mtotale/libreswan/commit/45ab9e00d76dad5950433c06ea9f5bb817e646fc)
2.  [The test cases for these
    changes](https://github.com/mtotale/libreswan/commit/19c1948841b3cec35e5f0fa9cc8344be7a2e3f10)
3.  [Changes for adding IPsec bypass
    policies](https://github.com/mtotale/libreswan/commit/5f1550b55b08d1c31f7b6d9335cadc946c49517e)

This project was done by Mayank Totale(mtotale@gmail.com) as a part of
his Google Summer of Code, under the guidance of Paul Wouters.