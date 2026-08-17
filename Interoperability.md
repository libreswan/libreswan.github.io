Although IKE and IPsec are IETF standards, there are often still
interoperability issues between different vendors. Below we list known
issues with certain vendors, as well as known networking issues of
services and cloud providers.

# Amazon AWS VPN

Amazon instances running libreswan require some additional logic due to
the AWS Elastic IP and internal routing. Additionally, Amazon provides
their own VPN servers you can use.

Configuring those is hard and tedious and in some cases cannot be made
to work due to a broken implementation of IPsec at Amazon.

## Multiple tunnels fail with Amazon's VPN

Various documentation suggests building failover tunnels with the AWS
VPN service. Instructions tell you to use 169.254.0.0/16 IP ranges -
which is VERY WRONG as this is the IPv4 Link Local IP range of
[RFC-3927](https://tools.ietf.org/html/rfc3927). You might need to
disable zeroconf on your machine. On RHEL6/Fedora you can do this by
adding NOZEROCONF=1 to /etc/sysconfig/network (on RHEL7, this seems
broken as the ifup-eth tests for -z and you might have to manually
delete a route)

Unfortunately, the IKE/IPsec implementation that Amazon runs is broken
and not only libreswan has this problem. People run into this issue as
well using
[strongswan](https://lists.strongswan.org/pipermail/users/2014-January/005797.html)
as well as
[openswan](http://serverfault.com/questions/571352/openswan-multiple-subnets-routing-issue)

The problem manifests as follows:

- Two tunnels are configured using the same ISAKMP parameters and
  different IPsec SA parameters
- The phase1 (ISAKMP SA) comes up successfully
- The phase2 (IPsec SA) of the first address range establishes
  successfully. and ping shows packet flow and proper encryption
- When the phase2 (IPsec SA) of the second address range is also
  established successfully, a ping shows packet flow and proper
  encryption
- However, the a ping send over the first established IPsec SA fails as
  soon as the second IPsec SA came up. It is clearly visible that the
  SPI used for the received encrypted answer packet is using the SPI of
  the second IPsec SA instead of the first IPsec SA.
- When initiating a new Quick Mode to rekey the first IPsec SA, it fixes
  this IPsec SA, but now the original second IPsec SA shows the exact
  same problem.

Note this bug is present regardless of whether IKEv1 or IKEv2 is used
with the Amazon VPN endpoint.

What happens is that the remote Amazon endpoint changes the previous
IPsec SA and uses the newest IPsec SA for the older range as well. In
other words, instead of encrypting the packet for the actual SA, it
encrypts it to the wrong SA. Therefor any proper implementation of IPsec
will fail to decrypt the packet and drop it. You can see this clearly
with tcpdump that shows the SPI numbers of each IPsec SA:

Load the connections and bring up the first tunnel

    # ipsec restart
    Redirecting to: systemctl stop ipsec.service
    Redirecting to: systemctl start ipsec.service
    # ipsec auto --add euc1-one
    002 added connection description "euc1-one"
    # ipsec auto --add euc2-one
    002 added connection description "euc1-two"
    # ipsec auto --up euc1-one
    002 "euc1-one" #1: initiating Main Mode
    104 "euc1-one" #1: STATE_MAIN_I1: initiate
    003 "euc1-one" #1: received Vendor ID payload [Dead Peer Detection]
    002 "euc1-one" #1: transition from state STATE_MAIN_I1 to state STATE_MAIN_I2
    106 "euc1-one" #1: STATE_MAIN_I2: sent MI2, expecting MR2
    002 "euc1-one" #1: transition from state STATE_MAIN_I2 to state STATE_MAIN_I3
    108 "euc1-one" #1: STATE_MAIN_I3: sent MI3, expecting MR3
    002 "euc1-one" #1: Main mode peer ID is ID_IPV4_ADDR: '54.239.63.154'
    002 "euc1-one" #1: transition from state STATE_MAIN_I3 to state STATE_MAIN_I4
    004 "euc1-one" #1: STATE_MAIN_I4: ISAKMP SA established {auth=PRESHARED_KEY cipher=aes_128 integ=sha group=MODP1024}
    002 "euc1-one" #2: initiating Quick Mode PSK+ENCRYPT+TUNNEL+PFS+UP+SAREF_TRACK+IKE_FRAG_ALLOW+NO_IKEPAD {using isakmp#1 msgid:62196a5b proposal=AES(12)_128-SHA1(2)_000 pfsgroup=OAKLEY_GROUP_MODP1024}
    117 "euc1-one" #2: STATE_QUICK_I1: initiate
    002 "euc1-one" #2: transition from state STATE_QUICK_I1 to state STATE_QUICK_I2
    004 "euc1-one" #2: STATE_QUICK_I2: sent QI2, IPsec SA established tunnel mode {ESP=>0x75ca3837 <0x410efc2c xfrm=AES_128-HMAC_SHA1 NATOA=none NATD=none DPD=passive}
    # tcpdump -i eth0 -n port 4500 or esp  &
    tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
    listening on eth0, link-type EN10MB (Ethernet), capture size 65535 bytes
    # ping 172.29.6.30
    PING 172.29.6.30 (172.29.6.30) 56(84) bytes of data.
    17:15:23.884243 IP 10.102.168.222 > 54.239.63.154: ESP(spi=0x75ca3837,seq=0x1), length 132
    17:15:23.884243 IP 10.102.168.222 > 54.239.63.154: ESP(spi=0x75ca3837,seq=0x1), length 132
    17:15:23.975522 IP 54.239.63.154 > 10.102.168.222: ESP(spi=0x410efc2c,seq=0xc65d40), length 132
    17:15:23.975522 IP 54.239.63.154 > 10.102.168.222: ESP(spi=0x410efc2c,seq=0xc65d40), length 132
    64 bytes from 172.29.6.30: icmp_seq=1 ttl=62 time=91.3 ms
    ^C
    --- 172.29.6.30 ping statistics ---
    1 packets transmitted, 1 received, 0% packet loss, time 0ms
    rtt min/avg/max/mdev = 91.331/91.331/91.331/0.000 ms

Note that our outgoing spi is 0x75ca3837 and their return spi is
0x410efc2c. Now let's bring up the second tunnel

    # ipsec auto --up euc1-two
    002 "euc1-two" #3: initiating Quick Mode PSK+ENCRYPT+TUNNEL+PFS+UP+SAREF_TRACK+IKE_FRAG_ALLOW+NO_IKEPAD {using isakmp#1 msgid:470e1e9a proposal=AES(12)_128-SHA1(2)_000 pfsgroup=OAKLEY_GROUP_MODP1024}
    117 "euc1-two" #3: STATE_QUICK_I1: initiate
    002 "euc1-two" #3: transition from state STATE_QUICK_I1 to state STATE_QUICK_I2
    004 "euc1-two" #3: STATE_QUICK_I2: sent QI2, IPsec SA established tunnel mode {ESP=>0xe3301004 <0x6a6cc99f xfrm=AES_128-HMAC_SHA1 NATOA=none NATD=none DPD=passive}
    # ping 169.254.237.17
    PING 169.254.237.17 (169.254.237.17) 56(84) bytes of data.
    17:15:36.184517 IP 10.102.168.222 > 54.239.63.154: ESP(spi=0xe3301004,seq=0x1), length 132
    17:15:36.184517 IP 10.102.168.222 > 54.239.63.154: ESP(spi=0xe3301004,seq=0x1), length 132
    17:15:36.275543 IP 54.239.63.154 > 10.102.168.222: ESP(spi=0x6a6cc99f,seq=0xc65d41), length 132
    17:15:36.275543 IP 54.239.63.154 > 10.102.168.222: ESP(spi=0x6a6cc99f,seq=0xc65d41), length 132
    64 bytes from 169.254.237.17: icmp_seq=1 ttl=64 time=91.0 ms
    ^C
    --- 169.254.237.17 ping statistics ---
    1 packets transmitted, 1 received, 0% packet loss, time 0ms
    rtt min/avg/max/mdev = 91.079/91.079/91.079/0.000 ms

Note that our outgoing spi is 0xe3301004 and their return spi is
0x6a6cc99f. So let's ping the first tunnel again

    # ping 172.29.6.30
    PING 172.29.6.30 (172.29.6.30) 56(84) bytes of data.
    17:15:32.932297 IP 10.102.168.222 > 54.239.63.154: ESP(spi=0x75ca3837,seq=0x2), length 132
    17:15:32.932297 IP 10.102.168.222 > 54.239.63.154: ESP(spi=0x75ca3837,seq=0x2), length 132
    17:15:33.023519 IP 54.239.63.154 > 10.102.168.222: ESP(spi=0x6a6cc99f,seq=0xc65d40), length 132
    17:15:33.023519 IP 54.239.63.154 > 10.102.168.222: ESP(spi=0x6a6cc99f,seq=0xc65d40), length 132
    ^C
    --- 172.29.6.30 ping statistics ---
    1 packets transmitted, 0 received, 100% packet loss, time 0ms

Note that our outgoing spi is still 0x75ca3837 from the first tunnel but
their return spi is <b>0x6a6cc99f</b> instead of0x410efc2c. They
mistakenly used the spi from the 2nd tunnel for the 1st tunnel!

## The elastic IP and the RFC1918 native IP address

Your AWS instance has a temporary RFC1918 IP address. The Amazon cloud
NATs this to your permanent public IP address, called the "elastic IP".

If you are want to connect the elastic IP address to a remote VPN, you
need to ensure that the encrypted packets created have the elastic IP as
the source address. When using IPsec, the kernel needs to create packets
with the elastic IP (eg a.b.c.d) as source address for packets to be
encrypted, but it can only do this properly if the IP is actually
configured on the host. It is recommended to configure the elastic IP as
an additional IP on the loopback interface, for example on the amazon
stock AMI create */etc/sysconfig/network-scripts/ifcfg-lo:elastic*:

    DEVICE=lo:elastic
    # use your elastic ip here
    IPADDR=a.b.c.d
    NETMASK=255.255.255.255
    ONBOOT=yes
    NAME=elasticIP

You can manually add it without restarting using:

    ip addr add a.b.c.d/32 dev lo:elastic

Next, you configure a "subnet" containing the elastic IP by setting
leftsubnet=elasticip/32.

{{ ambox \| nocat=true \| type=important \| text = Do not use the
leftsourceip= option to automatically create the alias when using
elastic IP's, or you will end up with broken route on your system
preventing it from reaching the remote subnets. }}

Note that using an Elastic IP technically means that your AWS IPsec
server is "behind NAT". Some Microsoft Windows operating systems need to
set the
[AssumeUDPEncapsulationContextOnSendRul](http://support.microsoft.com/kb/947234)
registry value to connect to IPsec servers behind NAT. furthermore, the
IP address on the AWs instance is dynamic, so it should not appear in
configuration files or else those would need to be updated when the
internal IP address of the machine changes after a reboot.

## ESP packet filter

The Amazon internal cloud network does not route IPsec ESP or AH
packets. These packets need to be encapsulated in UDP. While normally
the NAT detection takes care of this ESPinUDP encapsulation, if NAT is
not detected (for example because this is an IPsec connection between
two instances in the Amazon cloud), you can force encapsulation by
setting **encapsulation=yes**.

## NAT exclusion

If you are using NAT or MASQUERADE to provide connectivity to a subnet
behind your AWS machine, you need to exclude NAT for those
source/destination combinations that need to be encrypted via IPsec. For
example, if you have 10.0.2.0/24 behind your AWS server and
172.16.0.0/16 as subnet behind the remote IPsec gateway, use iptables
rules similar to:

    iptables -t nat -I POSTROUTING -s 10.0.2.0/24 -d 172.16.0.0/16 -j RETURN
    iptables -t nat -A POSTROUTING -s 10.0.2.0/24 -d 0.0.0.0/0 -j MASQUERADE -o eth0

## Example configuration

    # /etc/ipsec.conf on Amazon EC2 instance
    version 2.0

    config setup
         # we should exclude ourselves, but that's dynamic.
         virtual-private=%v4:10.0.0.0/8,%v4:192.168.0.0/16,%v4:172.16.0.0/12,%v4:25.0.0.0/8,%v4:100.64.0.0/10,%v6:fd00:
    :/8,%v6:fe80::/10
         protostack=netkey

    conn amazonec2
         # preshared key
         authby=secret
         # load connection and initiate it on startup
         auto=start
         # Amazon does not route ESP/AH packets, so these must be encapsulated in UDP
         encapsulation=yes
         # use %defaultroute to find our local IP, since it is dynamic
         left=%defaultroute
         # set our ID to your (static) elastic IP
         leftid=a.b.c.d
         # remote endpoint IP
         right=1.2.3.4
         # If you want to only connect the amazon VPS using its elastic IP, use:
         #    leftsubnet=<elastic ip>/32
         # If you want to connect a local subnet on the AWS VPC to the remote endpoint, configure it as a normal subnet:
         #   leftsubnet=10.123.123.0/24
         # And if the remote endpoint is a subnet, you also use a regular subnet configuration for the remote subnet:
         # rightsubnet=192.0.1.0/24
         # Multiple subnets can be done using:
         #    leftsubnets=10.123.123.0/24,10.100.0.0/16
         #    rightsubnets=192.0.1.0/24,192.0.2.0/24

    # /etc/ipsec.secrets
    # If you have multiple sites with different PSKs, you need to be a bit more subtle here
    # We use 0.0.0.0 for our local IP because the instance IP is dynamic and we want to avoid
    # hardcoding it into configurations where possible.
    193.110.157.131 0.0.0.0 %any : PSK "mysecret"

# Juniper

## Juniper Example

Although technically not an interop problem, Ryan Waldron
\<ryanw@phxx.com\> contributed a working Juniper configuration that is
compatible with libreswan

Juniper endpoint:

    set ike gateway "GW-01" address <Your SM IP Here> Main outgoing-zone "V1-Untrust" preshare "Your PSK Here" proposal "pre-g2-3des-md5"
    set ike respond-bad-spi 1
    set ike ikev2 ike-sa-soft-lifetime 60
    unset ike ikeid-enumeration
    unset ike dos-protection
    unset ipsec access-session enable
    set ipsec access-session maximum 5000
    set ipsec access-session upper-threshold 0
    set ipsec access-session lower-threshold 0
    set ipsec access-session dead-p2-sa-timeout 0
    unset ipsec access-session log-error
    unset ipsec access-session info-exch-connected
    unset ipsec access-session use-error-log
    set vpn "VPN-01" gateway "GW-01" no-replay tunnel idletime 0 proposal "g2-esp-3des-md5"
    set vrouter "untrust-vr"
    exit
    set vrouter "trust-vr"
    exit
    set url protocol websense
    exit
    set policy id 58 from "V1-Trust" to "V1-Untrust" "10.10.0.0/24" "172.16.0.0/16-VPN-01" "ANY" tunnel vpn "VPN-01" id 0x23 pair-policy 57 log
    set policy id 58
    set log session-init
    exit
    set policy id 57 from "V1-Untrust" to "V1-Trust" "172.16.0.0/16-VPN-01" "10.10.0.0/24" "ANY" tunnel vpn "VPN-01" id 0x23 pair-policy 58 log
    set policy id 57
    set log session-init
    exit

And the corresponding libreswan endpoint:

    conn NetScreen
            ike=3des-md5
            esp=3des-md5
            authby=secret
            keyingtries=0
            left=<Juniper IP Here>
            leftsubnet=<Remote Subnet Here>
            leftnexthop=%defaultroute
            right=<SW IP Here>
            rightsubnet=<Local Subnet Here>
            rightnexthop=%defaultroute
            compress=no
            auto=start

There is also another example of configuring Juniper with libreswan by
[Pedro
Kiefer](http://www.pedro.kiefer.com.br/2012/10/openswan-tunnel-to-juniper-ssg)

## Juniper shows Bad SPI messages in the Event Log

When libreswan and juniper rekey around the same time, the Juniper can
get confused. This bug is triggered especially if you have more than one
tunnel defined and are trying to bring up all of them at once. A
workaround for this is to increase the **ike soft-lifetime-buffer** on
the Juniper from the default 10 to 40. See also this [Juniper Knowledge
Base
Article](http://kb.juniper.net/InfoCenter/index?page=content&id=KB10091&pmv=print)

## Juniper continuously rekeying

Some have reported a bug in Juniper routers where the IPsec connection
is rekeying continuously. This problem is apparently caused by the
**vpn-monitor** option in the firewall policy configuration. Disabling
this option stopped the rekeying and resulted in a stable tunnel.

# Microsoft Windows

## L2TP / IPsec with the server behind NAT

Windows clients require some registry settings to be allowed to connect
to an IPsec server behind NAT:

on Windows Vista and newer

    REG ADD HKLM\SYSTEM\CurrentControlSet\Services\PolicyAgent /v AssumeUDPEncapsulationContextOnSendRule /t REG_DWORD /d 0x2 /f

on Windows XP

    REG ADD HKLM\SYSTEM\CurrentControlSet\Services\IPsec /v AssumeUDPEncapsulationContextOnSendRule /t REG_DWORD /d 0x2 /f

## Windows Certificate requirements

Windows 8.x and 10 require the IKEv2 Machine Certificate to have the
"Client Auth" **and** "Server Auth" ExtendedKeyUsage ("EKU") attribute
to be set. Using ertificates that lack these attributes will result in
"*Error 13806: IKE failed to find valid machine certificate...*"

alternatively, you can disable all EKU checks using this registry file
or using regedit:

    REG ADD HKLM\SYSTEM\CurrentControlSet\services\RasMan\Parameters /v DisableIKENameEkuCheck /t REG_DWORD /d 0x1 /f

For further information, see this
\[<http://technet.microsoft.com/en-us/library/dd941612(v=ws.10>).aspx
Microsoft\] link

## Windows IKEv2 default DiffieHellman proposal too weak

Microsoft Windows IKEv2 insists on using **ONLY** DiffieHellman 1024 (DH
group 2) which is no longer part of the default proposal set of
libreswan because it is too weak. Additionally, other clients such as
iOS/OSX refuse to use this weak group completely. As a result, to
support both Apple and Microsoft devices, the following ike= line is
required:

        ike=aes256-sha2_512;modp2048,aes128-sha2_512;modp2048,aes256-sha1;modp1024,aes128-sha1;modp1024