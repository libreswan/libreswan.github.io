When SElinux is enabled with a **targeted policy**, network labels can
be configured on the VPN tunnel to restrict the security context that is
allowed to pass via the VPN tunnel.

This basically looks like:

    # /etc/ipsec.conf

    config setup
        protostack=netkey
        # Use the private use number 32001. Older openswan versions use the squatted value of 10.
        secctx-attr-type=32001

    conn ipsec_selinux_tunnel
        # Labeled IPsec is currently only supported for IKEv1
        # IKEv2 is work in progress, see: https://tools.ietf.org/html/draft-ietf-ipsecme-labeled-ipsec-03
        ikev2=never
        leftid=@west
        left=1.2.3.4
        leftrsasigkey=0sAQ[...]
        rightid=@east
        right=5.6.7.8
        rightrsasigkey=0sAQ[...]
        authby=rsasig
        auto=start
        # Enable Labelled IPsec with the policy you want to allow across the VPN
        policy-label=system_u:object_r:ipsec_spd_t:s0

Note that some seliux-policy versions are missing one policy and you
might need to add the following selinux module:

    module local 1.0;

    require {
        type unconfined_t;
        type ipsec_spd_t;
        type ipsec_t;
        class association setcontext;
    }

    #============= ipsec_t ==============
    allow ipsec_t ipsec_spd_t:association setcontext;

    # Required if you run as a basic user.
    allow ipsec_t unconfined_t:association setcontext;

You can see the labels in the *ip xfrm state* output, for example:

    # ip xfrm state
    src 1.2.3.4 dst 5.6.7.8
        proto esp spi 0x436be694 reqid 16389 mode tunnel
        replay-window 32 flag af-unspec
        auth-trunc hmac(sha1) 0x4c7d6ff6a191951fc69d9c3def070db3e0d59ae5 96 enc cbc(aes) 0x3c624b14b79e6f2dd632d26d36d90ff7
        security context unconfined_u:unconfined_r:netserver_t:s0-s0:c0.c1023
    src 5.6.7.8 dst 1.2.3.4
        proto esp spi 0x3ad8e7fa reqid 16389 mode tunnel
        replay-window 32 flag af-unspec
        auth-trunc hmac(sha1) 0x91a06a54d2fd1899229129489bd1d766b8f00990 96 enc cbc(aes) 0x77a17777f44378970ffa25cdd2a8bd34
        security context unconfined_u:unconfined_r:netserver_t:s0-s0:c0.c1023