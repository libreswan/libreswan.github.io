There are different methods for providing a VPN server for roaming
(dynamic) clients. Which method to use depends on the clients that need
to be supported.

This method using IKEv2 without EAP, also called "Machine Certificate"
based authentication.

Supported clients:

- libreswan
- Windows 7 and up
- Windows Phone (requires latest firmware)
- OSX and iOS
- Android with strongswan client

### X.509 Certificate requirements

When serving Windows clients, special care needs to be taken when
generating X.509 certificates for this method.

- The VPN gateway's certificate must have its DNS name as SubjectAltname
  (SAN) in the certificate. The client then must connect to the VPN
  using the DNS name. Alternately, the client can connect using the IP
  if the SAN contains the IP address of the gateway.
- The VPN gateway's certificate must have the Digital Signature and Key
  Encipherment KU extensions if the SAN and CN use the same, full DNS
  name.
- The certificates also need to have the serverAuth and clientAuth
  ExtendedKeyUSage ("EKU") attribytes set. Alternatively, EKU checking
  can be disabled, see
  [Interoperability#Windows_Certificate_requirements](./Interoperability#Windows_Certificate_requirements)

{{ ambox \| nocat=true \| type=speedy \| text = Windows uses only
insecure defaults for IKEv2. To interop with libreswan, you need to
either specify a modp1024 based proposal or change the registry and add
a DWORD
HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\Rasman\Parameters\NegotiateDH2048_AES256
}}

### ipsec.conf for IKEv2 Machine Certificate VPN server

    conn ikev2-cp
        # The server's actual IP goes here - not elastic IPs
        left=1.2.3.4
        leftcert=vpn.example.com
        leftid=@vpn.example.com
        leftsendcert=always
        leftsubnet=0.0.0.0/0
        leftrsasigkey=%cert
        # Clients
        right=%any
        # your addresspool to use - you might need NAT rules if providing full internet to clients
        rightaddresspool=192.168.66.1-192.168.66.254
        # optional rightid with restrictions
        # rightid="C=CA, L=Toronto, O=Libreswan Project, OU=*, CN=*, E=*"
        rightca=%same
        rightrsasigkey=%cert
        #
        # connection configuration
        # DNS servers for clients to use
        modecfgdns=8.8.8.8,193.100.157.123
        # Versions up to 3.22 used modecfgdns1 and modecfgdns2
        #modecfgdns1=8.8.8.8
        #modecfgdns2=193.110.157.123
        narrowing=yes
        # recommended dpd/liveness to cleanup vanished clients
        dpddelay=30
        dpdtimeout=120
        dpdaction=clear
        auto=add
        ikev2=insist
        rekey=no
        # ikev2 fragmentation support requires libreswan 3.14 or newer
        fragmentation=yes
        # optional PAM username verification (eg to implement bandwidth quota
        # pam-authorize=yes

## Libreswan client

You can use the NetworkManager-libreswan package to configure a VPN
client connection using NetworkManager. You still need to import the
PKCS#12 certificate bundle using:

    ipsec import file.p12

If you do not want to use NetworkManager, but a static connection file
that you can manually bring up using ipsec auto --up connname, you can
create a file similar to this one:

Then add a client.conf in /etc/ipsec.d/ containing:

    # IKEv2 roadwarrior client config using X.509 certificates
    conn vpn.example.com
        left=%defaultroute
        leftcert=YourCertFiendlyName
        leftid=%fromcert
        leftrsasigkey=%cert
        leftsubnet=0.0.0.0/0
        leftmodecfgclient=yes
        right=vpn.example.com
        rightsubnet=0.0.0.0/0
        rightid=@vpn.example.com
        rightrsasigkey=%cert
        narrowing=yes
        ikev2=insist
        rekey=yes
        fragmentation=yes
        mobike=yes
        auto=add

You will also need to import the PKCS#12 certificate file as shown
above.

## Windows 7 client configuration with "RasClient" native IKEv2

- Control Panel -\> Network and Internet -\> Network and Sharing Center
  -\> Set Up a Connection or Network
- Choose the "Connect to a Workplace" VPN option -\> Use my Internet
  connection (VPN)
- Enter the gateway address or DNS name. What you enter here should
  correlate to a subjectAltName that is on leftcert.
- Name the connection.
- Select "Don't connect now; just set it up so I can connect later"
- Click "Create" and close the dialog.
- Click the network icon on the panel and right click on the VPN
  connection you created and select "Properties"
- On the Options tab, de-select the "Prompt for name and password,
  certificate, etc." and "Include windows logon domain" boxes.
- On the Security tab, set "Type of VPN" to IKEv2.
- In the "Authentication" box of the Security tab, select the "Use
  machine certificates" radial button.

That's all, now click "Connect" under the created connection.

## Common Windows 7 client errors

13806: IKE failed to find valid machine certificate. Contact your
Network Security Administrator about installing a valid certificate in
the appropriate Certificate Store.

Verify that you have imported the client certificate with private key
into the Computer certificate store and not the Local user store.
Starting mmc.exe as an administrator will allow you to do this. Newer
versions of Windows require that the certificate has both serverAuth and
clientAuth EKU's set.

example tutorial:
<https://wiki.strongswan.org/projects/strongswan/wiki/Win7Certs>

13801: IKE authentication credentials are unacceptable.

Verify that the gateway certificate has a SAN that matches the address
entered into the Windows client configuration. The certificate should
also contain the serverAuth EKU.

## Example certificate generation with certutil

- As root, create a database to generate certificates for this example.
  This database will hold the private key of the CA and allow you to
  generate new host certificates.

<!-- -->

    # mkdir ${HOME}/tmpdb
    # certutil -N -d sql:${HOME}/tmpdb
    Enter a password which will be used to encrypt your keys.
    The password should be at least 8 characters long,
    and should contain at least one non-alphabetic character.

    Enter new password:
    Re-enter password:

- Generate the CA certificate with a CA basic constraints extension

<!-- -->

    # certutil -S -x -n "Example CA" -s "O=Example,CN=Example CA" \
     -k rsa -g 4096 -v 12 -d sql:${HOME}/tmpdb -t "CT,," -2

    A random seed must be generated that will be used in the
    creation of your key.  One of the easiest ways to create a
    random seed is to use the timing of keystrokes on a keyboard.

    To begin, type keys on the keyboard until this progress meter
    is full.  DO NOT USE THE AUTOREPEAT FUNCTION ON YOUR KEYBOARD!

    Continue typing until the progress meter is full:

    |************************************************************|

    Finished.  Press enter to continue:

    Generating key.  This may take a few moments...

    Is this a CA certificate [y/N]?
    y
    Enter the path length constraint, enter to skip [<0 for unlimited path]: >
    Is this a critical extension [y/N]?
    N

- Generate the server certificate and assign extensions:

<!-- -->

    # certutil -S -c "Example CA" -n "vpn.example.com" -s "O=Example,CN=vpn.example.com" \
       -k rsa -g 4096 -v 12 -d sql:${HOME}/tmpdb -t ",," -1 -6 -8 "vpn.example.com"

    A random seed must be generated that will be used in the
    creation of your key.  One of the easiest ways to create a
    random seed is to use the timing of keystrokes on a keyboard.

    To begin, type keys on the keyboard until this progress meter
    is full.  DO NOT USE THE AUTOREPEAT FUNCTION ON YOUR KEYBOARD!

    Continue typing until the progress meter is full:

    |************************************************************|

    Finished.  Press enter to continue:

    Generating key.  This may take a few moments...

                    0 - Digital Signature
                    1 - Non-repudiation
                    2 - Key encipherment
                    3 - Data encipherment
                    4 - Key agreement
                    5 - Cert signing key
                    6 - CRL signing key
                    Other to finish
     > 0
                    0 - Digital Signature
                    1 - Non-repudiation
                    2 - Key encipherment
                    3 - Data encipherment
                    4 - Key agreement
                    5 - Cert signing key
                    6 - CRL signing key
                    Other to finish
     > 2
                    0 - Digital Signature
                    1 - Non-repudiation
                    2 - Key encipherment
                    3 - Data encipherment
                    4 - Key agreement
                    5 - Cert signing key
                    6 - CRL signing key
                    Other to finish
     > 8
    Is this a critical extension [y/N]?
    N
                    0 - Server Auth
                    1 - Client Auth
                    2 - Code Signing
                    3 - Email Protection
                    4 - Timestamp
                    5 - OCSP Responder
                    6 - Step-up
                    7 - Microsoft Trust List Signing
                    Other to finish
     > 0
                    0 - Server Auth
                    1 - Client Auth
                    2 - Code Signing
                    3 - Email Protection
                    4 - Timestamp
                    5 - OCSP Responder
                    6 - Step-up
                    7 - Microsoft Trust List Signing
                    Other to finish
     > 1
                    0 - Server Auth
                    1 - Client Auth
                    2 - Code Signing
                    3 - Email Protection
                    4 - Timestamp
                    5 - OCSP Responder
                    6 - Step-up
                    7 - Microsoft Trust List Signing
                    Other to finish
     > 8
    Is this a critical extension [y/N]?
    N

- Generate the client certificate, similar to the above

<!-- -->

    # certutil -S -c "Example CA" -n "win7client.example.com" -s "O=Example,CN=win7client.example.com" \
       -k rsa -g 4096 -v 12 -d sql:${HOME}/tmpdb -t ",," -1 -6 -8 "win7client.example.com"
    -- repeat same extensions above --

- The database should now contain

<!-- -->

    # certutil -L -d sql:${HOME}/tmpdb/

    Certificate Nickname                                         Trust Attributes
                                                                 SSL,S/MIME,JAR/XPI

    Example CA                                                   CTu,u,u
    vpn.example.com                                              u,u,u
    win7client.example.com                                       u,u,u

- Export the p12 files that contain the host certificate, private key,
  and CA certificate.

<!-- -->

    # pk12util -o win7client.example.com.p12 -n "win7client.example.com" -d sql:${HOME}/tmpdb/
    Enter password for PKCS12 file:
    Re-enter password:
    pk12util: PKCS12 EXPORT SUCCESSFUL

- The win7client.example.com.p12 should then be transferred to the
  client and imported to the Computer certificate store. The CA cert
  once imported must be placed into the "Trusted Root Certification
  Authorities" folder of the store.
- Export the gateway certificate and import it into the pluto DB

<!-- -->

    # pk12util -o vpn.example.com.p12 -n "vpn.example.com" -d sql:${HOME}/tmpdb/
    Enter password for PKCS12 file:
    Re-enter password:
    pk12util: PKCS12 EXPORT SUCCESSFUL

    # ipsec import vpn.example.com.p12
    Enter password for PKCS12 file:
    pk12util: PKCS12 IMPORT SUCCESSFUL