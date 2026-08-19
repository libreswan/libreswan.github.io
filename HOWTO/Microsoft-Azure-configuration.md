Azure IKEv2 (Route Based GW) Subnet to Subnet connection with libreswan
using PSK Example 

Contributed by Amir Naftali of Fortycloud

    conn conn2AzureRouteBasedGW
            authby=secret
            auto=start
            dpdaction=restart
            dpddelay=30
            dpdtimeout=120
            forceencaps=yes # not a must
            ike=aes256-sha1;modp1024
            ikelifetime=10800s
            ikev2=yes
            keyingtries=3
            left=%defaultroute
            leftid=<MY PUBLIC IP>
            leftsubnets=<Azure Local Network Gateway Subnets>
            pfs=yes
            phase2alg=aes128-sha1
            right=<Azure Route Based GW IP>
            rightid=<Azure Route Based GW IP>
            rightsubnets=<vNet Subnet>
            salifetime=3600s
            type=tunnel