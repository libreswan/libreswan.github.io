The idea is to leverage the LetsEncrypt Certificate Agency to
authenticate servers for IPsec. At the same time, we want our IPsec
clients to remain anonymous. This allows the client configuration to be
simple since it does not need to have its own verifiable identity. And
it also offers the best privacy for the client. This is similar to how
TLS works. But with IPsec we get to encrypt every kind of traffic
between the two hosts and not just those applications that support
SSL/TLS.

{{ ambox \| nocat=true \| type=warning \| text = This is an EXPERIMENTAL
feature. Please send feedback to the swan-dev@lists.libreswan.org
mailing list }}

__TOC__

## Client configuration

The client configuration is reasonable straightforward. What is needed
is the Root Certificate Agency file for LetsEncrypt and libreswan-3.19
or higher.

If libreswan is not yet installed or has never started before, it must
be started first so that it initializes the NSS certificate store. For
example:

    yum install libreswan
    ipsec start

Next, we need to install the LetsEncrypt CA certificates into the NSS
db. Note that for RHEL and Fedora, this store is located in /etc/ipsec.d
and for Debian and Ubuntu this store is located in /var/lib/ipsec/nss/

    mkdir letsencrypt
    cd letsencrypt
    wget https://letsencrypt.org/certs/lets-encrypt-x4-cross-signed.pem
    wget https://letsencrypt.org/certs/lets-encrypt-x3-cross-signed.pem
    wget https://letsencrypt.org/certs/isrgrootx1.pem
    # the trustid root is missing the header / footer and is stupidly embedded on web page
    # baesed on https://www.identrust.com/certificates/trustid/root-download-x3.html
    wget https://nohats.ca/LE/identrust-x3.pem

    # use the right NSS location!
    certutil -A -i lets-encrypt-x3-cross-signed.pem -n lets-encrypt-x3 -t CT,, -d sql:/etc/ipsec.d
    certutil -A -i lets-encrypt-x4-cross-signed.pem -n lets-encrypt-x4 -t CT,, -d sql:/etc/ipsec.d
    certutil -A -i isrgrootx1.pem -n isrgrootx1 -t CT,, -d sql:/etc/ipsec.d
    certutil -A -i identrust-x3.pem -n identrust-x3 -t CT,, -d sql:/etc/ipsec.d

Next, we need to configure libreswan to attempt to setup an IPsec tunnel
for each new target IP address the kernel wants to send a packet to.
This uses a special connection named "private-or-clear".

You can cut & paste the below configuration, or you can download it:
<https://raw.githubusercontent.com/libreswan/libreswan/master/docs/examples/oe-letsencrypt-client.conf>
oe-letsencrypt-client.conf\] Place the file in /etc/ipsec.d/

    # See https://libreswan.org/wiki/HOWTO:_Opportunistic_IPsec_using_LetsEncrypt
    #
    conn private-or-clear
        rightid=%fromcert
        rightrsasigkey=%cert
        rightauth=rsasig
        right=%opportunisticgroup
        rightmodecfgclient=yes
        rightcat=yes
        # Any CA will do because we only load the LetsEncrypt CA
        rightca=%any
        #
        left=%defaultroute
        leftid=%null
        leftauth=null
        leftmodecfgclient=yes
        leftcat=yes
        #
        narrowing=yes
        type=tunnel
        ikev2=insist
        negotiationshunt=drop
        failureshunt=passthrough
        keyingtries=1
        retransmit-timeout=3s
        auto=ondemand

Next, we need to tell when this kind of LetsEncrypt connection is
attempted. We are planning to add some plugins and DNS record or other
kind of information that will allow libreswan to detect which sites
support this before trying to connect. For now, we will just always try
and if it fails we remember this for a while (1h).

    # /etc/ipsec.d/policies/private-or-clear
    #
    # A number of hosts within this /24 support LetsEncrypt (letsencrypt.libreswan.org, nohats.ca, mx.nohats.ca)
    193.110.157.0/24
    # If you just want to always try it to everyone in the world, enable the below line
    0.0.0.0/0

