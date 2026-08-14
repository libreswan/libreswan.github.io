All hardware tokens supported by NSS should be supported by libreswan.
It is recommended to use libreswan 3.21 or newer to get full token
support.

# Yubi Key

The [yuibkey 4-series](https://www.yubico.com/product/yubikey-4-series/)
and the [yubikey Neo](https://www.yubico.com/product/yubikey-neo/)
support asymmetric encryption such as RSA operations that are required
for libreswan.

If you use **lsusb**, the following message is seen for a supported key:

    Yubico.com Yubikey 4 OTP+U2F+CCID

The older U2F-only yubikey's such as the github ones do not support RSA
operations. They appear as follows:

    USB HID v1.10 Device [Yubico Security Key by Yubico] on usb-0000:00:1a.0-1.1/input0

## Installation

    sudo yum install yubico-piv-tool libykneomgr coolkey pcsc-lite
    sudo systemctl enable pcscd
    sudo systemctl start pcscd

To test the key, insert it and run:

    ykneomgr --set-mode=06

If you see an error "error: ykneomgr_discover_match (-4): Backend error"
then your yubikey only supports U2F (such as the github yubikey)

For more information about the yubikey command line tools, see
<https://developers.yubico.com/yubico-piv-tool/>

## configuration

The easiest way to switch or use a yubikey is to generate a PKCS#12
(.p12) file, and import that onto the yubikey. Of course you can also
generate a cert request from the key and then get your VPN Certificate
Agency to sign that. But most people will just have their CA give them a
.p12 file.

First, tell the libreswan NSS database that you want to use a hardware
token:

    modutil -dbdir sql:/etc/ipsec.d -add coolkey -libfile /usr/lib64/pkcs11/libcoolkeypk11.so

If you want to not have to use the pincode, you can store the pincode in
/etc/ipsec.d/nsspasswd:

    nicknameofcert:pincode

To import a PKCS#12 file:

    yubico-piv-tool -s9c filename.p12 -KPKCS12 -aset-chuid -aimport-key   -aimport-cert

You can get a status of the yubikey to see the certificate, which will
roughly look like:

    yubico-piv-tool -a status
    CHUID:  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    CCC:    YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY
    Slot 9a:
        Algorithm:  RSA2048
        Subject DN: C=CA, ST=Ontario, L=Ottawa, O=No Hats Corporation, OU=Clients, CN=pwouters/emailAddress=pwouters@users.nohats.ca
        Issuer DN:  C=CA, ST=Ontario, L=Ottawa, O=No Hats Corporation, OU=Clients, CN=Certificate Agency (CA)/emailAddress=info@nohats.ca
        Fingerprint:    f094793012a211d6b65621664c1961ba1942e14a5651ca90eb10f5a06479d962
        Not Before: Jun  5 21:24:30 2017 GMT
        Not After:  Jun  4 21:24:30 2027 GMT
    Slot 9c:
        Algorithm:  RSA2048
        Subject DN: C=CA, ST=Ontario, L=Ottawa, O=No Hats Corporation, OU=Clients, CN=pwouters/emailAddress=pwouters@users.nohats.ca
        Issuer DN:  C=CA, ST=Ontario, L=Ottawa, O=No Hats Corporation, OU=Clients, CN=Certificate Agency (CA)/emailAddress=info@nohats.ca
        Fingerprint:    f094793012a211d6b65621664c1961ba1942e14a5651ca90eb10f5a06479d962
        Not Before: Jun  5 21:24:30 2017 GMT
        Not After:  Jun  4 21:24:30 2027 GMT
    Slot 9e:
        Algorithm:  RSA2048
        Subject DN: C=CA, ST=Ontario, L=Ottawa, O=No Hats Corporation, OU=Clients, CN=pwouters/emailAddress=pwouters@users.nohats.ca
        Issuer DN:  C=CA, ST=Ontario, L=Ottawa, O=No Hats Corporation, OU=Clients, CN=Certificate Agency (CA)/emailAddress=info@nohats.ca
        Fingerprint:    f094793012a211d6b65621664c1961ba1942e14a5651ca90eb10f5a06479d962
        Not Before: Jun  5 21:24:30 2017 GMT
        Not After:  Jun  4 21:24:30 2027 GMT

The yubikey does not store the public CA certificate within the token,
so this file needs to be installed separately in NSS. You can extract
the CA certificate from the PKCS#12 file and import it into the NSS
software token:

    openssl pkcs12 -in certificate.p12 -cacerts -nokeys -out ca.crt
    certutil -A CA.crt -d sql:/etc/ipsec.d -n "YourCAnickname" -t CT,,
    ipsec restart

In libreswan, you configure a certificate as normal, except you use a
specific leftcert= syntax to specify your token slot:

    conn yourvpn
         leftcert="pwouters:CAC ID Certificate"
         [....]

`Once the connection is loaded (auto=add in the config file, or by running ipsec auto --add yourvpn) you should be able to see the certificate and the private key:`

    # ipsec auto --listpubkeys
    000
    000 List of RSA Public Keys:
    000
    000 Jun 09 02:27:18 2017, 2048 RSA Key AwEAAdJUb (has private key), until Jun 04 21:24:30 2027 ok
    000        ID_DER_ASN1_DN 'C=CA, ST=Ontario, L=Ottawa, O=No Hats Corporation, OU=Clients, CN=pwouters, E=pwouters@users.nohats.ca'
    000        Issuer 'C=CA, ST=Ontario, L=Ottawa, O=No Hats Corporation, OU=Clients, CN=Certificate Agency (CA), E=info@nohats.ca'
    000 Jun 09 02:27:18 2017, 2048 RSA Key AwEAAdJUb (has private key), until Jun 04 21:24:30 2027 ok
    000        ID_USER_FQDN 'pwouters@users.nohats.ca'
    000        Issuer 'C=CA, ST=Ontario, L=Ottawa, O=No Hats Corporation, OU=Clients, CN=Certificate Agency (CA), E=info@nohats.ca'

You should see "(has private key"). If you do not see this, you might
need to unlock/unblock/activate your token:

And to check if the CA certificate imported correctly:

    # ipsec auto --listcacerts
    000
    000 List of X.509 CA Certificates:
    000
    000 Root CA certificate "C=CA, ST=Ontario, L=Ottawa, O=No Hats Corporation, OU=Clients, CN=Certificate Agency (CA)/emailAddress=info@nohats.ca" - SN: 0x00
    000   subject: C=CA, ST=Ontario, L=Ottawa, O=No Hats Corporation, OU=Clients, CN=Certificate Agency (CA), E=info@nohats.ca
    000   issuer: C=CA, ST=Ontario, L=Ottawa, O=No Hats Corporation, OU=Clients, CN=Certificate Agency (CA), E=info@nohats.ca
    000   not before: Thu Jan 26 05:47:53 2017
    000   not after: Mon Jan 25 05:47:53 2027
    000   2048 bit RSA