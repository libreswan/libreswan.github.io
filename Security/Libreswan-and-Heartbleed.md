## Is Libreswan vulnerable to the OpenSSL "Heartbleed" exploit?

Libreswan is **NOT** vulnerable to the openssl vulnerability
CVE-2014-0160 known as Heartbleed.

Libreswan is an implementation of IPsec IKEv1 and IKEv2 keying
protocols. These protocols do not use TLS to establish VPN connections.
VPN services and products based on TLS are often called "SSL VPNs".
Libreswan is an IKE/IPsec based VPN.

Libreswan does not use openssl for IKE/IPsec. Libreswan does use libcurl
which itself uses openssl for establishing connections for OCSP and CRL
URLs, but it does not provide a server for OCSP/CRL and is therefor not
vulnerable there either.