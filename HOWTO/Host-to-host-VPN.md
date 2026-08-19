![Host2host](/images/Host2host.png)

This example sets up an IPsec connection between two hosts. The names
and IP addresses used here are also used in our [testing
infrastructure](https://testing.libreswan.org/). You will find a lot of
configuration examples there as well. In this host-to-host example, we
will create an IPsec VPN between Host A ("west" on 192.1.2.45) and Host
B (east on 192.1.2.23)

Libreswan uses the terms "left" and "right" to describe endpoints. We
will use "left" for west and east for "right". We will be using raw RSA
keys, and not pre shared keys (PSK) because it is safer (and easier!)

Generate a raw RSA host key on each end and show the key for use in our
configuration file. Note that the raw key blobs span several lines. We
reduced them here for readability. Ensure they appear on a single line
in your ipsec.conf.

On the host called west, run:

    [root@west ~]# ipsec newhostkey
    Generated RSA key pair with CKAID f8d0e8766b60eaf5a10d2a220955bb1688415e6e was stored in the NSS database
    [root@west ~]# ipsec showhostkey --left --ckaid f8d0e8766b60eaf5a10d2a220955bb1688415e6e
        # rsakey AwEAAb42X
        leftrsasigkey=0sAwEAAb42X0gw [....]

Repeat this on the other host, in our case east, using "right" instead
"left":

    [root@east ~]# ipsec newhostkey
    Generated RSA key pair with CKAID b95477d03cbe3118c50fb433a2740ec52f3fb2d8 was stored in the NSS database
    [root@east ~]# ipsec showhostkey --right --ckaid b95477d03cbe3118c50fb433a2740ec52f3fb2d8
        # rsakey AwEAAesFf
        rightrsasigkey=0sAwEAAesFfVZqFzRA9F [...]

{{ ambox \| type = alert \| text = On embedded hardware with low
entropy, the process of generating a RSA new key can take minutes }}

{{ ambox \| type = alert \| text = On older versions of libreswan, the
newhostkey command had to be called with "--output
/etc/ipsec.d/your.secret", and the main secrets files /etc/ipsec.secrets
has an include statement for /etc/ipsec.d/\*.secret. On current
libreswan versions, the secrets file(s) are only used for PSK's and
XAUTH passwords. }}

    # /etc/ipsec.conf

    conn mytunnel
        leftid=@west
        left=192.1.2.23
        leftrsasigkey=0sAwEAAb42X0gw [....]
        rightid=@east
        right=192.1.2.45
        rightrsasigkey=0sAwEAAesFfVZqFzRA9F
        authby=rsasig
        # use auto=start when done testing the tunnel
        auto=add

You can use the identical configuration file on both east and west. The
hosts will each auto-detect whether they are "left" or "right".

First, ensure ipsec is started:

    ipsec setup start

Then ensure the connection loaded:

    ipsec auto --add mytunnel

And then try and bring up the tunnel on one of the hosts. It should not
matter which one you use.

    ipsec auto --up mytunnel

If all went well, you should see something like:

    # ipsec auto --up  mytunnel
    002 "mytunnel" #1: initiating v2 parent SA
    1v2 "mytunnel" #1: initiate
    1v2 "mytunnel" #1: STATE_PARENT_I1: sent v2I1, expected v2R1
    1v2 "mytunnel" #2: STATE_PARENT_I2: sent v2I2, expected v2R2 {auth=IKEv2 cipher=AES_GCM_16_256 integ=n/a prf=HMAC_SHA2_512 group=MODP2048}
    002 "mytunnel" #2: IKEv2 mode peer ID is ID_FQDN: '@east'
    003 "mytunnel" #2: Authenticated using RSA
    002 "mytunnel" #2: negotiated connection [192.1.2.45-192.1.2.45:0-65535 0] -> [192.1.2.23-192.1.2.23:0-65535 0]
    004 "mytunnel" #2: STATE_V2_IPSEC_I: IPsec SA established tunnel mode {ESP=>0xESPESP <0xESPESP xfrm=AES_GCM_16_256-NONE NATOA=none NATD=none DPD=passive}

If you want the tunnel to start when the machine starts, change
"auto=add" to "auto=start". Also ensure that your system starts the
ipsec service on boot. This can be done using the "service" or
"systemctl" command, depending on the init system used for the server.

You can generate some traffic, for example using the ping command, and
then use the *ipsec trafficstatus* command to confirm it was encrypted:

    [root@west ~]#  ping -n -c 4 192.1.2.23
    PING 192.1.2.23 (192.1.2.23) 56(84) bytes of data.
    64 bytes from 192.1.2.23: icmp_seq=1 ttl=64 time=0.443 ms
    64 bytes from 192.1.2.23: icmp_seq=2 ttl=64 time=0.403 ms
    64 bytes from 192.1.2.23: icmp_seq=3 ttl=64 time=0.450 ms
    64 bytes from 192.1.2.23: icmp_seq=4 ttl=64 time=0.437 ms
    --- 192.1.2.23 ping statistics ---
    4 packets transmitted, 4 received, 0% packet loss, time 3028ms
    rtt min/avg/max/mdev = 0.403/0.433/0.450/0.023 ms
    [root@west ~]# ipsec trafficstatus
    006 #2: "westnet-eastnet-ipv4-psk-ikev2", type=ESP, add_time=1561671961, inBytes=336, outBytes=336, id='@east'