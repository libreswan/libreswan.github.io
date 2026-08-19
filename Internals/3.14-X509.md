Version 3.14 introduces significant changes to pluto's X509 certificate
handling. Prior to 3.14, pluto contained its own functions for
certificate and crl parsing and verification. This code is now removed
and has been replaced by the NSS library certificate functions.

## Database changes

Pluto uses an SQL format NSS database, by default in /etc/ipsec.d. This
format allows pluto to pick up changes to the database without requiring
a restart. When upgrading libreswan to 3.14, the 'ipsec checknss'
command run on service startup will attempt to upgrade the existing DBM
format database.

- ipsec checknss first detects if an upgrade is needed and runs a
  certutil --upgrade-merge on the database. If /etc/ipsec.d/nsspassword
  is present it will also preserve the database password from that file.
- Any certificates and crls in /etc/ipsec.d/cacerts and
  /etc/ipsec.d/crls will be imported into the upgraded database. If
  these are duplicate, or old, it won't replace anything current in the
  database.

**When using crlutil or certutil on the upgraded database, you must
always prefix the database path with 'sql:'.** For example, to list all
certificates:

    certutil -L -d sql:/etc/ipsec.d

Running certutil commands without the sql: prefix looks in the directory
for different database files that are not read by pluto, so don't get
mixed up! Alternately, you can set the NSS_DEFAULT_DB_TYPE environment
variable to 'sql:' and use certutil/crlutil as normal.

## Certificate changes

Pluto now uses CERT_Certificate structures instead of its internal
x509_cert_t structure. The certificates received over the IKE exchange
are verified with a call to CERT_PKIXVerifyCert, verifying the
certificate down to a root CA that is located in the NSS database. Since
the IKE exchange can include intermediate certificates, a temporary
import is performed on all certificate payloads received, which places
the intermediates into the NSS ephemeral cache. Doing this ensures that
the intermediate certs are also verified and used to complete the chain.

**The use of NSS certificates now considers the database trust
arguments.** Before, this did not matter to pluto as the NSS
certificates were only converted to the internal pluto certificate when
loaded.

The following trust strings should be used:

- End cert with private key: u,u,u
- Root CA: CT,,
- Intermediate CA: ,,
- Trusted Peer cert (no private key), OCSP responder cert: P,,

For example:

     [root@east ~]# certutil -L -d sql:/etc/ipsec.d

     Certificate Nickname                                         Trust Attributes
                                                                  SSL,S/MIME,JAR/XPI

     east                                                         u,u,u
     Libreswan test CA for mainca - Libreswan                     CT,,
     north                                                        P,,
     hashsha2                                                     P,,
     west-ec                                                      P,,
     nic                                                          P,,

The 'CT,,' trust flags on a CA ensure that the CA is valid for verifying
a certificate with the serverAuth/clientAuth EKU extensions. While these
are not particularly relevant to the IKE and IPsec standards, the NSS
library requires a server or client profile type to be specified during
verification. Some clients (Windows) requires client certificates to
contain the serverAuth EKU, and due to this NSS API limitation, there
will be a failover verification attempt for the serverAuth profile. This
way, pluto is able to handle certificates with either serverAuth or
clientAuth (or both) set.

For best compatibility with the NSS verification and other clients, at
least the digitalSignature and nonRepudiation extensions should be set
on end certificates.

**CA certificates must have a basicConstraints extension specifying that
it is a CA.**

## CRL changes

Previously, CRLs were placed into /etc/ipsec.d/crls and pluto loaded
them internally on startup. The /etc/ipsec.d/crls directory is no longer
used in 3.14 and it is required that CRLs are imported into the
database. This can be done with:

    crlutil -I -i <file> -d sql:/etc/ipsec.d

(TODO: add ipsec importcrl)

When the NSS database contains a valid CRL for a CA used during the IKE
exchange, the CRL status is used automatically during certificate
verification. Before verifying the certificate there is a check for the
issuer's CRL. The behavior of pluto has not changed in this regard - If
a CRL is expired or missing, pluto queues a crl fetch request to be
processed during the next check interval (crlcheckinterval). The fetch
thread uses curl to retrieve the current CRL at the CA's CRL URI. The
fetched blob is passed to a spawned helper program '_import_crl' that
attempts to import the blob as a CRL into the NSS database. Assuming
that the fetch resulted in an updated CRL, it is now cached and
available for any subsequent exchanges.

The configuration option "strictcrlpolicy" has been renamed to
"crl_strict"

In strict mode (crl_strict), a missing or expired CRL results in a
rejection. If a peer's exchange fails while using a good certificate due
to the CRL expiring in strict mode, setting a crlcheckinterval that
triggers between the peer's retransmit attempts will allow a fetch to
update the CRL and authorize the exchange. The peer will then only
notice a delay in connection.

