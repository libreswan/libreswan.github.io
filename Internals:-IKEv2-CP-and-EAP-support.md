CP without EAP.

This rather straight forward. But is it used? Useful? Does StrongSWAN
support it?

Design challenge pose to support EAP:

AUTH exchange has \[CP\] , TSi, TSr. When a receiver get these it reply
with EAP and goes off to EAP authentican. However, it must hang on to
\[CP\], TSi, TSr. And after the authentication respond to it. After EAP
is complete the initiator does not send TSi and TSr again.

<http://tools.ietf.org/html/rfc5996#section-2.15> vs
<http://tools.ietf.org/html/rfc5996#section-2.19>

Configuration names: In general there may be conflicts in functionality
between IKEv1 and IKEv2.

The username is called xauthusername in IKEv1. Is it appropriate to call
that in v2?

Also some of the IKEv1 option keywords have a specific meaning in IKEv1.
Does that work for v2? xauthby, xauthname, modecfgserver, xauthserver,
xauthclient, modecfgclient, modecfgpull, modecfgdns, modecfgdomains, and
modecfgbanner

May be a solution is first create a v2 only connection and then use new
names.

WPA Supplicant source code has ikev2 has eap_server_ikev2.c what is
that?

Cisco specific modeconfig

It seems CP Attribute types, RFC5996 3.15.1, is missing DOMAIN name.
However, CISCO prviate extensions has them.

<http://www.cisco.com/c/en/us/td/docs/ios-xml/ios/sec_conn_ike2vpn/configuration/xe-3s/sec-flex-vpn-xe-3s-book/sec-cfg-flex-serv.html>