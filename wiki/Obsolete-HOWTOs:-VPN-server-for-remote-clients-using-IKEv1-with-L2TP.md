# IKEv1 is obsolete, please migrate to IKEv2

Using IPsec/L2TP is a common deployment. Note that it is a dated
solution that should be avoided when possible. Specifically, there are
issues with multiple Transport Mode IPsec connections and NAT.
Additionally, L2TP clients tend to be PSK based using Aggressive Mode,
which is also an unwise choice from a security perspective. There will
be two extra layers of packet encapsulation, a PPP layer and an L2TP
layer. This can cause MTU issues, so usually the L2TP/IPsec client uses
an MTU of 1200 for the ppp device that is created.

{{ ambox \| nocat=true \| type=speedy \| text =While we document how to
run an L2TP/IPsec server, we do not recommend this type of setup. }}

# L2TP/IPsec based server

If you place your L2TP/IPsec server behind NAT (such as on Amazon AWS)
you will need to change Registry settings on Windows to allow it to
connect to IPsec servers behind NAT

As this is the most widely (yet least secure) supported IPsec
configuration, almost every enduser device that supports IPsec, supports
this setup.

Supported clients:

- All Apple iphones, ipads
- Mac OSX
- Android
- Linux with commandline
- Microsoft Windows

The server has three components to configure: libreswan for IPsec,
xl2tpd for L2TP and pppd for PPP.

# IPsec server configuration

We are going to hand out IP address from the range 100.64.0.10/24 via
PPP. So we need to exclude those addresses from being used by the remote
endpoints as pre-NAT address. It is important to keep your address pool
small and not a commonly used IP range like 10.0.0.0/24 to avoid
collisions with pre-NAT IP addresses. We use something from the range
100.64.0.0/10 which is reserved for [Carrier-grade
NAT](https://tools.ietf.org/html/rfc6598) and should therefore never be
visible on the internet, and unlike the traditional
[RFC-1918](https://tools.ietf.org/html/rfc1918) address space is not
commonly in use for local networks.

    config setup
        # needed when using PSK only. Not needed for X.509 based servers
        uniqueids=no
        virtual-private=%v4:10.0.0.0/8,%v4:192.168.0.0/16,%v4:172.16.0.0/12,%v4:25.0.0.0/8,%v4:100.64.0.0/10,%v4:!100.64.0.0/24

    conn ikev1
        authby=secret
        pfs=no
        auto=add
        rekey=no
        left=%defaultroute
        right=%any
        ikev2=never
        type=transport
        leftprotoport=17/1701
        rightprotoport=17/%any
        dpddelay=15
        dpdtimeout=30
        dpdaction=clear

    conn ikev1-nat
        also=ikev1
        rightsubnet=vhost:%priv

And of course your PreSharedKey (PSK) in /etc/ipsec.secrets

    : PSK "strongrandomstring"

# L2TP server

For the L2TP server, we use xl2tpd.

/etc/xl2tpd/xl2tpd.conf

    [global]
        listen-addr = YourPublicIP
        ipsec saref = no
        force userspace = no
        ; debug tunnel = yes

    [lns default]
        ip range = 100.64.0.100-100.64.0.200
        local ip = 100.64.0.1
        require chap = yes
        refuse pap = yes
        require authentication = yes
        name = LinuxVPNserver
        ppp debug = yes
        pppoptfile = /etc/ppp/options.xl2tpd
        length bit = yes

Some xl2tpd versions are buggy when you leave out the ipsec saref
setting even if you want it to be 'no'. The force userspace option is
required to allow the kernel to decapsulate L2TP data packets so only
L2TP control packets make it to userland's xl2tpd. This significantly
increases performance.

The IP address from the pool is handed over to PPP.

# PPP server configuration

This is done via the above pppoptfile, in our case
/etc/ppp/options.xl2tpd

    ipcp-accept-local
    ipcp-accept-remote
    # use an internal server for DNS if you need to reach local-only zones or if
    # you want DNS to be encrypted through the tunnel.
    ms-dns  100.64.0.1
    # ms-dns  8.8.8.8
    # ms-dns
    noccp
    auth
    crtscts
    idle 1800
    # when having MTU issues, can be decreased to about 1200
    mtu 1410
    mru 1410
    nodefaultroute
    debug
    lock
    proxyarp
    connect-delay 5000

In this case, we are using a simple ppp configuration with usernames and
passwords specified in /etc/ppp/chap-secrets. You can hand out static
IPs (that should not be taken from the pool!) or hand them out from the
L2TP pool.

    # /etc/ppp/chap-secrets
    # Secrets for authentication using CHAP
    # client    server     secret          IP addresses
    user1       *          "password1"     10.10.64.2
    user2       *          "password2"     10.10.64.3
    user10      *          "secret10"      *
    user11      *          "geheim"        *
    #

If you want to use a radius plugin instead, change
/etc/ppp/options.xl2tpd to include:

    require-pap
    plugin radius.so
    plugin radattr.so
    radius-config-file /etc/radiusclient-ng/radiusclient.conf

# L2TP/IPsec client configuration

Configuring most clients such as mobile phones is pretty simple. The
information you need to configure on the client is:

\- The remote server DNS name or IP address - The L2TP username and
password - The PreSharedKey, sometimes called "Secret"

The ipsec.secrets would be the same as the server secrets file. The
ipsec.conf entry would be almost identical:

    config setup
        # needed when using PSK only. Not needed for X.509 based servers

    conn ikev1
        authby=secret
        pfs=no
        auto=add
        rekey=no
        left=%defaultroute
            # DNS name or IP of the VPN server you want to connect to
        right=YourVPNServerIP
        type=transport
        leftprotoport=17/1701
        rightprotoport=17/1701
        dpddelay=30
        dpdtimeout=70
        dpdaction=clear

Your /etc/xl2tpd/xl2tpd.conf file would be:

    [global]
       ; no need for listen-addr

    [lac server]
        ; DNS name or VPN server IP
        lns = YourVPNServerIP
        ppp debug = yes
        pppoptfile = /etc/ppp/options.server

And your /etc/ppp/options.server would contain:

    ipcp-accept-local
    ipcp-accept-remote
    refuse-eap
    require-mschap-v2
    noccp
    noauth
    idle 1800
    mtu 1200
    mru 1200
    defaultroute
    noipdefault
    usepeerdns
    debug
    lock
    connect-delay 5000
    name YourName
    password YourPassword