This meetup will be held immediately after
[IETF-90](http://www.ietf.org/meeting/90/index.html) in Toronto.

It was hosted by Paul Wouters.

Attenders: Antony Antony, D. Hugh Redelmeier, Matt Rogers, Tuomo Soini,
Kim Heino and Paul Wouters

## Agenda items

Meetup day sessions

- hostpair documentation / teachings in code (and/or wiki)
- relations between state and connection, switching, instantiation -
  teaching
- SADB userland documentation / teachings
- teaching directory structure for refactoring/cleanup

Important tasks discussed

- false "can not start crypto helper: failed to find any available
  worker" and load (also force_busy)
- quick scan of bugtracker
- make rpm / deb daily packages
- NSS and ipsec.secrets :RSA entries (obsolete, remove?)

## Work items in priority order

Coding style and refactoring

- 1 uncrustify fixups within the crypto boundary
- 1 refactoring to reduce crypto boundary
- 2 logging function sanity
- 3 coding style fixups after uncrustify
- 3 modularity of source files - directories

<!-- -->

- \- Simplifying the IKEv2 by expanding the state machine
- \- or Rewriting IKEv1 state machine the same way as IKEv2?

<!-- -->

- 2 cppcheck (action Paul: daily output)
- 2 coverity CHECKS (action Paul: daily output)
- 5 clang checks (action Paul: daily output)

<!-- -->

- 2 OE IPsec, AUTH_NONE, left/rightauthby=, adns lookups

<!-- -->

- 2 CREATE_CHILD_SA
- 3 CP payload (modeconfig for ikev2)
- 4 EAP (auth for IKEv2)

<!-- -->

- 1 statsd with xauth and traffic accounting (action paul/antony)
- 1 dns helpers removal
- 1 fix retransitmit=no, fix impair-retransmit and environment variable
  (action hugh)
- 1 when to release whack on failure (now after 20 minutes :)
  (action:hugh)
- 2 CA chains (action: Matt)
- 2 audit support (action: paul)
- 3 UNH certification bugfixing (action: paul)
- 3 TAHI tests bugfixing (action: paul)
- 3 ADNS dns helper -\> libunbound with libevent
- 3 retransmit timers, creating options, creating keywords, fuzzing
  sender/receivier, subsecond timers, retransmit fail parent state
  linger, 60s max? (action hugh)
- 3 "ipsec eroute" / ip xfrm xxxx replacement requirements for
  enduser/admin (action paul/antony)
- 3 ipsec status "brief" command for enduser/admin (action paul/antony)
- 4 FIPS certification bugfixing (action: paul)
- 4 decloning code
- 4 Resolving "warning comments", XXX TODO ???
- 4 Fix known missing code and/or file finding missing code as a bug in
  the tracker
- 4 cleanup bug tracker
- 4 NSS CRL/OCSP, phasing out /etc/ipsec.d/cacerts/ (action: matt)
- 5 dynamic interfacing and whack --listen / NM / libevent select loop
  replacement
- 5 fips failure should install %hold then fail
- 5 NSS and some userland IKE algo support (AES_GCM, AES_CCM, AES_CTR)
- 5 Default proposal list (decouple v1/v2, update v2 ?)
- 5 ike=/esp= parser
- 5 parser and generic restrictions (conflicting conns loading, etc)
- 5 multicast ipsec - (action: rgb)
- 5 what features can be dropped or simplified?
- 5+ ipsec failover (WIP at IETF)

<!-- -->

- 1 enter bug - Makefile fixes for lib/ so "make programs" updates it
  properly
- 1 enter bug - Makefile fixes for "make programs" when whack.c is
  updated
- 1 enter bug - Makefile fixes for not updating man pages when xml files
  did not change (put all xml in one dir?)
- 5 kvmplutotest vs containertest
- 5 KLIPS: what to do? namespace support? what minimal kernel version ?
  (note OCF) (action: rgb)
- 5 netkey uses pf_key, herbert wants us to stop that
- 2 machine parsable propeties for test suite description
- 4 changing/updating testsuite for new requirements (fuzzing, nfs/9p,
  convert from beaker?)
- 5 IKEv1 / IKEv2 cleanup / separation ?