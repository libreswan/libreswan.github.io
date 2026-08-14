I played with the AWS and [\| libreswan
OE](https://aws.amazon.com/quickstart/architecture/libreswan-ipsec-mesh)
. Here are some notes and commands I used. May be eventually polish this
to a better document.

NOTE: the outputs are mixed from different instances. You may noitce IP
address are not consistent. Once I have more experience I would be
tempted to make consistent set of outputs for more troubleshooting. send
comments to swan@lists.libreswan.org.

# AWS EC2 instance experience, after ipsec works

## iperf and ipsec trafficstatus

    [root@ip-172-31-22-162 ec2-user]# iperf3 -R -i 2 -c  172.31.24.146
    Connecting to host 172.31.24.146, port 5201
    Reverse mode, remote host 172.31.24.146 is sending
    [  4] local 172.31.22.162 port 49756 connected to 172.31.24.146 port 5201
    [ ID] Interval           Transfer     Bandwidth
    [  4]   0.00-2.00   sec   241 MBytes  1.01 Gbits/sec
    [  4]   2.00-4.00   sec   238 MBytes  1.00 Gbits/sec
    [  4]   4.00-6.00   sec   235 MBytes   984 Mbits/sec
    [  4]   6.00-8.00   sec   231 MBytes   969 Mbits/sec
    [  4]   8.00-10.00  sec   235 MBytes   987 Mbits/sec
    - - - - - - - - - - - - - - - - - - - - - - - - -
    [ ID] Interval           Transfer     Bandwidth       Retr
    [  4]   0.00-10.00  sec  1.15 GBytes   992 Mbits/sec  133             sender
    [  4]   0.00-10.00  sec  1.15 GBytes   991 Mbits/sec                  receiver

    iperf Done.

    NOTE: AWS instance t2.micro is fast 1 Gbps of encrypted traffic! This is amazing. I do not see it that often in KVM environments.

    [root@ip-172-31-22-162 ec2-user]# ipsec  whack --trafficstatus
    006 #2: "private#172.31.0.0/16"[1] ...172.31.24.146, type=ESP, add_time=1557943233, inBytes=2167022, outBytes=1238843830, id='CN=ip-172-31-24-146.us-east-2.compute.internal'

## Look at certificates and public keys

    ipsec whack --listcerts
    000
    000 List of X.509 End Certificates:
    000
    000 End certificate "hostcert" - SN: 0x0207b57f2ca8
    000   subject: CN=ip-172-31-22-162.us-east-2.compute.internal
    000   issuer: CN=ipsec.us-east-2
    000   not before: Wed May 15 23:03:00 2019
    000   not after: Fri Jun 14 23:03:00 2019
    000   4096 bit RSA: has private key
    <pre>

    <pre>
    [root@ip-172-31-22-162 ec2-user]# ipsec whack --listpubkeys
    000
    000 List of RSA Public Keys:
    000
    000 May 16 05:37:51 2019, 4096 RSA Key AwEAAaOQ6 (no private key), until Jun 14 23:03:00 2019 ok
    000        ID_DER_ASN1_DN 'CN=ip-172-31-22-162.us-east-2.compute.internal'
    000        Issuer 'CN=ipsec.us-east-2'
    000 May 16 05:37:51 2019, 4096 RSA Key AwEAAaOQ6 (no private key), until Jun 14 23:03:00 2019 ok
    000        ID_IPV4_ADDR '172.31.22.162'
    000        Issuer 'CN=ipsec.us-east-2'
    <pre>

    <pre>
    ipsec whack --listpubkeys
    000
    000 List of RSA Public Keys:
    000
    000 May 16 05:31:53 2019, 4096 RSA Key AwEAAZsHF (no private key), until Jun 14 23:03:01 2019 ok
    000        ID_DER_ASN1_DN 'CN=ip-172-31-24-146.us-east-2.compute.internal'
    000        Issuer 'CN=ipsec.us-east-2'
    000 May 16 05:31:53 2019, 4096 RSA Key AwEAAZsHF (no private key), until Jun 14 23:03:01 2019 ok
    000        ID_IPV4_ADDR '172.31.24.146'
    000        Issuer 'CN=ipsec.us-east-2'
    000 May 16 05:27:00 2019, 4096 RSA Key AwEAAaOQ6 (has private key), until Jun 14 23:03:00 2019 ok
    000        ID_DER_ASN1_DN 'CN=ip-172-31-22-162.us-east-2.compute.internal'
    000        Issuer 'CN=ipsec.us-east-2'
    000 May 16 05:27:00 2019, 4096 RSA Key AwEAAaOQ6 (has private key), until Jun 14 23:03:00 2019 ok
    000        ID_IPV4_ADDR '172.31.22.162'

## ipsec status output for OE connections

    000 "private":     oriented; my_ip=unset; their_ip=unset; mycert=hostcert; my_updown=ipsec _updown;
    000 "private":   xauth us:none, xauth them:none,  my_username=[any]; their_username=[any]
    000 "private":   our auth:rsasig, their auth:rsasig
    000 "private":   modecfg info: us:none, them:none, modecfg policy:push, dns:unset, domains:unset, banner:unset, cat:unset;
    000 "private":   labeled_ipsec:no;
    000 "private":   policy_label:unset;
    000 "private":   CAs: 'CN=ipsec.us-east-2'...'CN=ipsec.us-east-2'
    000 "private":   ike_life: 3600s; ipsec_life: 28800s; replay_window: 32; rekey_margin: 540s; rekey_fuzz: 100%; keyingtries: 0;
    000 "private":   retransmit-interval: 500ms; retransmit-timeout: 60s;
    000 "private":   sha2-truncbug:no; initial-contact:no; cisco-unity:no; fake-strongswan:no; send-vendorid:no; send-no-esp-tfc:no;
    000 "private":   policy: RSASIG+ENCRYPT+PFS+OPPORTUNISTIC+GROUP+GROUTED+IKEV2_ALLOW+IKEV2_PROPOSE+SAREF_TRACK+IKE_FRAG_ALLOW+ESN_NO+failureDROP;
    000 "private":   conn_prio: 32,0; interface: eth0; metric: 0; mtu: unset; sa_prio:auto; sa_tfc:none;
    000 "private":   nflog-group: unset; mark: unset; vti-iface:unset; vti-routing:no; vti-shared:no; nic-offload:auto;
    000 "private":   our idtype: ID_DER_ASN1_DN; our id=CN=ip-172-31-24-146.us-east-2.compute.internal; their idtype: %fromcert; their id=%fromcert
    000 "private":   dpd: action:hold; delay:0; timeout:0; nat-t: encaps:auto; nat_keepalive:yes; ikev1_natt:both
    000 "private":   newest ISAKMP SA: #0; newest IPsec SA: #0;
    000 "private#172.31.0.0/16": 172.31.24.146[CN=ip-172-31-24-146.us-east-2.compute.internal]---172.31.16.1...%opportunistic[%fromcert]===172.31.0.0/16; prospective erouted; eroute owner: #0
    000 "private#172.31.0.0/16":     oriented; my_ip=unset; their_ip=unset; mycert=hostcert; my_updown=ipsec _updown;
    000 "private#172.31.0.0/16":   xauth us:none, xauth them:none,  my_username=[any]; their_username=[any]
    000 "private#172.31.0.0/16":   our auth:rsasig, their auth:rsasig
    000 "private#172.31.0.0/16":   modecfg info: us:none, them:none, modecfg policy:push, dns:unset, domains:unset, banner:unset, cat:unset;
    000 "private#172.31.0.0/16":   labeled_ipsec:no;
    000 "private#172.31.0.0/16":   policy_label:unset;
    000 "private#172.31.0.0/16":   CAs: 'CN=ipsec.us-east-2'...'CN=ipsec.us-east-2'
    000 "private#172.31.0.0/16":   ike_life: 3600s; ipsec_life: 28800s; replay_window: 32; rekey_margin: 540s; rekey_fuzz: 100%; keyingtries: 0;
    000 "private#172.31.0.0/16":   retransmit-interval: 500ms; retransmit-timeout: 60s;
    000 "private#172.31.0.0/16":   sha2-truncbug:no; initial-contact:no; cisco-unity:no; fake-strongswan:no; send-vendorid:no; send-no-esp-tfc:no;
    000 "private#172.31.0.0/16":   policy: RSASIG+ENCRYPT+PFS+OPPORTUNISTIC+GROUPINSTANCE+IKEV2_ALLOW+IKEV2_PROPOSE+SAREF_TRACK+IKE_FRAG_ALLOW+ESN_NO+failureDROP;
    000 "private#172.31.0.0/16":   conn_prio: 32,0; interface: eth0; metric: 0; mtu: unset; sa_prio:auto; sa_tfc:none;
    000 "private#172.31.0.0/16":   nflog-group: unset; mark: unset; vti-iface:unset; vti-routing:no; vti-shared:no; nic-offload:auto;
    000 "private#172.31.0.0/16":   our idtype: ID_DER_ASN1_DN; our id=CN=ip-172-31-24-146.us-east-2.compute.internal; their idtype: %fromcert; their id=%fromcert
    000 "private#172.31.0.0/16":   dpd: action:hold; delay:0; timeout:0; nat-t: encaps:auto; nat_keepalive:yes; ikev1_natt:both
    000 "private#172.31.0.0/16":   newest ISAKMP SA: #0; newest IPsec SA: #0;
    000 "private#172.31.0.0/16"[1]: 172.31.24.146[CN=ip-172-31-24-146.us-east-2.compute.internal]---172.31.16.1...172.31.22.162[CN=ip-172-31-22-162.us-east-2.compute.internal]; erouted; eroute owner: #2
    000 "private#172.31.0.0/16"[1]:     oriented; my_ip=unset; their_ip=unset; mycert=hostcert; my_updown=ipsec _updown;
    000 "private#172.31.0.0/16"[1]:   xauth us:none, xauth them:none,  my_username=[any]; their_username=[any]
    000 "private#172.31.0.0/16"[1]:   our auth:rsasig, their auth:rsasig
    000 "private#172.31.0.0/16"[1]:   modecfg info: us:none, them:none, modecfg policy:push, dns:unset, domains:unset, banner:unset, cat:unset;
    000 "private#172.31.0.0/16"[1]:   labeled_ipsec:no;
    000 "private#172.31.0.0/16"[1]:   policy_label:unset;
    000 "private#172.31.0.0/16"[1]:   CAs: 'CN=ipsec.us-east-2'...'CN=ipsec.us-east-2'
    000 "private#172.31.0.0/16"[1]:   ike_life: 3600s; ipsec_life: 28800s; replay_window: 32; rekey_margin: 540s; rekey_fuzz: 100%; keyingtries: 0;
    000 "private#172.31.0.0/16"[1]:   retransmit-interval: 500ms; retransmit-timeout: 60s;
    000 "private#172.31.0.0/16"[1]:   sha2-truncbug:no; initial-contact:no; cisco-unity:no; fake-strongswan:no; send-vendorid:no; send-no-esp-tfc:no;
    000 "private#172.31.0.0/16"[1]:   policy: RSASIG+ENCRYPT+PFS+OPPORTUNISTIC+GROUPINSTANCE+IKEV2_ALLOW+IKEV2_PROPOSE+SAREF_TRACK+IKE_FRAG_ALLOW+ESN_NO+failureDROP;
    000 "private#172.31.0.0/16"[1]:   conn_prio: 32,0; interface: eth0; metric: 0; mtu: unset; sa_prio:auto; sa_tfc:none;
    000 "private#172.31.0.0/16"[1]:   nflog-group: unset; mark: unset; vti-iface:unset; vti-routing:no; vti-shared:no; nic-offload:auto;
    000 "private#172.31.0.0/16"[1]:   our idtype: ID_DER_ASN1_DN; our id=CN=ip-172-31-24-146.us-east-2.compute.internal; their idtype: ID_DER_ASN1_DN; their id=CN=ip-172-31-22-162.us-east-2.compute.internal
    000 "private#172.31.0.0/16"[1]:   dpd: action:hold; delay:0; timeout:0; nat-t: encaps:auto; nat_keepalive:yes; ikev1_natt:both
    000 "private#172.31.0.0/16"[1]:   newest ISAKMP SA: #1; newest IPsec SA: #2;
    000 "private#172.31.0.0/16"[1]:   IKEv2 algorithm newest: AES_GCM_16_256-HMAC_SHA2_512-MODP2048
    000 "private#172.31.0.0/16"[1]:   ESP algorithm newest: AES_GCM_16_256-NONE; pfsgroup=<Phase1>
    000 "private-or-clear": 172.31.24.146[CN=ip-172-31-24-146.us-east-2.compute.internal]---172.31.16.1...%opportunisticgroup[%fromcert]; unrouted; eroute owner: #0

    000 IPsec SAs: total(1), authenticated(0), anonymous(1)
    000
    000 #1: "private#172.31.0.0/16"[1] ...172.31.22.162:500 STATE_PARENT_I3 (PARENT SA established); EVENT_v2_SA_REPLACE_IF_USED_IKE in 2841s; newest ISAKMP; idle; import:local rekey
    000 #2: "private#172.31.0.0/16"[1] ...172.31.22.162:500 STATE_V2_IPSEC_I (IPsec SA established); EVENT_v2_SA_REPLACE_IF_USED in 27831s; newest IPSEC; eroute owner; isakmp#1; idle; import:local rekey
    000 #2: "private#172.31.0.0/16"[1] ...172.31.22.162 esp.d6d830dc@172.31.22.162 esp.475291e5@172.31.24.146 ref=0 refhim=0 Traffic: ESPin=128B ESPout=128B! ESPmax=0B
    000

## look at NSS db

The host certificate is strored in NSS db on the instance. Here is more
detailed look

- ipsec whack --listcert
- ipsec whack --listpubkeys
- certutil -L -d sql://etc/ipsec.d

<!-- -->

    Certificate Nickname                                         Trust Attributes
                                                                 SSL,S/MIME,JAR/XPI

    hostcert                                                     u,u,u
    ipsec.us-east-1                                              ,,
    <pre>

    *  certutil -L -n hostcert -d sql://etc/ipsec.d
    <pre>
            Signature Algorithm: PKCS #1 SHA-256 With RSA Encryption
            Issuer: "CN=ipsec.us-east-1"
            Validity:
                Not Before: Wed Jun 05 08:02:08 2019
                Not After : Fri Jul 05 08:02:08 2019
            Subject: "CN=ip-172-31-34-68.ec2.internal"

    Name: Certificate Subject Alt Name
    IP Address: 54.161.124.255
    DNS name: "ec2-54-161-124-255.compute-1.amazonaws.com"