The libreswan IKE daemon uses the Mozilla [Network Security
Services](http://www.mozilla.org/projects/security/pki/nss/) ("NSS")
crypto library for all cryptographic functions during the IKE
negotiation.

## Introduction

NSS is a userspace library utilized by the libreswan IKE daemon
'pluto' for cryptographic operations.  NSS does not handle the IPsec
crypto operations inside of the kernel; these are handled seperately
by NETKEY or the KLIPS kernel module.

The NSS library exports a [PKCS#11
API](http://en.wikipedia.org/wiki/PKCS_11) for the application to
communicate to a cryptographic device.  The cryptographic device is
usually the "soft token" but can also be a Hardware Security Module
(HSM).

The advantage of using NSS is that pluto does not need to know in
detail how the cryptographic device works.  Pluto does not access any
private keys or data itself.  Instead, it uses the PK11 wrapper API of
NSS irrespective of the cryptographic device used.  Pluto hands over
work using the PK11 interface to NSS and never has direct access to
the private key material itself.  Both IKEv1 and IKEv2 operations are
performed using NSS.  Private RSA keys (raw RSA as well as X.509 based
private RSA keys) are stored inside NSS and those are not referenced
in /etc/ipsec.secrets.  X.509 keys and certificates are referenced
using their "nickname" instead of their filename in /etc/ipsec.conf.

While PreShared Key (PSK) calculations are done using NSS, the actual
preshared key ("secret") is still stored in /etc/ipsec.secrets.

Libreswan no longer needs its own FIPS certification, as all code
"within the crypto boundary" has been added to the NSS library.  So if
the NSS librart is FIPS certified, and the Linux kernel is fips
certified, then using libreswan for IKE and IPsec is FIPS certified
too.  Note that from time to time, the exact requirements change (for
example with respect to ICV handling in AES_GCM) and it might be that
patches or tweaks are neccessary.  This partially depends on the
certification lab involved with the testing as well.

If you are migrating from openswan with NSS or libreswan 3.13 or older
to libreswan 3.14 or higher, then you will be converted to the new NSS
SQL database format.  See **[3.14_X509](./Internals:-3.14-X509)**

## NSS command line tools

NSS provides a number of command line utilities for manipulating an
NSS database.  Libreswan enhances this by providing a wrapper for each
command that adds the path to Libreswan's NSS database.  For instance
`ipsec certutil -L` invokes `certutil -d /var/lib/ipsec/nss -L`.

- `ipsec certutil`: Look and modify libreswan's NSS database.  "ipsec
  initnss" uses `certutil` under the hood.

- `ipsec pk12util`: import and export certificates and keys from and
  to Libreswan's NSS database.  The "ipsec import" command is a simple
  wrapper around this utility.

- `ipsec modutil`: low-level manipulation of Libreswan's NSS database
  such as putting the database into FIPS mode or manipulating
  [hardware tokens](./HOWTO:-Using-NSS-Hardware-Tokens).

- `ipsec crlutil`: importing CRLs into Libreswan's NSS database

- `ipsec vfychain`: verifying certificates using tokens from
  Libreswan's NSS database

For more information on the underlying commands, see the NSS
documentation.

## Creating the NSS database for use with Libreswan

If you are not using a packaged libreswan version, you might need to
create a new NSS db before you can start libreswan.  This can be done
using:

    ipsec initnss

On Linux, Libreswan's NSS database is created in
`/var/lib/ipsec/nss/`.

When creating a database, you are prompted for a password.  The
default libreswan package install for RHEL/Fedora/CentOS uses an empty
password.  It is up to the administrator to decide on whether to use a
password or not.  However, a non-empty database password must be
provided when running in FIPS mode.

To change the empty password, run:

    ipsec certutil -W

Enter return for the "old password", then enter your new password
twice.

If you create the database with a password, and want to run NSS in
FIPS mode, you must create the password file
`/etc/ipsec.d/nsspassword` before starting libreswan.  The
`nsspassword` file must contain the password you provided when
creating NSS database.

If the NSS database is protected with a non-empty password, the
`nsspassword` file must exist for pluto to start.  The syntax of the
`nsspassword` file is:

    token_1_name:the_password
    token_2_name:the_password

The name of NSS softtoken (the default software NSS database) when NOT
running in FIPS mode is "NSS Certificate DB".  If you wish to use
software NSS database with password "secret", you would have the
following entry in the nsspassword file:

    NSS Certificate DB:secret

If running NSS in FIPS mode, the name of NSS softtoken is "NSS FIPS
140-2 Certificate DB".  If there are smartcards in the system, the
entries for passwords should be entered in this file as well.

Note: Do not enter any spaces before or after the token name or
password.

## Using raw keys with NSS

The `ipsec newhostkey` is used to create a raw key:

    ipsec newhostkey [--keytype {rsa,ecdsa,eddsa}] [--password password]

(by default an RSA key is created) The password is only required if
the NSS database is protected with a non-empty password.

Public key information is available using the `ipsec showhostkey`
command.  It can be used to generate left/right rsasigkey, eddsakey,
oe ecdsakey= entries suitable for use in `/etc/ipsec.conf`:

    # ipsec showhostkey --list
    < 1> RSA keyid: AwEAAbScF ckaid: 2ad438fc7f3b65706f0381520f9f106a9eba7a96
    # ipsec showhostkey --left --ckaid 2ad438fc7f3b65706f0381520f9f106a9eba7a96
        # rsakey AwEAAbScF
        leftrsasigkey=0sAwEAAbScFcIsVh6ee/nd7n4VEBRWnpuxefzzDFktmikoUcO76/gql0f67ySeugs8B/N7u/Jcn7NoOJmDZrcD4p5t2Qddzw5yl1sd2na6vN/eQvCFPrjHz6qX67qx+jExe8Jd6UxvwQC3bzGkJr8vt3sWpsUyfNsNdoxO7tE5uzumHv2Cm9Cwts80k4+I+qF1bKALY5jn/xAR1UGhZDxymfYfNJm0+dSmzMp8J9yw9fN5tt6eUKB/cuRHn7wfKEAd2E9PYcLeXaDnMJHyslIIxK5GXRK0nNGxMqPdJIzp4t1jBOJhd6HMEiaW9K08hVdwiz9pMTIM+DDhPvtMueR2WZ7KUSM=

## Using certificates with NSS

Any X.509 certificate management system can be used to generate
Certificate Agencies, certificates, pkcs12 files and CRLs.  Common
tools people use are the openssl command, the GTK utility `tinyca2`,
or the NSS `certutil` command.

Below, we will be using the nss tools to generate certificates in
Libreswan's NSS database:

### To create a certificate authority (CA certficate)

    ipsec certutil -S -k rsa -n "ExampleCA" -s "CN=Example CA Inc" -v 12 \
            -t "CT,C,C" -x

It creates a certificate with RSA keys (-k rsa) with the nick name
"ExampleCA", and with common name "Example CA Inc" in Libreswan's NSS
database.  The option "-v" specifies the certificates validity period.
"-t" specifies the attributes of the certificate.  "C" is required for
creating a CA certificate.  "-x" means self signed.

It is not a requirement to create the CA in NSS database.  The CA
certificate can be obtained from third parties.

### To create a user certificate signed by the above CA

    ipsec certutil -S -k rsa -c "ExampleCA" -n "user1" -s "CN=User Common Name" \
            -v 12 -t "u,u,u"

This creates a user cert with nick name "user1" with attributes
"u,u,u" signed by the CA cert "ExampleCA" in Libreswan's NSS database.

Note: you must provide a nick name when creating a user certificate,
because pluto reads the user certificate from the NSS database based
on the user certificate's nickname.

## Configuring certificates in ipsec.conf

In `ipsec.conf`, the leftcert= option takes a certificate nickname as
argument.  For example if the nickname of the user cert is "hugh",
then it can be "leftcert=hugh".

If you are migrating from openswan without NSS, you were used to
specify the filename for the certificate in the leftcert= option.
Filenames are not valid in Libreswan when identifying a certificate or
private key.  Only the nickname can be used.

    leftcert=nickname

If you use an external CA certificate, you must import them it into
Libreswan's NSS database.

## Importing third-party files into NSS

### Importing user credentials (.crt, .key and .p12 files)

If you do not have the third-party certificate in the PKCS#12 format,
use openssl to create a PKCS#12 file:

    openssl pkcs12 -export -in cert.pem -inkey key.pem \
            -certfile cacert.pem -out YourName.p12   [-name YourName]

Now you can import the file into libreswan's NSS database, use:

    ipsec import YourName.p12

or:

    ipsec pk12util -i YourName.p12

If you did not pick a name using the -name option, you can use:

    ipsec certutil -L

to figure out the name NSS picked during the import.

To specify the certificate in ipsec.conf, use a line like:

    leftcert=YourName

### Importing CA Certificates

The CAname is a friendly_name to refer to the CA certificate when
manipulating the certificate within Libreswan's NSS database.  If your
NSS database is protected by a password, specify it as the last item
on the command line.  For DER formatted certificates use:

    ipsec certutil -A -i /path/YourCA.der -n "CAname" -t 'CT,,'

For PEM formatted CA certificates use:

    ipsec certutil -A -a -i /path/YourCA.pem -n "CAname" -t 'CT,,'

Note: the "CAname" is used to directly manipulate an individual
certificate within Libreswan's NSS database.  When authenticating
using a CA, `{left,right}ca=` require the Distinguished Name of the
authorized Certificate Authority (aka the certificate's Subject) as
that identifies all of the CA's certificates.

### Importing CRLs

For PEM files use:

    ipsec crlutil -I -i /path/yourcrl.der -a  -B

For dir files use:

    ipsec crlutil -I -i /path/yourcrl.der -B

Note: CRLs signed by a root CA are only processed if the root CA is
marked as Trusted in NSS - See previous section.

### Importing Raw Private Keys

NSS does not allow the direct import of a PEM containing a private
key.  However, it does allow the import of that same key when paired
with a self-signed certificate and bundled into a PKCS#12 file.

Starting with the raw key:

    $ head -1 OUTPUT/*.key    # see nothing hidden
    ==> OUTPUT/east.key <==
    -----BEGIN PRIVATE KEY-----

Generate a certificate request (this uses 365 days, could be
unlimited), self-sign it and then bundle it into a PKCS#12 file:

    $ openssl req -new -subj "/CN=east" \
          -key OUTPUT/east.key \
          -out OUTPUT/east.csr
    $ openssl req -text -in OUTPUT/east.csr -noout | grep east
          Subject: CN = east
    $ openssl x509 -req -days 365 \
          -in OUTPUT/east.csr \
          -signkey OUTPUT/east.key \
          -out OUTPUT/east.crt
    $ openssl pkcs12 -export -password pass:foobar \
          -in OUTPUT/east.crt \
          -inkey OUTPUT/east.key \
          -name east \
          -out OUTPUT/east.p12

And then import it:

    $ ipsec pk12util -i OUTPUT/east.p12 -W foobar
    $ certutil -K
    certutil: Checking token "NSS Certificate DB" in slot "NSS User Private Key and Certificate Services"
    < 0> rsa      42ce27ac8668ab0e1f20894f1f73f95de4aa6c72   east

Once the key has been imported.  It can be identified using something
like either of:

    rightid=@east
    rightckaid=42ce27ac8668ab0e1f20894f1f73f95de4aa6c72

See the test ikev2-03-rawrsa-pem.

## Exporting a CA(?) certificate to load on another libreswan machine

To export the CA certificate, including the private key:

    ipsec pk12util -o cacert1.p12 -n cacert1

Normally you would just want the CA cert.  To extract just the CA cert
without the private key:

    ipsec certutil -L -n "CA nickname" -a > theca.crt

You can also use -x instead of -a for binary DER encoding.

Copy the .p12 or .crt file to the new machine.

To import the .crt file:

    ipsec certutil -A -i theca.crt -n "CA nickname" -t "CT,,"

To import the .p12 file:

    ipsec import cacert1.p12
    ipsec certutil -M -n cacert1 -t "CT,,"

## Example configurations

### Mutual authentication using local certificates

Two peers, left (west) and right (east) authenticate each other using
explicit certificates (ref `ikev2-04-basic-x509`):

    conn left-right
        # topology
        left=192.1.2.45
        right=192.1.2.23
	leftsubnet=192.0.1.0/24
	rightsubnet=192.0.2.0/24
        # certs from local NSS db
	leftcert=west
	rightcert=east
        # IDs taken from local certs
        rightid=%fromcert
        leftid=%fromcert
        # key identified by cert when needed
        leftrsasigkey=%cert
        rightrsasigkey=%cert

### Gateway server

The client uses it's own certificate's signer as the Disnguished Name
for the server's certificate:

    conn nss-cert
        # Left security gateway, subnet behind it, next hop toward right.
        left=192.1.2.45
        right=192.1.2.23
        leftcert=west
	leftsubnet=192.0.1.254/32
        leftid=%fromcert
	leftsourceip=192.0.1.254
        # Right security gateway, subnet behind it, next hop toward left.
        rightid=%fromcert
	rightsubnet=192.0.2.254/32
	rightsourceip=192.0.2.254
	# test specific options
	leftsendcert=always
	rightsendcert=always

While the server uses `{left,right}ca=` to identify the Certificate
Authority:

    conn nss-cert
        # Left security gateway, subnet behind it, next hop toward right.
        left=192.1.2.45
        right=192.1.2.23
	leftsubnet=192.0.1.254/32
	rightsubnet=192.0.2.254/32
	rightsourceip=192.0.2.254
	leftsourceip=192.0.1.254
	# use wildcards
	leftid="C=CA, ST=Ontario, L=Toronto, O=Libreswan, OU=Test Department, CN=*, E=*"
	leftca="C=CA, ST=Ontario, L=Toronto, O=Libreswan, OU=Test Department, CN=Libreswan test CA for mainca, E=testing@libreswan.org"
        # local proof of identity
        rightid=%fromcert
        rightcert=east
	# test specific options
	leftsendcert=always
	rightsendcert=always

## Configuring a smartcard with NSS

Required library: libcoolkey or other PKCS#11 compatible library

To make smartcard tokens visible through NSS

    ipsec modutil -add <module_name> -libfile libcoolkeypk11.so \
            -mechanisms <mechanisms_separted_by_colons>

An example of mechanisms can be:
RC2:RC4:DES:DH:SHA1:MD5:MD2:SSL:TLS:AES:CAMELLIA.

To check whether the token is visible or not, run

    ipsec modutil -list

## Using NSS in FIPS mode

If the system is running in FIPS mode, the NSS library and libreswan
will automatically also run in FIPS mode.  To check if libreswan is
running in FIPS mode, run:

    ipsec fipsstatus

To see more detailed information about the FIPS status of the
operating system and libreswan, the selfcheck command can be run:

    # ipsec pluto --selftest
    Pluto initialized
    FIPS Product: NO
    FIPS Kernel: NO
    FIPS Mode: NO
    [...]
    FIPS HMAC integrity support [enabled]
    FIPS mode disabled for pluto daemon
    FIPS HMAC integrity verification self-test passed
    [...]
    Encryption algorithms:
      AES_CCM_16              IKEv1:     ESP     IKEv2:     ESP     FIPS  {256,192,*128}  aes_ccm, aes_ccm_c
      AES_CCM_12              IKEv1:     ESP     IKEv2:     ESP     FIPS  {256,192,*128}  aes_ccm_b
      AES_CCM_8               IKEv1:     ESP     IKEv2:     ESP     FIPS  {256,192,*128}  aes_ccm_a
      3DES_CBC                IKEv1: IKE ESP     IKEv2: IKE ESP     FIPS  [*192]  3des
      AES_GCM_16              IKEv1:     ESP     IKEv2: IKE ESP     FIPS  {256,192,*128}  aes_gcm, aes_gcm_c
      AES_GCM_12              IKEv1:     ESP     IKEv2: IKE ESP     FIPS  {256,192,*128}  aes_gcm_b
      AES_GCM_8               IKEv1:     ESP     IKEv2: IKE ESP     FIPS  {256,192,*128}  aes_gcm_a
      AES_CTR                 IKEv1: IKE ESP     IKEv2: IKE ESP     FIPS  {256,192,*128}  aesctr
      AES_CBC                 IKEv1: IKE ESP     IKEv2: IKE ESP     FIPS  {256,192,*128}  aes
      NULL_AUTH_AES_GMAC      IKEv1:     ESP     IKEv2:     ESP     FIPS  {256,192,*128}  aes_gmac
    Hash algorithms:
      SHA1                    IKEv1: IKE         IKEv2:             FIPS  sha
      SHA2_256                IKEv1: IKE         IKEv2:             FIPS  sha2, sha256
      SHA2_384                IKEv1: IKE         IKEv2:             FIPS  sha384
      SHA2_512                IKEv1: IKE         IKEv2:             FIPS  sha512
    PRF algorithms:
      HMAC_SHA1               IKEv1: IKE         IKEv2: IKE         FIPS  sha, sha1
      HMAC_SHA2_256           IKEv1: IKE         IKEv2: IKE         FIPS  sha2, sha256, sha2_256
      HMAC_SHA2_384           IKEv1: IKE         IKEv2: IKE         FIPS  sha384, sha2_384
      HMAC_SHA2_512           IKEv1: IKE         IKEv2: IKE         FIPS  sha512, sha2_512
    Integrity algorithms:
      HMAC_SHA1_96            IKEv1: IKE ESP AH  IKEv2: IKE ESP AH  FIPS  sha, sha1, sha1_96, hmac_sha1
      HMAC_SHA2_512_256       IKEv1: IKE ESP AH  IKEv2: IKE ESP AH  FIPS  sha512, sha2_512, sha2_512_256, hmac_sha2_512
      HMAC_SHA2_384_192       IKEv1: IKE ESP AH  IKEv2: IKE ESP AH  FIPS  sha384, sha2_384, sha2_384_192, hmac_sha2_384
      HMAC_SHA2_256_128       IKEv1: IKE ESP AH  IKEv2: IKE ESP AH  FIPS  sha2, sha256, sha2_256, sha2_256_128, hmac_sha2_256
      AES_CMAC_96             IKEv1:     ESP AH  IKEv2:     ESP AH  FIPS  aes_cmac
      NONE                    IKEv1:     ESP     IKEv2: IKE ESP     FIPS  null
    DH algorithms:
      NONE                    IKEv1:             IKEv2: IKE ESP AH  FIPS  null, dh0
      MODP2048                IKEv1: IKE ESP AH  IKEv2: IKE ESP AH  FIPS  dh14
      MODP3072                IKEv1: IKE ESP AH  IKEv2: IKE ESP AH  FIPS  dh15
      MODP4096                IKEv1: IKE ESP AH  IKEv2: IKE ESP AH  FIPS  dh16
      MODP6144                IKEv1: IKE ESP AH  IKEv2: IKE ESP AH  FIPS  dh17
      MODP8192                IKEv1: IKE ESP AH  IKEv2: IKE ESP AH  FIPS  dh18
      DH19                    IKEv1: IKE         IKEv2: IKE ESP AH  FIPS  ecp_256, ecp256
      DH20                    IKEv1: IKE         IKEv2: IKE ESP AH  FIPS  ecp_384, ecp384
      DH21                    IKEv1: IKE         IKEv2: IKE ESP AH  FIPS  ecp_521, ecp521
    testing AES_GCM_16:
      empty string
      one block
      two blocks
      two blocks with associated data
    testing AES_CTR:
      Encrypting 16 octets using AES-CTR with 128-bit key
      Encrypting 32 octets using AES-CTR with 128-bit key
      Encrypting 36 octets using AES-CTR with 128-bit key
      Encrypting 16 octets using AES-CTR with 192-bit key
      Encrypting 32 octets using AES-CTR with 192-bit key
      Encrypting 36 octets using AES-CTR with 192-bit key
      Encrypting 16 octets using AES-CTR with 256-bit key
      Encrypting 32 octets using AES-CTR with 256-bit key
      Encrypting 36 octets using AES-CTR with 256-bit key
    testing AES_CBC:
      Encrypting 16 bytes (1 block) using AES-CBC with 128-bit key
      Encrypting 32 bytes (2 blocks) using AES-CBC with 128-bit key
      Encrypting 48 bytes (3 blocks) using AES-CBC with 128-bit key
      Encrypting 64 bytes (4 blocks) using AES-CBC with 128-bit key

Note various non-FIPS allowed algorithms are missing from the
selftest, such as MD5, CHACHA20POLY1305, MODP1536, etc etc.

For example using RHEL8/CentOS8, placing the system in FIPS mode using
the following commands is enough for libreswan to run in FIPS mode:

    fips-mode-setup --enable
    reboot

If the Linux distribution offers no easy way to place the system in
FIPS mode, this can be done manually.  For the Operating System to be
considered in FIPS mode, the Linux kernel (compiled with FIPS support)
must have been booted with the kernel command option fips=1 and the
file /etc/system-fips needs to exist (but can be 0 bytes in size).
The system-fips file is often created by dracut-fips.  Additionally,
the NSS database has to be (re)configured to be in FIPS mode.  This
can be done using:

    ipsec modutil -fips true -force

To check if the NSS database is in FIPS mode, use:

    ipsec modutil -chkfips true
