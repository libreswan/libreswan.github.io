Web servers are often used to provide PKCS#12 formatted certificates for
laptops and phones. Especially on phones, this saves a lot of awkward
typing by the user. To ensure that Android phones don't download the
.p12 files as text files which it cannot import, it is important to
serve the .p12 files with the correct MIME type. For Apache, add the
following line to the configuration:

    AddType application/x-pkcs12 .p12 .pfx

Note that iOS (Iphones etc) ignore the CA certificate within the PKCS#12
file, so you must provide the cacert.pem file separately.