Paul to document, explain and implement the crypto boundary

Is there a readonly and writeonly path for crypto ?

NSS debugging / logging should be fixed before this, so we don't need to
change any crypto files.

This also depends on putting CRLs/certs into nss, and not using the
"openssl" methods of loading from /etc/ipsec.d/

so ifdef NSS/OPENSSL needs to happen before this.

nss errors returns numbers, and you need to do a call to nss to get the
string message length, then allcoate that space and send it to another
nss function.

we need an nss module, that is thread safe, to deal with the logging.