<!-- file-is-title -->

## Handling IKEv1's broken three-way Quick Mode (aka Child SA)

IKEv1's Quick Mode (CREATE_CHILD_SA) exchange has three messages:

|direction|message|
|---------|-------|
|initiator -> responder| propose SA
|initiator <- responder| accept SA, half IPsec param
|initiator -> responder| other half of IPsec param

The problem is that the initiator has no way to known when the
responder has finished with the final message.  This leads to to the
failure:

```
west #
 ipsec up westnet-eastnet
"westnet-eastnet" #1: initiating IKEv1 Main Mode connection
...
"westnet-eastnet" #2: IPsec SA established tunnel mode ...
west #
 ../../guestbin/ping-once.sh --up -I 192.0.1.254 192.0.2.254
DOWN unexpected
```

because the ping is sent before the responder has finished installing
the IPsec (Child) SA.

_IKEv2 doesn't have this problem because it always sends a response._

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

For instance, in `interop-ikev1-strongswan-17-compress` the
`westrun.sh` script waits for `east` to log that the SA is established
before continuing to the ping:

```
west #
 ipsec up westnet-eastnet-ikev1
"westnet-eastnet-ikev1" #1: initiating IKEv1 Main Mode connection
...
"westnet-eastnet-ikev1" #2: IPsec SA established tunnel mode ...
west #
 ../../guestbin/wait-for.sh --match 'CHILD_SA .* established' -- cat OUTPUT/east.charon.log
[IKE] <westnet-eastnet-ikev1|1> CHILD_SA westnet-eastnet-ikev1{1} established with SPIs SPISPI_i SPISPI_o and TS 192.0.2.0/24 === 192.0.1.0/24
west #
 ../../guestbin/ping-once.sh --up -I 192.0.1.254 192.0.2.254
up
```
