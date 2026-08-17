pluto and dns(sec):

sometimes you need to have it resolved for the policy

sometimes you need to lookup the dns (for right=)

Do case analyses:

auto=ondemand needs IP addresses auto=add needs IP address

for instance to %trap a remote IP or subnet. Then if we did a dns lookup
for a remote host, then we should take the TTL into account.

right=FQDN would need dns lookups

pluto used to be designed to always use IPs, not DNS.

We need to write out a few more details about DNS interaction.

DNSSEC support should remain a configre option so embedded can disable
it. For builds with dnssec support, it would be nice to have an option
to enable/disable dnssec.