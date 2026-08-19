# Introduction

Most IPsec deployments fall into two types of deployment. The first type
is the Remote Access, where roaming users (phones, laptops) connect to
the corporate network. The second type of IPsec network is where two or
more IPsec gateways connects different networks together. Both of these
types of deployment use encryption only to encrypt the part of the
network that is considered to be using the public internet. These type
of deployments are called "static tunnels" or "roadwarrior tunnels". The
configuration of these deployments is simple. Both endpoints are
preconfigured to accept each other's credentials.

The goal of enterprise cloud encryption (also called mesh encryption) is
to encrypt all traffic between all the nodes, without using dedicated
IPsec gateways. This elliminates all plaintext traffic on a given
network or cloud. These deployments are very dynamic. If the network
contains thousands of hosts, where only some hosts communicate to some
other hosts. In modern cloud deployments, these hosts also vary.
Depending on the demand, servers are continiously added and removed from
the network. Therefore, the classic configuration of each host having a
configuration for all other hosts does not work. Even if one would use
automated tools like puppet or ansible, adding a new host should not
require all other hosts to have their IPsec configuration updated before
they can communicate with the newly added host.

Traditionally, libreswan calls these type of dynamic configurations
"opportunistic". This goes back to the FreeS/WAN days in the late
nineties. Each node is configured to intercept all unencrypted traffic.
Once an unencrypted packet is seen by the kernel, the kernel will notify
the userland IKE daemon so it can attempt to setup an IPsec connection
to the remote IP address. Once this tunnel policy is in place, the
kernel will allow the packets to out encrypted. There are various tuning
options to allow for different service levels. For example, it is
possible to insist that some network ranges always have encryption, or
never have encryption. Or encryption to some networks can be optional.

{{ ambox \| nocat=true \| type=speedy \| text = The methods of
configuring various aspects of Opportunistic IPsec are still subject to
change }}

# The basic configuration

Currently, libreswan supports a few different groups of connections:

- private - Traffic to these networks must be encrypted
- private-or-clear - Traffic should be encryped but may happen in the
  clear
- clear-or-private - Traffic per default will go in the clear, but if
  the remote endpoint negotiates encryption that is accepted
- clear - No encryption will ever be allowed and all traffic happens in
  the clear
- block - No traffic, clear or encrypted, is allowed to these
  destinations

To add a certain network range to one of these policies, simple add them
in CIDR notation to the names files in /etc/ipsec.d/policies/. To enable
mandatory encryption for all nodes within 10.0.0.0/8, simply add
"10.0.0.0/8" on a line by itself to the file
/etc/ipsec.d/policies/private

The above named policies must be created as "regular" IPsec connections
within libreswan. This is done by placing a configuration file in
/etc/ipsec.d/\*.conf. You can find some examples in the source tree in
the
[doc/examples](https://github.com/libreswan/libreswan/tree/master/docs/examples)
directory. Specifically look at the oe-\* prefixed files.

For example, when using X.509 certificates, the "private" connection
would look something like:

    # example for /etc/ipsec.d/private.conf
    conn private
        leftid=%fromcert
        leftrsasigkey=%cert
        # nickname of your certificate imported to NSS
        leftcert=example-123.libreswan.org
        left=%defaultroute
        #
        right=%opportunisticgroup
        rightid=%fromcert
        rightrsasigkey=%cert
        #
        authby=rsasigkey
        negotiationshunt=hold
        failureshunt=drop
        type=tunnel
        ikev2=insist
        sendca=issuer
        auto=add

And the policy files in /etc/ipsec.d/policies/ would look like:

    # /etc/ipsec.d/policies/private
    10.0.0.0/8

    # /etc/ipsec.d/policies/clear
    0.0.0.0/0

Currently, libreswan orders these CIRD networks based on "longest prefix
first", meaning the more specific and thus smaller the network range,
the higher the priority.

When starting libreswan with this configuration, an IPsec policy will be
installed in the kernel to "trap" any packets destined for IP addresses
covered by entries in /etc/ipsec.d/policies/private, and libreswan will
attempt to setup an IPsec tunnel to those IP addresses. If this fails,
it will drop the traffic to prevent cleartext packet leaks. In the time
that the IPsec connection is being negotiated, packets are held to
prevent cleartext leaks.

# An IP address is not a certified identifier

One issue is that any IPsec connection that is triggered by a packet
needs to be authenticated using only the source and destination IP
address. Even if certificates are exchanged, a server in the cloud
cannot tell if that certificate belongs to that IP address. In the next
release, libreswan will add an additional DNS lookup of the name
specified by the received certificate to see if the DNS entry for that
name has a proper address (A or AAAA) record to the IP that gave us the
certificate. If this DNS domain is properly DNSSEC signed, we have some
certainty that this host is really who they claim to be.

# Authentication methods

The following authentication methods are planned to be supported with
cloud encryption via Opportunistic IPsec:

- X.509 certificates (mutual authentication - the method described
  above)
- Single side X.509 certificates (eg LetsEncrypt, where client
  authenticates the server, but the server does not authenticate the
  client)
- GSSAPI / Kerberos (mutual authentication)
- DNSSEC based (mutual or single sided)
- DNSSEC via Reverse DNS (mutual or single sided)

# Lets Encrypt

As of libreswan-3.119 there is support for single sided certificate
authentication that can be used with LetsEncrypt or any other public CA.
It also supports NAT-Traversal, so that this can be used by roaming
clients (laptops, phones) that are often behind NAT. For details, see
[HOWTO: Opportunistic IPsec using
LetsEncrypt](/HOWTO/Opportunistic-IPsec-using-LetsEncrypt)