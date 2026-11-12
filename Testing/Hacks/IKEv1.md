<!-- file-is-title -->

## Handling IKEv1's broken Quick Mode (aka Child SA)

IKEv1's Quick Mode (CREATE_CHILD_SA) exchange has three messages:

```
west -> east: propose SA
east -> west: accept SA, half IPsec param
west -> east: other half of IPsec param
```

The problem is that the initiator doesn't know when, and hence can't
wait for, the responder to complete the exchange.  This leads to to
the failure:

```
west #
 ipsec up westnet-eastnet
"westnet-eastnet" #1: initiating IKEv1 Main Mode connection
...
"westnet-eastnet" #2: IPsec SA established tunnel mode {ESP=>0xESPESP <0xESPESP xfrm=AES_CBC_128-HMAC_SHA1_96 DPD=passive}
west #
 ../../guestbin/ping-once.sh --up -I 192.0.1.254 192.0.2.254
DOWN unexpected
```

because the ping is sent before `east` has finished installing the
IPsec (Child) SA.

### Fix 1: Convert test to NN-test.sh form

For instance, `basic-pluto-01/` has:

|script|commands|
|------|--------|
|03-west-up.sh|`ipsec up westnet-eastnet`
|04-east-established.sh|`../../guestbin/wait-for-pluto.sh '^".*#2: IPsec SA established'`
|05-west-ping.sh|`../../guestbin/ping-once.sh --up -I 192.0.1.254 192.0.2.254`
||`ipsec trafficstatus`

so that the ping is only run after `east` has been confirmed as established

### Fix 2: Use `wait-for.sh OUTPUT/east.log`

For instance, `interop-ikev1-strongswan-17-compress` has:

```
west #
 ipsec up westnet-eastnet-ikev1
"westnet-eastnet-ikev1" #1: initiating IKEv1 Main Mode connection
...
"westnet-eastnet-ikev1" #2: IPsec SA established tunnel mode {ESP=>0xESPESP <0xESPESP xfrm=AES_CBC_256-HMAC_SHA1_96 IPCOMP=>0xCPI <0xCPI DPD=passive}
west #
 ../../guestbin/wait-for.sh --match 'CHILD_SA .* established' -- cat OUTPUT/east.charon.log
[IKE] <westnet-eastnet-ikev1|1> CHILD_SA westnet-eastnet-ikev1{1} established with SPIs SPISPI_i SPISPI_o and TS 192.0.2.0/24 === 192.0.1.0/24
west #
 ../../guestbin/ping-once.sh --up -I 192.0.1.254 192.0.2.254
up
```
