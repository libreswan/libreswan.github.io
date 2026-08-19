# IKEv1 is obsolete, please migrate to IKEv2

There are different methods for providing a VPN server for roaming
(dynamic) clients. Which method to use depends on the clients that need
to be supported.

## XAUTH / RSA a.k.a "Cisco IPsec mode"

Supported clients:

- All Apple iphones, ipads
- Mac OSX (see below)
- Android 4.x (ICS and newer)
- Linux with NetworkManager or commandline
- Microsoft Windows using a third party client such as the Cisco client,
  or the free [Shrew Soft client](https://www.shrew.net/download/vpn)

Notably, Microsoft Windows [does not support
XAUTH](http://msdn.microsoft.com/en-us/library/windows/desktop/cc983672.aspx)
natively. Blackberry devices also do not support this method.

These days, [IKEv1 /
XAUTH](https://tools.ietf.org/html/draft-ietf-ipsec-isakmp-xauth-06) is
the most commonly used IPsec connection method. It can be deployed using
a group shared key (PSK) or X.509 certificates. In this scenario,
libreswan is configured with an IP address pool, and it assigns an IP to
connecting clients. Apart from the X.509 authentication, XAUTH also
requires a username and password. The password can also contain a one
time password (OTP) such as Google Authenticator

### Server ipsec.conf for XAUTH/RSA

    # libreswan /etc/ipsec.conf configuration file
    config setup
      protostack=netkey
      # exclude networks used on server side by adding %v4:!a.b.c.0/24
      virtual-private=%v4:10.0.0.0/8,%v4:192.168.0.0/16,%v4:172.16.0.0/12,%v4:25.0.0.0/8,%v4:!10.231.247.0/24,%v4:!10.231.246.0/24

    conn xauth-rsa
        authby=rsasig
        pfs=no
        auto=add
        rekey=no
        left=YourPublicIP
        leftcert=vpn.example.com
        leftid=@vpn.nohats.ca
        leftsendcert=always
        leftsubnet=0.0.0.0/0
        rightaddresspool=10.231.247.1-10.231.247.254
        right=%any
        rightid=%fromcert
        rightrsasigkey=%cert
        modecfgdns=193.110.157.123,8.8.8.8
        # Versions up to 3.22 used modecfgdns1 and modecfgdns2
        #modecfgdns1=193.110.157.123
        #modecfgdns2=8.8.8.8
        leftxauthserver=yes
        rightxauthclient=yes
        leftmodecfgserver=yes
        rightmodecfgclient=yes
        modecfgpull=yes
        xauthby=alwaysok
        fragmentation=yes
        # xauthby=pam
        # xauthfail=soft
        # Can be played with below
        # dpddelay=30
        # dpdtimeout=120
        # dpdaction=clear

In this example, the IP pool is 10.231.247.0/24 so on the VPN server you
would need to provide some NAT rules if you wish to offer full internet
connectivity through the VPN. Assuming that your office servers behind
this VPN server uses 10.231.246.0/24, you would add the following
iptables rules on the VPN server:

    iptables -t nat -I POSTROUTING -s 10.231.247.0/24 -d 10.231.246.0/24  -j RETURN
    iptables -t nat -A POSTROUTING -s 10.231.247.0/24 -d 0.0.0.0/8 -j MASQUERADE

### Client ipsec.conf XAUTH/RSA

This is mostly a mirror image of the server side


    conn xauth-rsa
        authby=rsasig
        pfs=no
        auto=add
        rekey=no
        left=%defaultroute
        leftcert=YourCert.example.com
        leftid=%fromcert
        leftsendcert=always
        leftxauthusername=YourName
        rightsubnet=0.0.0.0/0
        right=vpn.example.com
        rightid=%fromcert
        rightxauthserver=yes
        leftxauthclient=yes
        rightmodecfgserver=yes
        leftmodecfgclient=yes
        modecfgpull=yes
        xauthby=alwaysok
        ike-frag=yes
        # xauthby=pam
        # xauthfail=soft
        # Can be played with below
        # dpddelay=30
        # dpdtimeout=120
        # dpdaction=clear
        #
        # Commonly needed to talk to Cisco server
        # Might also need _exact_ ike= and esp= lines
        remote-peer-type=cisco
        aggrmode=yes

You can store your XAUTH password in /etc/ipsec.secrets if you do not
use NetworkManager and if you're not using a one time token:

    # /etc/ipsec.secrets
    @YOUR_ID: XAUTH "password"

When using PSK instead of RSA/certificates, you usually require a
"GroupPSK" which is the XAUTH secret, and also need to use
leftid=@GroupID instead of using the ID of your certificate.

### Aggressive Mode

On Android, there is a field called "IPSec identifier" and on iOS/OSX
there is a field called "Group Name". When these fields are blank,
Aggressive Mode is used. When these are not blank, Main Mode is used and
the value is the rightid=@String. Unfortunately, iOS/OSX sends these as
hex, which can be matched using rightid=@\[String\] but then it no
longer works for Android or NetworkManager. These values are best left
unset when using libreswan as a server. When connecting to a Ciso with
libreswan as a client, you will need to use rightid=@String and
aggrmode=yes.

{{ ambox \| nocat=true \| type=speedy \| text = iOS UserInterface bug:
If you ever fill in the "Group Name" and then clear it - the connection
remains using Aggressive Mode. If you want to use Main Mode your only
choice is to delete the VPN profile and start one from scratch where you
never touch the "Group Name" input box. }}

### User/password authentication for XAUTH

Libreswan has three options for the user/password authentication. This
is specified using the xauthby= option. If using X.509 certificates,
which are issued to individual devices/users and which can be revoked,
there is no real need to have an additional username/password layer. In
that case, **xauthby=alwaysok** can be used. This should **not** be used
when using a PSK.

If there are only a handful of users that need to be authenticated,
**xauthby=file** can be used. The format of this file is similar to the
Apache htpasswd file, and the **htpasswd** command can be used to create
the file and the user/passwords. The only difference is an additional
third column specifying the connection name. An example of an
**/etc/ipsec.d/passwd** file for the above example connection (using
xauthby=file) would be:

    john:$apr1$5h/bAg4p$Q5/c2XjwSzYy3sh/1j8Bp/:xauth-rsa
    paul:$apr1$YiVSo114$um2oIM6AqucFuMeXl/1ab0:xauth-rsa

The last method that can be used is **xauthby=pam**. Using this
configuration, libreswan uses the **/etc/pam.d/pluto** pam configuration
file to authenticate users. An /etc/pam.d/pluto example file:

    #%PAM-1.0
    # Regular System auth
    auth include system-auth
    #
    # Google Authenticator with Regular System auth in combined prompt mode
    # (OTP is added to the password at the password prompt without separator)
    # auth required pam_google_authenticator.so forward_pass
    # auth include system-auth use_first_pass
    #
    # Common
    account required pam_nologin.so
    account include system-auth
    password include system-auth
    session optional pam_keyinit.so force revoke
    session include system-auth
    session required pam_loginuid.so

=== xauthfail= option ===

Some deployments wish to **catch** the user when their password is wrong
or disabled and notify them. When the option **xauthfail=soft** is set,
the authentication failure is ignored and the IPsec tunnel is allowed to
establish. The "updown" script is signaled with the environment variable
XAUTHFAIL=soft. This can be used to NAT this user to a specific web page
where they can renew their VPN subscription.

=== fragmentation= option ===

It is recommended to use the **fragmentation=yes** option to make the
IKE connection more reliable. This is particularly important when using
X.509 certificates, which tend to cause fragmentation when used with
2048 bit RSA keys.

## IPsec with L2TP

See
[VPN_server_for_remote_clients_using_IKEv1_with_L2TP](./Obsolete-HOWTOs:-VPN-server-for-remote-clients-using-IKEv1-with-L2TP)