That's it. Now you can restart libreswan to reload the configuration and
test it.

    paul@thinkpad:~$ sudo ipsec restart
    Redirecting to: systemctl stop ipsec.service
    Redirecting to: systemctl start ipsec.service
    paul@thinkpad:~$ sudo ipsec whack --trafficstatus
    paul@thinkpad:~$ ping letsencrypt.libreswan.org
    PING letsencrypt.libreswan.org (193.110.157.131) 56(84) bytes of data.
    64 bytes from letsencrypt.libreswan.org (193.110.157.131): icmp_seq=2 ttl=64 time=96.5 ms
    64 bytes from letsencrypt.libreswan.org (193.110.157.131): icmp_seq=3 ttl=64 time=98.0 ms
    ^C
    --- letsencrypt.libreswan.org ping statistics ---
    3 packets transmitted, 2 received, 33% packet loss, time 2062ms
    rtt min/avg/max/mdev = 96.564/97.306/98.049/0.805 ms
    paul@thinkpad:~$ sudo ipsec whack --trafficstatus
    006 #4: "private-or-clear#193.110.157.0/24"[2] ...193.110.157.131, type=ESP, add_time=1484626492, inBytes=168, outBytes=168, id='CN=letsencrypt.libreswan.org'

If a host does not support Opportunistic IPsec, you can see this in the
bare shunt table.

    paul@thinkpad:~$ ping 193.110.157.1
    PING 193.110.157.1 (193.110.157.1) 56(84) bytes of data.
    64 bytes from 193.110.157.1: icmp_seq=2 ttl=52 time=93.9 ms
    64 bytes from 193.110.157.1: icmp_seq=3 ttl=52 time=93.9 ms
    ^C
    --- 193.110.157.1 ping statistics ---
    3 packets transmitted, 2 received, 33% packet loss, time 2001ms
    rtt min/avg/max/mdev = 93.906/93.935/93.964/0.029 ms
    paul@thinkpad:~$ sudo ipsec whack --trafficstatus
    006 #2: "private-or-clear#193.110.157.0/24"[1] ...193.110.157.131, type=ESP, add_time=1484626698, inBytes=168, outBytes=168, id='CN=letsencrypt.libreswan.org'
    paul@thinkpad:~$ sudo ipsec whack --shuntstatus
    000 Bare Shunt list:
    000
    000 76.10.157.68/32:0 -0-> 193.110.157.1/32:0 => %pass 0    oe-failing

(note the tunnel shown was already established above)

You can confirm with tcpdump:

    23:21:25.682769 IP 76.10.157.68 > 193.110.157.131: ESP(spi=0x63c0c45a,seq=0x5), length 120
    23:21:25.778733 IP 193.110.157.131 > 76.10.157.68: ESP(spi=0x43f7f488,seq=0x5), length 120
    23:21:25.778733 IP 193.110.157.131 > 76.10.157.68: ICMP echo reply, id 18348, seq 3, length 64
    23:21:26.683790 IP 76.10.157.68 > 193.110.157.131: ESP(spi=0x63c0c45a,seq=0x6), length 120
    23:21:26.782588 IP 193.110.157.131 > 76.10.157.68: ESP(spi=0x43f7f488,seq=0x6), length 120
    23:21:26.782588 IP 193.110.157.131 > 76.10.157.68: ICMP echo reply, id 18348, seq 4, length 64
    23:21:27.685652 IP 76.10.157.68 > 193.110.157.131: ESP(spi=0x63c0c45a,seq=0x7), length 120
    23:21:27.785603 IP 193.110.157.131 > 76.10.157.68: ESP(spi=0x43f7f488,seq=0x7), length 120
    23:21:27.785603 IP 193.110.157.131 > 76.10.157.68: ICMP echo reply, id 18348, seq 5, length 64

Note that the way tcpdump and IPsec hook into the kernel, you see both
the encrypted outgoing, encrypted incoming and decrypted incoming
traffic, but not the outgoing pre-encrypt traffic. Work is underway to
integrate OE with VTI interfaces where you will see all cleartext on the
ipsec0 interface and all encrypted packets on the physical interface.

## Server configuration

The server-side configuration consists of two parts. Getting a
LetsEncrypt certificate and configurating libreswan. In this example, we
will setup nssec.nohats.ca as an Opportunistic IPsec server for use with
LetsEncrypt.

