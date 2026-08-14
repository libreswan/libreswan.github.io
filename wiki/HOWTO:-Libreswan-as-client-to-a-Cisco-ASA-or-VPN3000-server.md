Many companies have Cisco or cisco-comptable VPN setups to allow laptops
to connect to the enterprise network. This most often uses XAUTH with
PreSharedKeys. It requires some special handling which libreswan
activates with the remote_peer_type= option. The easiest way to
configure this is using Networkmanager-libreswan (or
NetworkManager-openswan on older distros). But you can do it using
manual connections as well:

First, you place the Groupname and Secret in /etc/ipsec.secrets:

    @Groupname : PSK "secret"

In /etc/ipsec.conf you would place the connection information, which
also includes the username and groupname:

    conn cisco
        # fill in your groupname and username
        leftid=@Groupname
        leftxauthusername=yourusername
        #
        # The proposals have to match exactly or the cisco stops talking
        ike=aes128-sha1;modp1024
        esp=aes128-sha1;modp1024
        right=cisco_dns_or_ip
        initial_contact=yes
        # nat-ikev1=drafts
        # cisco_unity=yes
        aggrmode=yes
        authby=secret
        left=%defaultroute
        leftxauthclient=yes
        leftmodecfgclient=yes
        remote_peer_type=cisco
        rightxauthserver=yes
        rightmodecfgserver=yes
        salifetime=24h
        #ikelifetime=1h
        ikelifetime=24h
        dpdaction=restart
        dpdtimeout=60
        dpddelay=30
            auto=add

It is possible, though less secure, to store the user password in
ipsec.secrets as well, provided you do not require unique token with
each password:

    @username : XAUTH "password"

If the password is in ipsec.secrets, the connection can use auto=start.
If not, then the connection needs to be started by NetworkManager or by
command line ipsec auto --up to allow typing in the password.