Previously pluto allowed CRLs with an MD5 signature algorithm. These are
now rejected by NSS. You must use CRLs with a signature algorithm of at
least SHA-1.

## OCSP support

Switching to the NSS cert library now gives us OCSP support.

**To configure OCSP support, the following 'config setup' options are
provided:**

- ocsp_enable
  - enable or disable OCSP checks within NSS. yes/no. Default == no
- ocsp_uri
  - set a "default responder" uri: ex.
    "<http://nic.testing.libreswan.org:2560>". Default == unset
- ocsp_trust_name
  - set to the NSS nickname of the certificate used by the OCSP
    responder to sign the responses. Default == unset
  - this option goes together with ocsp_uri to enable a default
    responder.
- ocsp_timeout
  - set to the maximum time (in seconds) that pluto will block waiting
    on the OCSP response. Default == 2 seconds.
- ocsp_strict
  - 'yes' sets OCSP checking to "strict" which configures
    CERT_SetOCSPFailureMode with ocspMode_FailureIsVerification
  - 'no' (the default) sets it to
    ocspMode_FailureIsNotAVerificationFailure (perhaps this should not
    be default)

The following comment from NSS sources explains the failure modes:

`/*                                                                    `
` * ocspMode_FailureIsVerificationFailure:                             `
` * This is the classic behaviour of NSS.                              `
` * Any OCSP failure is a verification failure (classic mode, default).`
` * Without a good response, OCSP networking will be retried each time `
` * it is required for verifying a cert.                               `
` *                                                                    `
` * ocspMode_FailureIsNotAVerificationFailure:                         `
` * If we fail to obtain a valid OCSP response, consider the           `
` * cert as good.                                                      `
` * Failed OCSP attempts might get cached and not retried until        `
` * minimumSecondsToNextFetchAttempt.                                  `
` * If we are able to obtain a valid response, the cert                `
` * will be considered good, if either status is "good"                `
` * or the cert was not yet revoked at verification time.              `
` *                                                                    `
` * Additional failure modes might be added in the future.             `
` */                                                                   `

When enabling OCSP it is recommended to set ocsp_uri and ocsp_trust_name
together in order to enable a default responder. Without it, NSS will
rely solely on OCSP information contained in the certificates. Similar
to the problem of configuring CRL fetches that rely on the IPsec
connectivity, configuring an OCSP URI with an address that is only
reachable through the IPsec tunnel can be problematic. You should test
carefully and adjust the ocsp_timeout option if you are using OCSP
responders over an IPsec tunnel or the internet, but for best results
you should specify a default responder with an address on the LAN of the
ipsec host.

An OCSP responder certificate can be a CA, or a seperate certificate
issued just for the responder's OCSP service, and it must be pre-loaded
into the NSS database before starting pluto. The OCSP responder
certificate should have the OCSP Responder Certificate EKU extension,
and an OCSP authInfo ext. with the URI of the OCSP responder.

For example, the test harness has a certificate 'nic' used for OCSP. Its
extensions are:

`        Signed Extensions:`
`            Name: Certificate Basic Constraints`
`            Data: Is not a CA.`

`            Name: Certificate Key Usage`
`            Usages: Digital Signature`
`                    Non-Repudiation`
`                    Certificate Signing`
`                    CRL Signing `

`            Name: Extended Key Usage`
`                TLS Web Server Authentication Certificate`
`                TLS Web Client Authentication Certificate`
`                Code Signing Certificate`
`                OCSP Responder Certificate`

`            Name: Authority Information Access`
`            Method: PKIX Online Certificate Status Protocol`
`            Location: `
`                URI: "`[`http://nic.testing.libreswan.org:2560`](http://nic.testing.libreswan.org:2560)`" `

`            Name: CRL Distribution Points`
`            Distribution point:`
`                URI: "`[`http://nic.testing.libreswan.org/revoked.crl`](http://nic.testing.libreswan.org/revoked.crl)`"`

The CRL Signing/Certificate Signing KU extensions and Code Signing EKU
may also be required. This text should be updated when this is
confirmed.

OCSP requests are HTTP GET type through the NSS library. The NSS state
maintains an OCSP cache that can be cleared for a running instance of
pluto with 'ipsec auto --purgeocsp'.

## Test coverage

WIP..

Test list:

- nss-cert-0x
- nss-cert-chain-0x
- nss-cert-crl-0x
- nss-cert-ocsp-0x

1\. Requires ocspd installed on nic (available in fedora repo)

- - For CRL tests a fetch URL is provided by nic through launching a
    python SimpleHTTPServer from nicinit

2\. pyOpenSSL on testing _host_ system needs a patch to support
creating SHA-1 signed CRL.
<https://nohats.ca/ftp/pyOpenSSL/pyOpenSSL-0.14-4.fc21.noarch.rpm>