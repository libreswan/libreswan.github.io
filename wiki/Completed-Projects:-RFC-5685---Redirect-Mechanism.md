## Introduction

[RFC 5685](https://tools.ietf.org/html/rfc5685) is a document that
specifies guidelines for usage of Redirect Mechanism for Internet Key
Exchange Version 2 (IKEv2). Basic idea is that responder peers should be
able to redirect the initiators to a new address. RFC suggests that the
main usage is intended for server-to-client architectures, where server
could (e.g. when he is going down for maintenance or is overloaded)
redirect clients to other servers.

Cisco, among the other vendors and implementations, supports this RFC
and has a nice explanation of the feature
[here](https://www.cisco.com/c/en/us/td/docs/ios-xml/ios/sec_conn_ike2vpn/configuration/xe-16-10/sec-flex-vpn-xe-16-10-book/sec-cfg-clb-supp.html).

## Implementation

To allow the use of Redirect Mechanism in IKEv2, the following main
changes were made:

- Two new source code files were created:
  *programs/pluto/ikev2_redirect.{h,c}*.

<!-- -->

- Added code in *programs/pluto/ikev2_parent.c* which deals with sending
  and processing of IKEv2 \*REDIRECT\* Notify payloads.

<!-- -->

- Code for reading connection and config options was updated.

<!-- -->

- Code for issuing dynamic whack commands was added.

<!-- -->

- New test cases were added. These can be found as ‘’ikev2-redirect-\*’’
  folders in testing/pluto/ directory.

## Configuring the IKEv2 Redirect Mechanism in libreswan

Four connection options are added for this mechanism:

- **send-redirect** - specifies whether to send REDIRECT payload in
  IKE_AUTH response when peer receives REDIRECT_SUPPORTED notification.
  Allowed values are yes (always send), no (never send) and auto (the
  default, redirect if in DDoS mode).

<!-- -->

- **redirect-to** - specify what address to put in REDIRECT payload,
  that is where to redirect the other end. Both IPv4 and IPv6 addresses
  are supported as well the FQDNs. Only one address should be specified.
  The value of this option is not considered if send-redirect is set to
  no.

<!-- -->

- **accept-redirect** - specify whether to send REDIRECT_SUPPORTED
  notification (and process incoming REDIRECT notifications) to the
  other end when we initiate IKEv2 exchange. Allowed values are yes
  (always send) and no (the default, never send).

<!-- -->

- **accept-redirect-to** - specify the address (or list of addresses)
  where we allow to be redirected to. Both IPv4 and IPv6 addresses are
  supported as well the FQDNs. The value %any, as well as not specifying
  any address, signifies that we will redirect to any address gateway
  sends us in REDIRECT Notify payload.

Examples:

       send-redirect=yes
       redirect-to=1.2.3.4

       accept-redirect=yes
       accept-redirect-to=1.1.1.1, 1.2.3.4, server.myserver.org

Two more options are added for config configuration:

- **global-redirect** - specifies whether to send REDIRECT payload in
  IKE_SA_INIT response when peer receives REDIRECT_SUPPORTED
  notification. Allowed values are yes (redirect all requests), no
  (don’t redirect at all) and auto (redirect if busy - in DDoS mode).

<!-- -->

- **global-redirect-to** - specify what address to put in REDIRECT
  payload, that is where to redirect the other end. Both IPv4 and IPv6
  addresses are supported as well the FQDNs. Since version 4.0 (14th
  October 2020), multiple addresses can be specified. In that case,
  server will go through them and redirect clients evenly to all
  specified addresses.

Examples:

    config setup
       global-redirect=on
       global-redirect-to=1.2.3.4

    config setup
       global-redirect=on
       global-redirect-to=1.2.3.4,5.6.7.8,9.10.11.12

**Redirect during an active session**

It is also possible to redirect peers (of specific connection) during an
active session (established IPsec tunnel). For that, the whack command
--redirect-to is used, possibly preceeded by --name <connection-name>,
followed by an address or list of addresses. If more than one address is
specified, the peers to be redirected will be redirected evenly to
specified addresses. If connection name is not specified, all active
peers on the server will be redirected.

Examples:

    ipsec whack --redirect-to 1.2.3.4                              # all active peers will be redirected to address 1.2.3.4

    ipsec whack --name myconn --redirect-to 1.2.3.4                # active peers of connection myconn will be redirected to address 1.2.3.4

    ipsec whack --redirect-to 1.2.3.4,5.6.7.8,9.10.11.12           # all active peers will be (evenly distributed) redirected to addresses 1.2.3.4,5.6.7.8,9.10.11.12

## Issues encountered

Combining new idea of redirection with network routing logic caused
significant problems.

## Future work

Things that would be nice to have:

1\. Figure out a way to enable/disable redirection of peers in
IKE_SA_INIT/IKE_AUTH reply based on multiple parameters.

Example: 'Redirect in IKE_SA_INIT all IKEv2 requests received between
2pm and 4pm to gateway X; redirect in IKE_AUTH all IKEv2 requests
(received between 1am and 3am AND peer certificate is issued by Y) to
gateway Z'

## Source code

Code status: merged in master branch, in the meantime it was refactored
and heavily improved by main developer D. Hugh Redelmeier.

Code commit can be found here:
<https://github.com/vukasink/libreswan/commit/cd4dda55fbd15372f1b115f5d9d38b05da6ac50e>

Test commit can be found here:
<https://github.com/vukasink/libreswan/commit/9de3fbf1ee2743e75dd362d52c9852defa6f3936>

The main developer of this feature is Vukasin Karadzic. Work on this
project was done under the mentorship of Paul Wouters and sponsored by
Google as part of Google Summer of Code 2018 Program.