# IKEv1 is obsolete, please migrate to IKEv2

Libreswan's IKE daemon pluto can use pam for XAUTH authentication
(xauthby=pam). One Time Passwords (OTP) can be supported via pam
directives. The following example is for using FreeOTP. When using the
commands below, the proper pam files will be created for libreswan to
use. This example is based on RHEL7 with Red Hat Identity Management
using FreeIPA. It assumes the VPN server and the VPN client are part of
the same FreeIPA / Kerberos domain.

Create the vpn user and set a temporary initial password. Then change
the password to a permanent one:

    ipa user-add player1
    ipa passwd player1
    kinit player1

Now kinit back to admin, and run 'ipa user-mod' to enable otp auth for
the user:

    kinit admin
    ipa user-mod player1 --user-auth-type=otp

An OTP token must be created and associated with a user that will be the
owner of the token. For both UI and CLI methods, a QR code is displayed
when the token is created succesfully. Launch the FreeOTP app on the
device and scan the QR code to enable the token.

    ipa otptoken-add --type=HOTP --desc=playertoken1 --owner=player1 --algo=sha256 --digits=6

The libreswan server should first be joined to the IPA domain. Use
ipa-client-install to do this. See [Installing the IPA
Client](https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/Linux_Domain_Identity_Authentication_and_Policy_Guide/Installing_the_IPA_Client_on_Linux.html)
for more information about joining the domain. In order for libreswan to
use OTP through PAM, *sssd_pam* authentication must be included in the
PAM stack. The ipa-client-install process will do this for you by
default, and there are no other modifications to PAM necessary.

Ensure that the IPA user is resolved and able to log in through SSH
using their password+OTP.

    getent passwd player1
    ssh player1@vpnserver

The following is an example configuration of /etc/ipsec.conf for the VPN
server:

    config setup
        protostack=netkey
        virtual-private=%v4:10.0.0.0/8,%v4:192.168.0.0/16,%v4:172.16.0.0/12,%v4:25.0.0.0/8,%v4:!192.168.2.0/24

    conn vpn-clients
        # left is the server
        left=192.168.1.38
        leftsubnet=192.168.2.0/24
        leftxauthserver=yes
        leftmodecfgserver=yes
        # right is the client
        right=%any
        rightid=@groupname
        rightxauthclient=yes
        rightmodecfgclient=yes
        rightaddresspool=192.168.2.11-192.168.2.20
        modecfgpull=yes
        authby=secret
        xauthby=pam
        ikev2=no
        rekey=no
        auto=add

When using PSK instead of RSA/certificates, also add the PSK into
/etc/ipsec.secrets:

    @groupname %any : PSK "grouppassword"

An example client configuration for the above server would be:


    conn vpnserver
        # left is the server
        left=192.168.1.38
        leftsubnet=192.168.2.0/24
        leftxauthserver=yes
        leftmodecfgserver=yes
        # right is the client
        right=%defaultroute
        rightid=@groupname
        rightxauthclient=yes
        rightmodecfgclient=yes
        rightxauthusername=player1
        # right is client-side
        modecfgpull=yes
        authby=secret
        xauthby=pam
        ikev2=no
        rekey=no
        auto=add

And for PSK create the same /etc/ipsec.secrets as the one listed above
for the server.

Now you can connect using the CLI tool on the vpn client:

    ipsec start
    ipsec auto --up vpnserver

This will look like:

    root@client ~]# ipsec auto --up privnet
    002 "privnet" #1: initiating Main Mode
    104 "privnet" #1: STATE_MAIN_I1: initiate
    003 "privnet" #1: received Vendor ID payload [Dead Peer Detection]
    003 "privnet" #1: received Vendor ID payload [FRAGMENTATION]
    003 "privnet" #1: received Vendor ID payload [XAUTH]
    003 "privnet" #1: received Vendor ID payload [RFC 3947]
    002 "privnet" #1: enabling possible NAT-traversal with method RFC 3947 (NAT-Traversal)
    002 "privnet" #1: transition from state STATE_MAIN_I1 to state STATE_MAIN_I2
    106 "privnet" #1: STATE_MAIN_I2: sent MI2, expecting MR2
    003 "privnet" #1: NAT-Traversal: Result using RFC 3947 (NAT-Traversal) sender port 500: no NAT detected
    002 "privnet" #1: transition from state STATE_MAIN_I2 to state STATE_MAIN_I3
    108 "privnet" #1: STATE_MAIN_I3: sent MI3, expecting MR3
    002 "privnet" #1: Main mode peer ID is ID_IPV4_ADDR: '192.168.1.38'
    002 "privnet" #1: transition from state STATE_MAIN_I3 to state STATE_MAIN_I4
    004 "privnet" #1: STATE_MAIN_I4: ISAKMP SA established {auth=PRESHARED_KEY cipher=aes_256 integ=sha group=MODP1536}
    040 "privnet" #1: privnet prompt for Password:
    Enter passphrase:
    002 "privnet" #1: XAUTH: Answering XAUTH challenge with user='player1'
    002 "privnet" #1: transition from state STATE_XAUTH_I0 to state STATE_XAUTH_I1
    004 "privnet" #1: STATE_XAUTH_I1: XAUTH client - awaiting CFG_set
    002 "privnet" #1: XAUTH: Successfully Authenticated
    002 "privnet" #1: transition from state STATE_XAUTH_I0 to state STATE_XAUTH_I1
    004 "privnet" #1: STATE_XAUTH_I1: XAUTH client - awaiting CFG_set
    002 "privnet" #1: modecfg: Sending IP request (MODECFG_I1)
    005 "privnet" #1: Received IPv4 address: 192.168.2.11/32
    005 "privnet" #1: Received IP4 NETMASK 255.255.255.0
    002 "privnet" #1: transition from state STATE_MODE_CFG_I1 to state STATE_MAIN_I4
    004 "privnet" #1: STATE_MAIN_I4: ISAKMP SA established
    002 "privnet" #2: initiating Quick Mode PSK+ENCRYPT+TUNNEL+PFS+DONT_REKEY+UP+XAUTH+MODECFG_PULL+IKEV1_ALLOW+SAREF_TRACK+IKE_FRAG_ALLOW {using isakmp#1 msgid:8272c01d proposal=defaults pfsgroup=OAKLEY_GROUP_MODP1536}
    117 "privnet" #2: STATE_QUICK_I1: initiate
    002 "privnet" #2: transition from state STATE_QUICK_I1 to state STATE_QUICK_I2
    004 "privnet" #2: STATE_QUICK_I2: sent QI2, IPsec SA established tunnel mode {ESP=>0x564532aa <0x6f1f5941 xfrm=AES_128-HMAC_SHA1 NATOA=none NATD=none DPD=passive XAUTHuser=player1}
    [root@client ~]#

You can confirm the tunnel as well using:

    ipsec whack --trafficstatus