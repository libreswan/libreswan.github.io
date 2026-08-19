## Opportunistic IPsec

The term Opportunistic IPsec is used to describe IPsec deployments
that cover a large number of hosts using a single simple configuration
on all hosts. Adding hosts do not require reconfiguration of all
existing hosts. This concept can be used in an Enterprise or Cloud
model, but can also be applied to the Internet at large. To use
Opportunistic IPsec at an internet scale, see [HOWTO: Opportunistic
IPsec using
LetsEncrypt](/HOWTO/Opportunistic-IPsec-using-LetsEncrypt).  This
HOWTO describes the Enterprise or Cloud deployment, sometimes also
called Mesh Encryption"

## How it works

Libreswan defines Opportunistic Groups that specify if network ranges
MUST, SHOULD, MAY or MUST NOT be encrypted. When a host within such a
group wants to communicate to another host in the group, libreswan
attempts to setup an IPsec tunnel.

### Triggers

There are two main triggers for this:

- DNS based triggers

This mode intercepts the application's DNS lookup, attempts to setup a
tunnel, and then releases the DNS answer to the application. This mode
is currently being developed for the 3.20 release.

- Packet based triggers

This mode installs packet based policies into the kernel. When a host
wants to send a packet to another host in the group, the kernel will
notify libreswan to attempt to negotiate a tunnel. Once the tunnel is
established, the traffic for the target host is allowed to go out
encrypted. If the tunnel fails, the traffic will either be blocked or is
allowed to pass in the clear, depending on the policy for the target
host.

### Authentication

Any regular IKEv2 authentication method can be used for Opportunistic
IPsec, as these connections are regular libreswan configurations, except
for the **right=%opportunisticgroup** entry that defines the connection
for Opportunistic IPsec. A common authentication method it for hosts to
authenticate each other based on X.509 certificates using a commonly
shared Certificate Authority. That is the method this HOWTO will use, as
cloud deployments usually already roll out certificates for each node in
the cloud.

PreSharedKey (PSK) authentication is possible, but not recommended as
one compromised host would result in group PSK secret being compromised
as well. Although a NULL Authentication based authentication method can
be used to deploy encryption between nodes even without authentication.
This mode still protects against passive attackers.

### Opportunistic connections

There are currently five built-in connection groups that are defined for
different policies. Each of these has a connection ("conn") entry in
ipsec.conf and a file in /etc/ipsec.d/policies/ that lists the members
in this group.

- conn private

Hosts in this group can only communicate encrypted and no cleartext is
allowed. If the tunnel fails to establish, traffic is dropped

- conn private-or-clear

Hosts in this group will attempt to communicate encrypted, but will
allow cleartext if the other end does not support IPsec. During the
tunnel negotiation, traffic can be helt or passed in cleartext.

- conn clear-or-private

Hosts in this group not attempt to initiate IPsec for encrypted
communication, but will accept incoming requests.

- conn clear

Hosts in this group will never initiate or accept IPsec and only
communicate in the clear.

- conn block

Hosts in this group are completely blocked. It is similar to using a
firewall rule to drop all traffic. This group is a legacy group and
usually not in use.

At the moment, these connection names MUST be used. Future versions of
libreswan will allow custom group names.

### NAT

NAT is supported, but there is a catch. Pre-NAT IP's cannot be trusted.
For example, imagine a cloud that uses 8.8.8.0/24 and has a client on
8.8.8.8. If this client would setup an Opportunistic IPsec connection,
it would present itself as 8.8.8.8 (The IP address of Google DNS). The
responding IPsec server would build up a tunnel to this client using
8.8.8.8. If it had been configured to use Google DNS, this client would
now start receiving all of the server's Google DNS traffic. For that
reason, if an incoming client is detected to be behind NAT, the server
assigns the client an IP address from its pool. The client will map this
IP address inside its IPsec subsystem so that it does not need to
configure the given IP address on a real interface. It also allows the
client to connect to multiple servers and receiving the same IP address
without causing a conflict.

Configurations in this HOWTO assume that no NAT exists between the nodes
of the cloud.

## Example configuration

Below is a documented example configuration.

### installing certificate

It assumes all nodes in the cloud have PKCS#12 certificate file. It
assumes the "friendly name" or "nick name" of the certificate is the
full hostname (fqdn) If your certificate system did not supply a PKCS#12
certificate file, but seperate files for the key, certificate and CA
certificate, you can use the following command to create a PKCS#12 file:

    openssl pkcs12 -export -in cert.pem -inkey privkey.pem -out yourhostname.p12 -name yourhostname -CAfile chain.pem -certfile chain.pem

