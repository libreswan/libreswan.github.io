This example sets up an IPsec connection between two hosts called "east"
and "west". (these names are also used for our daily tests, and you can
find lots of configuration examples in our test suite)

192.0.2.254/24 eth0 WEST eth1 192.1.2.23 --\[internet\]-- 192.1.2.45
eth1 EAST eth0 192.0.1.254/24

Libreswan uses the terms "left" and "right" to describe endpoints. We
will use left for west and east for right. We will be using PSK in this
example. Generate a pre shared key (PSK) for use in this VPN. PSK is
really not a password, it's a key and you must make absolutely sure it
is transferred to remote end in a secure way by using PGP/GPG or ssh.
Secure PSK should be at least 32 characters random but 64 chars is
better. We can actually cope with even longer PSK sizes but not all
implementations can. You can generate psk with openssl, pwgen or some
other tool which can really generate random string. Libreswan is not
limited to 64 chars psk but some other IPsec implementations are, that's
the reason we use 64 as an example.

Openssl command to create a psk which is 64 chars long.

    [root@west ~]# openssl rand -base64 48

Also pwgen can be used to generate a psk.

    [root@west ~]# pwgen -s 64 1
    a64-charslongrandomstringgeneratedwithpwgenoropensslorothertool

Edit /etc/ipsec.secrets with your favourite editor and add PSK entry:

    192.1.2.23 192.1.2.45 : PSK "a64-charslongrandomstringgeneratedwithpwgenoropensslorothertool"

Exactly same /etc/ipsec.secrets entry is needed on east. Remember to use
ssh or other secure method to move the data.

Now we are ready to make a simple /etc/ipsec.conf file for our host to
host tunnel. The psk is only in /etc/ipsec.secrets and there are no
signs about it in /etc/ipsec.conf.

    # /etc/ipsec.conf

    config setup
        protostack=netkey

    conn mytunnel
        left=192.1.2.23
        right=192.1.2.45
        authby=secret
        # use auto=start when done testing the tunnel
        auto=add

In this simple case you can use the identical configuration file on both
east and west. They will auto-detect if they are "left" or "right".

First, ensure ipsec is started:

    ipsec setup start

Then ensure the secret is loaded - this is only required if ipsec
service was already running:

    ipsec auto --rereadsecrets

Then ensure the connection loaded:

    ipsec auto --add mytunnel

And then try and bring up the tunnel:

    ipsec auto --up mytunnel

If all went well, you should see something like:

    # ipsec auto --up  mytunnel
    104 "mytunnel" #1: STATE_MAIN_I1: initiate
    003 "mytunnel" #1: received Vendor ID payload [Dead Peer Detection]
    003 "mytunnel" #1: received Vendor ID payload [FRAGMENTATION]
    106 "mytunnel" #1: STATE_MAIN_I2: sent MI2, expecting MR2
    108 "mytunnel" #1: STATE_MAIN_I3: sent MI3, expecting MR3
    003 "mytunnel" #1: received Vendor ID payload [CAN-IKEv2]
    004 "mytunnel" #1: STATE_MAIN_I4: ISAKMP SA established {auth=PRESHARED_KEY cipher=aes_128 integ=sha group=MODP2048}
    117 "mytunnel" #2: STATE_QUICK_I1: initiate
    004 "mytunnel" #2: STATE_QUICK_I2: sent QI2, IPsec SA established tunnel mode {ESP=>0xESPESP <0xESPESP xfrm=AES_128-HMAC_SHA1 NATOA=none NATD=none DPD=passive}

If you want the tunnel to start when the machine starts, change
"auto=add" to "auto=start". Also ensure that your system starts the
ipsec service on boot. This can be done using the "service" or
"systemctl" command, depending on the init system used for the server.