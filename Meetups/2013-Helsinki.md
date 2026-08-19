This meetup was hosted by Tuomo Soini. Besides Tuomo, this meeting was
attended by Antony Antony, D. Hugh Redelmeier, Paul Wouters, Kim and
Mika.

Agenda items

## uncrustify

## Testing Harness

do we want to integrate with CISCO?

## [crypto boundary and certification](/Security/Crypto-boundary-and-certification)

### ECC support for IKE and ESP

### /etc/ipsec.d ASN.1/PEM and and NSS / openssl

### Linux Secure Tunnel interface support

### pluto and DNS(SEC)

### Logging cleanup

### Retransmit timings

### New OE

### interface listening, binding, updating

### TAPROOM / TCLCALLOUT removal?

### ipsec eroute and ipsec auto --status replacement

### remove DEBUG switch for userland, possibly also klips. always set

### Status of IKEv2

### IKEv1 / IKEv2 disentanglment

### Website user and dev documentation

### Network Manager / whack API

### webca management with addresspool

### git branch/tree policies review

### roadmap?

### Feature matrix: strongswan vs libreswan

### lib/libpluto/

### state machine explination

### Specific Bug issues

Makefile.depend.linux : do we really need it in git? when i locally
re-generate it is different.

Connection validations: check invalid combinations when loading
connections. eg Con without matching CERT in NSS db. subnet(s) &
addresspool. Where is the appropriate place to do it? addcon or
starterwhack.c - set_whack_end . If it is whack we already parsed the
"also" conn lines we may be able to generate warnings/errors