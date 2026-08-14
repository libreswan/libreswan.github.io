This is mostly a collection of ideas and possibilities, as of 2019. AWS
support is already developed to a quickstart guide and others need more
work. I hope to find resources to work on these and eventually develop
further. The goal is code, quickstart/howto.

# Commerical Cloud's support for Opportunistic Encryption

## AWS

[OE
quickstart](https://aws.amazon.com/quickstart/architecture/libreswan-ipsec-mesh%7CAWS)
AWS started libreswan Certifcate OE work in in 2018, in May 2019 a quick
start guide was published. This guide will support internal AWS EC2
cloud-to-cloud support using certificates. The CA is created per AWS
user using lambda functions.

### AWS further ideas/roadmap

#### add internal IP address to Subject Alt Names(SAN)

#### support OE for external, Elastic IP(EIP), for both symmetrical and asymmetrical case

- create certificate for external name signed by either by
  \[<https://docs.aws.amazon.com/acm/latest/userguide/acm-overview.html>\|
  AWS Certificate Manger\] or Letsencryt.
- Use
  [1](https://aws.amazon.com/blogs/compute/building-a-dynamic-dns-for-route-53-using-cloudwatch-events-and-lambda%7CRoute53)
  to create Letsencrypt certifcate

#### libreswan support to read SAN

Currently libreswan only read Common Name(CN) from a certificate. Add
support read Subject Alt Names (SAN). This has two advantages one is add
IP addresses(internal, and external). It becomes an additional level of
verification. We can support multiple IDR (Responder ID).

## Google Compute Cloud

Google is arguably closer to support DNS OE and libreswan. Google
support reverse zones, aka, ptr records and IPSECKEYS. However, as of
2019 May, there is no DNSSEC support for reverse zone. If DNSSEC was
support that would be perfect IPsec OE authentication and authorization
support. I hope Google will add singed reverse zones soon.

\[<https://cloud.google.com/dns/docs/dnssec-advanced>\| IPSECKEY record
support\]

#### initial work add support to google cloud

Either create a letsencrypt certificate or IPSECKEY?

## Microsoft Azure