# Using NAT to resolve an subnet IP conflict

VPNs often connect networks in the RFC-1918 address space, such as
10.0.0/8, 192.16.8.0.0/16 or 172.16.0.0/12. A problem arises when both
ends use the same address space. One of the parties, will need to NAT
their subnet to something else. For example

Remote end uses 10.0.0.0/8 Local end uses 10.6.6.0/24

Ask the remote for a range they do not use, for example 192.168.0.0/24

Build a connection using these subnets:

    conn vpn
        left=1.2.3.4
        leftsubnet=192.168.0.0/24
        right=5.6.7.8
        rightsubnet=10.0.0.0/8
        [...]

then add the required iptables NAT rules that avoids bad interaction
with existing rules or the IPsec processing:

    iptables -I POSTROUTING -m policy --dir out --pol ipsec -j ACCEPT
    iptables -I POSTROUTING -s 10.6.6.0/24 -d 10.0.0.0/8 -o ethX -j SNAT --to-source 192.168.0.1

You can also try to map a /24 to /24 and have all your machines
reachable on these alternative IP addresses, which should work using
another iptables rule to DNAT 192.168.0.X/24 to 10.6.6.X/24