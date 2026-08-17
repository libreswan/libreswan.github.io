"ipsec ca" command:

In order to simplify the creation and management of certificates for use
with Libreswan, the 'ipsec ca' command is proposed. A generalized use
case would be a VPN gateway with roadwarriors that occasionally need to
be replaced and added to, where the issuing CA is standalone, specific
to the gateway (ie. not a previously issued organizational sub CA). We
should not allow a lot of specific certificate customization with these
commands

calling ipsec ca, the ipsec script runs \$FINALLIBEXECDIR/_ipsec_ca
which is a python2.7 script, that calls on certutil and crlutil

1.  ipsec ca --new-ca

initializes sql:/var/lib/ipsec/ and creates a new self-signed CA with
its private key in the database. options: --subject
"CN=gateway,O=company,OU=security" --months X Other extensions?
emailaddr, dns name, crl/ocsp dist points

Command to run: certutil -S -k rsa -g 4096 -n "{CN from --subject}" -s
"{--subject}" -v {--months} -t "CT,," -x -d sql:/var/lib/ipsec

some extension options would be: -4 crl -7 emailAddrs -8 DNS-names OCSP
ext uses --extAIA

1.  ipsec ca --new-host
2.  ipsec ca --new-crl
3.  ipsec ca --revoke