There are different methods and software available to get a LetsEncrypt
certificate. While most people seem to use certbot, I found
[dehydrated](https://github.com/lukas2511/dehydrated) much nicer to use.
To proof ownership of the server, you need to answer an ACME challenge
using either DNS or HTTP. We will use HTTP. Note that you only briefly
need to run an HTTP server while getting or renewing the certificate. In
our example we will use a standard apache install on RHEL/CENTOS server.
It should work on version 6 or 7 of these distributions.

At the time of writing, those repositories do not yet have
libreswan-3.19 or later. The Libreswan Project offers a repository for
RHEL/CentoOS 6 and 7 that does have a new enough version:

    cd /etc/pki/rpm-gpg
    wget https://download.libreswan.org/RPM-GPG-KEY-libreswan
    cd /etc/yum.repos.d
    wget https://download.libreswan.org/rhel-libreswan.repo
    </pre?

    Install libreswan and apache:

    <pre>
    yum install libreswan httpd
    ipsec start
    systemctl start httpd

Install and run "dehydrated" to get (and renew) a LetsEncrypt
certificate. If your host has multiple DNS names, add all of them on a
single line in the domains.txt file:

    mkdir /etc/dehydrated
    cd /etc/dehydrated
    wget https://raw.githubusercontent.com/lukas2511/dehydrated/master/dehydrated
    chmod 755 dehydrated
    echo "nssec.nohats.ca" > domains.txt
    echo "WELLKNOWN=/var/www/html/.well-known/acme-challenge" >>config
    echo "CONTACT=your@email.com" >>config
    mkdir -p /var/www/html/.well-known/acme-challenge
    restorecon -R /var/www/html/.well-known
    ln -s  /etc/dehydrated/dehydrated /usr/local/sbin/dehydrated
    dehydrated -c
    <pre>

    If everything worked, it will look like:

    <pre>
    [root@nssec dehydrated]# dehydrated -c
    # INFO: Using main config file /etc/dehydrated/config
    Processing nssec.nohats.ca
     + Signing domains...
     + Generating private key...
     + Generating signing request...
     + Requesting challenge for nssec.nohats.ca...
     + Already validated!
     + Requesting certificate...
     + Checking certificate...
     + Done!
     + Creating fullchain.pem...
     + Done!

Now we need to import the certificate into libreswan. It will require an
"export password". It is not really used because we will immediately
import it without password into libreswan. You should set the name
(-name) to the DNs name of your host. We will use this later in the
libreswan configuration.

    cd /etc/dehydrated/certs/nssec.nohats.ca/
    openssl pkcs12 -export -inkey privkey.pem -in cert.pem -name nssec.nohats.ca -certfile fullchain.pem -out nssec.nohats.ca.p12
    Enter Export Password:
    Verifying - Enter Export Password:

The .p12 file can now be imported into libreswan:

    ipsec import nssec.nohats.ca.p12
    Enter password for PKCS12 file:
    pk12util: PKCS12 IMPORT SUCCESSFUL
    correcting trust bits for Let's Encrypt Authority X3 - Digital Signature Trust Co.

Now similar to what we had done on the client, we need to create a
connection. You can cut & paste the below configuration, or you can
download it:
<https://raw.githubusercontent.com/libreswan/libreswan/master/docs/examples/oe-letsencrypt-server.conf>\]
Place the file in /etc/ipsec.d/

    # See https://libreswan.org/wiki/HOWTO:_Opportunistic_IPsec_using_LetsEncrypt
    conn clear-or-private
            leftid=%fromcert
            leftrsasigkey=%cert
            # Use the nickname (DNS name) of YOUR server
            leftcert=nssec.nohats.ca
            leftauth=rsasig
            left=%defaultroute
            leftaddresspool=100.64.0.1-100.64.255.254
            leftmodecfgclient=yes
            #
            rightid=%null
            rightauth=null
            right=%opportunisticgroup
            #
            negotiationshunt=passthrough
            failureshunt=passthrough
            type=tunnel
            ikev2=insist
            sendca=issuer
            auto=add

Since with this connection you want to respond to everyone who tries to
connect to you, you should add 0.0.0.0/0 to the clear-or-private policy
file:

    # /etc/ipsec.d/policies/clear-or-private
    # The world
    0.0.0.0/0

And now you are read to restart libreswan and test it all out!

    ipsec restart

## List of servers that are known to support Opportunistic IPsec

- [letsencrypt.libreswan.org](http://letsencrypt.libreswan.org)
- [nohats.ca](https://nohats.ca)
- [naomirae.com](http://naomirae.com)
- [mx.nohats.ca](http://mx.nohats.ca)
- [nssec.nohats.ca](http://nssec.nohats.ca) (This server can also be
  used as DNS server)

## Monitoring and Debugging

Monitoring and debugging can be done using:

    # to see all IPsec tunnels currently active (and the amount of traffic encrypted)
    sudo ipsec whack --trafficstatus

    # to see all the IP addresses that were tried, but did not offer Opportunistic IPsec:
    sudo ipsec whack --shuntstatus

    # to see all the gory inside state of the libreswan pluto daemon
    sudo ipsec status

Libreswan also logs via syslog (or to a file if specified using
logfile=/var/log/pluto.log in /etc/ipsec.conf)

It can be useful to do a manual debug version of an OE request. Since
you might already have an outstanding request, and there cannot be two
requests, the easiest is to restart libreswan and then test. Note that
you need to know your local IP and the remote IP. There is no DNS
resolution using this debug command.

    sudo ipsec restart
    sleep 3
    sudo ipsec whack --oppohere YOURIP --oppothere REMOTEIP

It will look something like:

    paul@thinkpad:~$ sudo ipsec restart
    Redirecting to: systemctl stop ipsec.service
    Redirecting to: systemctl start ipsec.service
    paul@thinkpad:~$ dig +short nssec.nohats.ca
    193.110.157.123
    paul@thinkpad:~$ sudo ipsec whack --oppohere 76.10.157.68 --oppothere 193.110.157.123
    002 initiate on demand from 76.10.157.68:0 to 193.110.157.123:0 proto=0 because: whack
    133 "private-or-clear#193.110.157.0/24"[1] ...193.110.157.123 #1: STATE_PARENT_I1: initiate
    002 "private-or-clear#193.110.157.0/24"[1] ...193.110.157.123 #1: private-or-clear#193.110.157.0/24 IKE proposals for initial initiator (selecting KE): 1:IKE:ENCR=AES_GCM_C_256;PRF=HMAC_SHA2_512,HMAC_SHA2_256,HMAC_SHA1;INTEG=NONE;DH=MODP2048,MODP3072,MODP4096,MODP8192 2:IKE:ENCR=AES_GCM_C_128;PRF=HMAC_SHA2_512,HMAC_SHA2_256,HMAC_SHA1;INTEG=NONE;DH=MODP2048,MODP3072,MODP4096,MODP8192 3:IKE:ENCR=AES_CBC_256;PRF=HMAC_SHA2_512,HMAC_SHA2_256,HMAC_SHA1;INTEG=HMAC_SHA2_512_256,HMAC_SHA2_256_128,HMAC_SHA1_96;DH=MODP2048,MODP3072,MODP1536 4:IKE:ENCR=AES_CBC_128;PRF=HMAC_SHA2_512,HMAC_SHA2_256,HMAC_SHA1;INTEG=HMAC_SHA2_512_256,HMAC_SHA2_256_128,HMAC_SHA1_96;DH=MODP2048,MODP3072,MODP1536 (default)
    002 "private-or-clear#193.110.157.0/24"[1] ...193.110.157.123 #1: private-or-clear#193.110.157.0/24 ESP/AH proposals for initiator: 1:ESP:ENCR=AES_GCM_C_256;INTEG=NONE;ESN=DISABLED 2:ESP:ENCR=AES_GCM_C_128;INTEG=NONE;ESN=DISABLED 3:ESP:ENCR=AES_CBC_256;INTEG=HMAC_SHA2_512_256,HMAC_SHA2_256_128;ESN=DISABLED 4:ESP:ENCR=AES_CBC_128;INTEG=HMAC_SHA2_512_256,HMAC_SHA2_256_128;ESN=DISABLED 5:ESP:ENCR=AES_CBC_128;INTEG=HMAC_SHA1_96;ESN=DISABLED (default)
    002 "private-or-clear#193.110.157.0/24"[1] ...193.110.157.123 #2: certificate CN=nssec.nohats.ca OK
    002 "private-or-clear#193.110.157.0/24"[1] ...193.110.157.123 #2: negotiated connection [76.10.157.68,76.10.157.68:0-65535 0] -> [193.110.157.123,193.110.157.123:0-65535 0]

## Common Errors

If you are trying to perform a manual OE operation for a target IP that
is not covered by /etc/ipsec.d/policies/private\* you will receive this
error:

    paul@thinkpad:~$ sudo ipsec whack --oppohere 76.10.157.68 --oppothere 1.2.3.4
    002 initiate on demand from 76.10.157.68:0 to 1.2.3.4:0 proto=0 because: whack
    002 Cannot opportunistically initiate for 76.10.157.68 to 1.2.3.4: no routed template covers this pair
    033 Cannot opportunistically initiate for 76.10.157.68 to 1.2.3.4: no routed template covers this pair