Such a file contains the host certificate and the CA certificate. To
import the PKCS#12 certificate into libreswan, run:

    ipsec import file.p12

### Configuration

When using certificates, there is no need to change anything in the
/etc/ipsec.secrets file, as that file is only used for PSK's and XAUTH.

The basic /etc/ipsec.conf does not need anything special, and it usually
just points to further include files.

    # /etc/ipsec.conf

    config setup
        protostack=netkey
        #plutodebug="all"
        logfile=/var/log/pluto.log

    include /etc/ipsec.d/*.conf

Next, we will put our Opportunistic connections in one file:

    # /etc/ipsec.d/oe-certificate.conf

    conn private-or-clear
            # Prefer IPsec, allow cleartext
            rightrsasigkey=%cert
            rightauth=rsasig
            right=%opportunisticgroup
            rightca=%same
            left=%defaultroute
            leftcert=yourhostname
            leftid=%fromcert
            narrowing=yes
            type=tunnel
            ikev2=insist
            auto=ondemand
            # tune remaining options to taste - fail fast to prevent packet loss to the app
            negotiationshunt=drop
            failureshunt=passthrough
            keyingtries=1
            retransmit-timeout=3s
            auto=ondemand

    conn private
            # IPsec mandatory
            rightrsasigkey=%cert
            rightauth=rsasig
            right=%opportunisticgroup
            rightca=%same
            left=%defaultroute
            leftcert=yourhostname
            leftid=%fromcert
            narrowing=yes
            type=tunnel
            ikev2=insist
            auto=ondemand
            # tune remaining options to taste - fail fast to prevent packet loss to the app
            negotiationshunt=hold
            failureshunt=drop
            # 0 means infinite tries
            keyingtries=0
            retransmit-timeout=3s
            auto=ondemand

    conn clear-or-private
            # Prefer cleartext, allow cleartext
            rightrsasigkey=%cert
            rightauth=rsasig
            right=%opportunisticgroup
            rightca=%same
            left=%defaultroute
            leftcert=yourhostname
            leftid=%fromcert
            narrowing=yes
            type=tunnel
            ikev2=insist
            auto=ondemand
            # tune remaining options to taste - fail fast to prevent packet loss to the app
            negotiationshunt=drop
            failureshunt=passthrough
            keyingtries=1
            retransmit-timeout=3s
            auto=add

    conn clear
            type=passthrough
            # temp workaround
            #authby=never
            left=%defaultroute
            right=%group
            auto=ondemand
    conn block
            type=reject
            # temp workaround
            #authby=never
            left=%defaultroute
            right=%group
            auto=ondemand

### Assign networks

To put a host or subnet into one of the above conn groups, simple add
these in CIDR notation into the policy files in /etc/ipsec.d/policies/

    # /etc/ipsec.d/policies/private-or-clear
    # Try IPsec and allow fallback to clear for these:
    10.0.0.0/8
    192.168.0.0/16
    1.2.3.4/32

    # /etc/ipsec.d/policies/private
    # These are known hosts to support IPsec and so we insist on encryption
    10.1.2.0/24
    10.1.3.0/24
    192.168.1.1/32

    # /etc/ipsec.d/policies/clear
    # force to always be cleartext
    # eg some host within a private or private-or-clear group that will never support opportunistic
    10.1.2.3/32

## Testing & Debugging

To test, simple generate network traffic. A ping command will work fine.

You can see all the IPsec tunnels that are up using:

    ipsec whack --trafficstatus

Inactive tunnels are torn down (once an hour)

You can see all the hosts that did not result in an IPsec tunnel:

    ipsec whack --shuntstatus

Shunts are cleaned up regularly (once every 15 minutes)

To get a full debug status output, run:

    ipsec status

To see the kernel state, you can run the following commands:

    ip xfrm policy
    ip xfrm state

## Security Implications

Currently, with libreswan-3.19 and using packet based triggers, there is
no additional check that the certificate identity of the remote host
matches the identity of the host at the target IP. This means one
compromised host in the cloud can take over an IP of another host and
receive its encrypted traffic, that it will be able to decrypt.

libreswan-3.20 will add a DNS lookup, that can be protected with DNSSEC,
to confirm the hostname in DNS for the given IP matches the certificate
ID presented during IPsec negotiation.