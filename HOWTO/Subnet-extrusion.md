Often IPsec is deployed in a hub-and-spoke architecture. Each leaf node
has an IP range that is part of a larger range. Leaves communicate with
each other via the hub. This is called subnet extrusion. In the example
below we configure the head office with 10.0.0.0/8 and two branches that
use a smaller /24 subnet.

At the head office:

    conn branch1
        left=1.2.3.4
        leftid=@headoffice
        leftsubnet=0.0.0.0/0
        leftrsasigkey=0sA[...]
        #
        right=5.6.7.8
        rightid=@branch1
        righsubnet=10.0.1.0/24
        rightrsasigkey=0sAXXXX[...]
        #
        auto=start
        authby=rsasigkey

    conn branch2
        left=1.2.3.4
        leftid=@headoffice
        leftsubnet=0.0.0.0/0
        leftrsasigkey=0sA[...]
        #
        right=10.11.12.13
        rightid=@branch2
        righsubnet=10.0.2.0/24
        rightrsasigkey=0sAYYYY[...]
        #
        auto=start
        authby=rsasigkey

At the “branch1” office we use the same branch1 connection as above, but
additionally we use a pass-through connection to exclude our local LAN
traffic from being sent through the tunnel:

    conn branch1
        left=1.2.3.4
        leftid=@headoffice
        leftsubnet=0.0.0.0/0
        leftrsasigkey=0sA[...]
        #
        right=10.11.12.13
        rightid=@branch2
        righsubnet=10.0.1.0/24
        rightrsasigkey=0sAYYYY[...]
        #
        auto=start
        authby=rsasigkey

    conn passthrough
        left=127.0.0.1
        right=0.0.0.0
        leftsubnet=10.0.1.0/24
        rightsubnet=10.0.1.0/24
        authby=never
        type=passthrough
        auto=route