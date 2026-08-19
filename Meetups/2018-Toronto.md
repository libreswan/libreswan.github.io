# Roadmap

- killing MAST
- Killing KLIPS

\- Disable KLIPS per default

\- Announce KLIPS will be removed first release after Feburary 2019

- Changing shunts

# Bugs

# Misc.

- technical debt
- testing using lightweight namespaces
- IKEv2 state name changes
- get state names out of enduser logging
- remove duplicate / similar logging functions
- logging to stderrlog or file
- Cleanup debug log messages that serve no good purpose anymore
- openwrt build / patched to upstream including all architectures
- logging groups too many and not used
- time data structures and complexity
- addconn thread work being done inline in pluto
- microstates
- compile without ikev1 support
- remove biddown ikev1/ikev2
- conn being ikev1 or ikev2 not both.
- shunks, chunks and other strings.
- pluto interface / ip discovery (bind to ANY)
- howto IKEv2 proplsals properly with existing
- enduser usability - simpler interface. (eg type=profile)
- compress for IKEv2 is broken
- simpler command tool / what to do whack / auto
- webgui discussion
- explain LSWLOG / LSWDEBUGLOG
- EAP-TLS and EAP-mschapv2 architecture, design external or internal
- XAUTH payload padding and Checkpoint
- IKEv1 duplicate messages
- IPv6 addresspool
- VTI and/or XFRMi support and obsoleting VTI or not
- Talk about Test Suite improvements
- teardown case for tests
- Storing packets for multiple exchanges at once to support simultanious
  exchange
- cleanup msgid to not require so many ntoh() / hton()
- Using reqid from ACQUIRE to improve find_host_connection
- split IKE_INIT from connection ???
- IKE_AUTH traffic selector mismatch handling
- MULTIPLE_AUTH / EAP support
- childless IKE SA
- Bug reporting github vs other
- Known issues file ?
- Introducing travis ?
- Introducing Coverity
- Website redo ? more HOWTO docs?
- phase out asn1.h
- merge in IKE_REDIRECT
- merge in TCP support
- XFRM bogus policy bug
- Function names ikev2_\* to v2_\*
- add ipsec auto/whack command that does parent-rekey and child-rekey

`  (can be used for hardwarefailover when IKE state is synced between nodes(`