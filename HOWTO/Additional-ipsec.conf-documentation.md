## Introduction

the most up to date source of the ipsec.conf options is always the
manual page, which you can see on the system that has libreswan. The
following commands show the most important manual pages:

    man ipsec.conf
    man ipsec.secrets
    man pluto

Although the man pages describe the options very well, it is not always
the best place to explain things in great detail. These pages go into
some more details for some of the options from ipsec.conf.

## XAUTH configurations

IPsec VPNs can by authenticated using various different methods:

\- PreShared Key with IDs (or IPs as ID) - Raw RSA public keys - X.509
Certificates

These three authentication methods authenticate the device, or
technically speaking in the PSK case, a group of devices. Sometimes
administrators also want to authenticate the user, for instance to
ensure the device cannot be used if the legitimate owner lost their
device. Or the administrator wants to automatically assign an IP address
to the connecting device. To accomplish both the user authentication and
the IP assignment, you can use one of these two methods:

\- XAUTH (IKEv1) or CP (IKEv2) - IPsec + L2TP

### XAUTH on the server

The following ipsec.conf shows a server-side example using X.509
certificate and XAUTH taken from our test case
[xauth-pluto-15](https://github.com/libreswan/libreswan/tree/master/testing/pluto/xauth-pluto-15).
The server is the "right" side, it is called "east".

    conn xauth-rsa
       left=%any
       leftaddresspool=192.0.2.100-192.0.2.200
       leftxauthclient=yes
       leftrsasigkey=%cert
       leftmodecfgclient=yes
       #
       right=192.1.2.23
       rightsubnet=0.0.0.0/0
       rightid=%fromcert
       rightrsasigkey=%cert
       rightcert=east
       rightxauthserver=yes
       rightmodecfgserver=yes
       #
       modecfgpull=yes
       modecfgdns=8.8.8.8,8.8.4.4
       # Versions up to 3.22 used modecfgdns1 and modecfgdns2
       #modecfgdns1=8.8.8.8
       #modecfgdns2=8.8.4.4
       rekey=no
       #
       #xauthby=alwaysok
       xauthby=pam
       #xauthby=file
       #xauthfail=soft

With this configuration, the device that connects will have to present
its X.509 certificate. It will also need to provide a username and
password, because that is part of the XAUTH protocol. In this example,
the username and password are looked up using the **/etc/pam.d/pluto**
PAM module. If you only have a handful of users, you can also use the
*xauthby=file* option to use a htpasswd stile password file in
/etc/ipsec.d/passwd. But if you only care about the IP address
assignment, and do not want to maintain a separate username/password
database, you can specify **xauthby=alwaysok**. This will satisfy the
client's requirement of needing to specify a username and password for
XAUTH, but the server side will just accept whatever username or
password.

### XAUTH on the client

On the client side, there is another issue. Especially on phones that
frequently connect and reconnect, you do not wish to input your username
and password all the time. Of course, the whole point of XAUTH is that
you do so. But often people use XAUTH more to get the automatic IP
address and DNS servers, and they don't really care about the username
and password because they can revoke the X.509 certificate when the
phone is lost. So there are ways to store both the username and the
password. On the client, you can add the username and password to your
configuration files:

    # /etc/ipsec.conf
    conn client
        left=%defaultroute
        leftxauthusername=paul
        leftxauthclient=yes
        leftrsasigkey=%cert
        leftmodecfgclient=yes
        [...]

    # /etc/ipsec.secrets
    @paul : XAUTH "secretpassword"

### Handling XAUTH login failures

The keyword **xauthfail=soft** can be used to allow the IPsec connection
to establish even if the XAUTH username/password authentication failed.
The _updown script is passed the XAUTH_FAILED environment variable. The
script can be modified to check for this and add firewall or NAT rules.
For instance, the user could be blocked from everything and all HTTP
requests could be redirected to a special server that informs the user
that their account is no longer working or that they need to pay for
continued VPN services. Note that if X.509 certificates become invalid
due to revocation or expiry, the XAUTH phase is never reached and the
user cannot be redirected to such a portal server.