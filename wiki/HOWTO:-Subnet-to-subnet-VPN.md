Building a tunnel between two endpoints for multiple subnets is pretty
simialar to a [host to host VPN](./HOWTO:-Host-to-host-VPN) tunnel.
Except you will see we are adding leftsubnets/rightsubnets statements.
We used the also= keyword to avoid adding the same information into each
connection.

    # /etc/ipsec.conf

    config setup
        #logfile=/var/log/pluto.log

    conn mysubnet
         also=mytunnel
         leftsubnet=192.0.1.0/24
         rightsubnet=192.0.2.0/24
         auto=start

    conn mysubnet6
         also=mytunnel
         connaddrfamily=ipv6
         leftsubnet=2001:db8:0:1::/64
         rightsubnet=2001:db8:0:2::/64
         auto=start

    conn mytunnel
        leftid=@west
        left=192.1.2.23
        leftrsasigkey=0sAQOrlo+hOafUZDlCQmXFrje/oZm [...] W2n417C/4urYHQkCvuIQ==
        rightid=@east
        right=192.1.2.45
        rightrsasigkey=0sAQO3fwC6nSSGgt64DWiYZzuHbc4 [...] D/v8t5YTQ==
        authby=rsasig

To test the tunnel on "west":

    # ping -n -c 4 -I 192.0.1.254 192.0.2.254
    PING 192.0.2.254 (192.0.2.254) from 192.0.1.254 : 56(84) bytes of data.
    64 bytes from 192.0.2.254: icmp_seq=1 ttl=64 time=0.XXX ms
    64 bytes from 192.0.2.254: icmp_seq=2 ttl=64 time=0.XXX ms
    64 bytes from 192.0.2.254: icmp_seq=3 ttl=64 time=0.XXX ms
    64 bytes from 192.0.2.254: icmp_seq=4 ttl=64 time=0.XXX ms
    --- 192.0.2.254 ping statistics ---
    4 packets transmitted, 4 received, 0% packet loss, time XXXX
    rtt min/avg/max/mdev = 0.XXX/0.XXX/0.XXX/0.XXX ms

The reason why you need to specify the source address for the ping
command is that Linux will always pick the "nearest IP" automatically.
Since the nearest IP would be 192.1.2.23, and that IP is not part of the
192.0.2.0/24 subnet, the ping would go out unencrypted. If you want all
communication between the gateways themselves to be encrypted, and it is
okay that they will talk to each other on their internal IP addresses,
you can use the leftsourceip= and rightsourceip= options:

    conn mysubnet
         also=mytunnel
         leftsubnet=192.0.1.0/24
         leftsourceip=192.0.1.254
         rightsubnet=192.0.2.0/24
         rightsourceip=192.0.2.254
         auto=start

libreswan will than add a route to the system for the remote subnet
using the "src <ipaddress>" parameter to accomplish this.

Alternatively, you could add IPsec tunnels for the host-host connection,
but you would also need to add tunnels for the host-subnet and
subnet-host connections. This is a little cumbersome, so usually people
just use the sourceip= options.