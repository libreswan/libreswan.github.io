Classic VPNs provide encryption and authentication of hosts or users
based on an existing and configured relationship. This can be an
enterprise VPN, or a VPN service provider.

The goal of Opportunistic IPsec is to attempt to encrypt **ALL**
communications between any two host without requiring a trust
relationship or preconfiguration. That is, the goal is to encrypt the
entire internet.

{{ ambox \| nocat=true \| type=speedy \| text = This feature is
experimental - please ensure you have non-network console access to the
machines you run Opportunistic IPsec on }}

**QUICKSTART:**

    # install libreswan-3.19 or higher using apt-get, yum or dnf
    cd /etc/ipsec.d
    wget https://raw.githubusercontent.com/libreswan/libreswan/master/docs/examples/oe-upgrade-authnull.conf
    ipsec restart
    # test by pinging a known Opportunistic IPsec site:
    ping oe.libreswan.org
    ipsec whack --trafficstatus

# How does Opportunistic IPsec work?

The IKEv2 protocol is used to negotiate the symmetric encryption keys
for the IPsec subsystem in the kernel. The kernel then takes care of
encrypting and decrypting the traffic between the hosts.

The IKE daemon is responsible for this negotiation. It uses encryption
itself to protect the IKE communication between the hosts. Therefor, IKE
communication consists roughly of two parts:

- Setup a secure communication link to the other host
- Mutually agree on encryption keys and source/destination IP addresses
  to install in the kernel.

To setup a secure channel, the IKE protocol first performs a
DiffieHellman Key Exchange. Then the peers authenticate each other. Once
authenticated, symmetric keys for the kernel are derived.

The IKE daemon can also tell the kernel which traffic it wants to be
notified for, so it can initiate IKE. For Opportunistic IPsec, the
libreswan IKE daemon basically tells the kernel it is interested in all
traffic. Once traffic for a new IP is received or ready to be sent, the
kernel will inform the IKE daemon. The IKE daemon will attempt to setup
an IPsec tunnel. If that is not possible, for instance because the other
end does not support Opportunistic IPsec, the IKE daemon tells the
kernel to let that traffic go unencrypted. The IKE daemon manages the
established tunnels and cleartext passes. It will keep active IPsec
tunnels alive and terminate idle IPsec tunnels. It also expires the
cleartext passes to try and upgrade those to IPsec tunnels as well.

The biggest issue is how to authenticate someone you never communicated
with before. And IKE/IPsec in the past required both parties to identify
itself. However, as of IKEv2 and specifically since
\[<https://tools.ietf.org/html/rfc7619> RFC-7619\[, the IKE protocol
allows a special NULL authentication. We use this to provide different
levels of authentication and protection

Opportunistic IPsec is always host-to-host, meaning IPsec tunnels are
only setup for the hosts themselves. Since there is no method to
securely convey ownership of a certain IP address, an Opportunistic
IPsec host can never be trusted to talk on another IP's behalf.

{{ ambox \| nocat=true \| type=information \| text = The libreswan-3.19
release does not yet support IPv6. Support for this will be added to
3.20 }}

## Types of Opportunistic Encryption

- Mutually authenticated IPsec - this requires both peers authenticate
  each other. This is the classic IPsec model. Authentication could be
  based on X.509, Kerberos, DNSSEC or a bitcoin ledger.

<!-- -->

- Single side authentication - this requires that the client
  authenticates the server, but the server allows everyone to connect
  and encrypt. This is similar to the SSL/TLS model

<!-- -->

- Unauthenticated encryption - this requires no authentication from
  either side. But it is vulnerable to a Man In The Middle attack.

Work is being done to implement all three types of Opportunistic IPsec.
As of version 3.16, libreswan supports unauthenticated encryption.

### Configuring Opportunistic unauthenticated IPsec

To configure libreswan, simply download the configuration file
[oe-upgrade-authnull.conf](https://raw.githubusercontent.com/libreswan/libreswan/master/docs/examples/oe-upgrade-authnull.conf)
and place it in the */etc/ipsec.d* directory.

You can tune for which IP ranges you want to try Opportunistic IPsec.
You can configure these ranges to be passive or active. Passive means
the system will respond and accept IKE requests for IPsec, but it will
never attempt to initiate it. This can be used on busy servers where it
is expected that only few clients connecting to it will support
Opportunistic IPsec. Active means that the system will always attempt to
initiate IKE.

The passive IP ranges are configured in
/etc/ipsec.d/policies/clear-or-private

The active IP ranges are configuref in /etc/ipsec.d/private-or-clear.

Per default, 0.0.0.0/0 is places in the active range.

Simply restart libreswan and Opportunistic IPsec will be enabled.

### Monitoring the sytem for IPsec tunnels

There are three important commands to get information about IPsec
tunnels and Shunts. Shunts are placed in the kernel to allow cleartext,
once the IKE daemon determined it cannot setup IPsec.

- ipsec whack --trafficstatus

This will show the active IPsec tunnels

- ipsec whack --shuntstatus

This will show the active shunts. The ones labeled "acquire" are
currently in an IKE negotiation. The ones labeled "oe-failing" are
shunts installed due to IKE failures.

- ipsec status

This will give a lot of developer specific internal status of the IKE
daemon.

### Test hosts

If you want to test Opportunistic IPsec, you can do so by sending
traffic to any \*.libreswan.org or \*.nohats.ca host. If you browse to
[oe.libreswan.org](http://oe.libreswan.org/) it will inform you whether
or not your connection has been encrypted with Opportunistic IPsec.

Below follows an example output from the commandline:

    [root@oe1 ~]# ipsec whack --trafficstatus
    000
    006 #3225: "private-or-clear#193.110.157.0/24"[2] ...193.110.157.124, type=ESP,  add_time=1450417506, inBytes=252, outBytes=252, id='ID_NULL'
    006 #3229: "private-or-clear#193.110.157.0/24"[4] ...193.110.157.131, type=ESP,  add_time=1450417537, inBytes=252, outBytes=252, id='ID_NULL'
    006 #3234: "private-or-clear#193.110.157.0/24"[774] ...193.110.157.130, type=ESP,  add_time=1450417774, inBytes=0, outBytes=0, id='ID_NULL'
    000
    [root@oe1 ~]# ping -c 2 libreswan.org
    PING libreswan.org (188.127.201.229) 56(84) bytes of data.
    64 bytes from libreswan.org (188.127.201.229): icmp_seq=2 ttl=64 time=25.1 ms
    64 bytes from libreswan.org (188.127.201.229): icmp_seq=3 ttl=64 time=25.2 ms
    --- libreswan.org ping statistics ---
    4 packets transmitted, 2 received, 50% packet loss, time 3002ms
    rtt min/avg/max/mdev = 25.161/25.185/25.210/0.160 ms
    [root@oe1 ~]# ipsec whack --trafficstatus
    000
    006 #3238: "clear-or-private#0.0.0.0/0"[2] ...188.127.201.229, type=ESP,  add_time=1450417921, inBytes=252, outBytes=252, id='ID_NULL'
    006 #3225: "private-or-clear#193.110.157.0/24"[2] ...193.110.157.124, type=ESP,  add_time=1450417506, inBytes=252, outBytes=252, id='ID_NULL'
    006 #3229: "private-or-clear#193.110.157.0/24"[4] ...193.110.157.131, type=ESP,  add_time=1450417537, inBytes=252, outBytes=252, id='ID_NULL'
    006 #3236: "private-or-clear#193.110.157.0/24"[775] ...193.110.157.130, type=ESP,  add_time=1450417894, inBytes=0, outBytes=0, id='ID_NULL'
    000

    [root@oe1 ~]# ipsec whack --shuntstatus
    000 Bare Shunt list:
    000
    000 193.110.157.129/32:0 -0-> 193.110.157.123/32:0 => %pass 0    oe-failing