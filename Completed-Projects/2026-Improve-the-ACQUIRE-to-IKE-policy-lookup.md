# Improve the ACQUIRE to IKE policy lookup by making use of the policy.index

GSoC 2026 - Libreswan - Vinayak Sandur  
Mentor: Andrew Cagney  
[Project Details](<https://github.com/libreswan/libreswan/wiki/GSoC-2026:-Code-Project-Ideas#improve-the-acquire-to-ike-policy-lookup-by-making-use-of-the-policyindex>)

## Goals

A connection with `auto=ondemand` installs an outbound IPsec kernel policy.When a packet matches that policy, the kernel sends an ACQUIRE to pluto asking it to negotiate. 
The ACQUIRE carries the protocol and the source and destination addresses as well as
a policy.index field, which was always 0. So pluto worked by walking through every loaded connection, matching selectors against the packet, keeping the highest-priority survivor. 
This project closes the loop,gives each policy an unique identifier to the connection that owns it, install it in the kernel, and uses a hashtable to find the connection directly when the ACQUIRE returns.The identifier is the connection's reqid, carried in the policy's `XFRMA_TMPL` attribute. 


## What I did(merged upstream) 

The work can be majorly split into four merged changes. They landed in that order, since each one depended on the last.

#### Planting the reqid ([#2811](https://github.com/libreswan/libreswan/pull/2811))
When an ondemand kernel policy is now installed in the kernel, pluto now writes the connection's reqid in the xfrm template instead of leaving it as 0. When an outbound packet matches this policy,the ACQUIRE message brings back this value making it easier for looking up the connection which installed the policy.If the ACQUIRE carries no reqid, the old selector search still runs.Existing tests which showed reqid as 0 were also updated.

#### The lookup ([#2836](https://github.com/libreswan/libreswan/pull/2836))  
Adds a connection hashtable keyed on reqid registered alongside the existing tables,automatically maintains as connections are added or removed.    
As the reqid is echoed back through the ACQUIRE message,the connection is found by single hash lookup instead of the walking every connection. 
Opportunistic connections needed one extra fix.Every clone of the template would have a new reqid generated and re-hashed so that each instance can be uniquely identified.


#### Display the reqid ([#2871](https://github.com/libreswan/libreswan/pull/2871))  
`ipsec status` now directly prints the connection's reqid; Makes things easier.

#### Updating whack command ([#2878](https://github.com/libreswan/libreswan/pull/2878)) 
Updated the  command `ipsec whack --oppohere/--oppothere` by adding a `--opporeqid` flag so that the connection is searched up via the hashtable route.

#### Testing

The change affects almost every Linux test, so most of the test work was updating
existing output and adding sanitizer rules for generated reqids.  
One bug also got fixed on the way.The connection which does not install the kernel policy would be selected if added after the actual connection which loads it.([#574](https://github.com/libreswan/libreswan/issues/574)).  
Assist goes to  Amrinder(@aamrindersingh) for flagging this issue as one this project would fix.  
A test case demonstrating that this was fixed was also added.([#2910](https://github.com/libreswan/libreswan/pull/2910)). 

No specific tests were written apart from the above as these changes affected the entire test suite. 


## Future Work 

- Pluto's hashtable currently seems complex to build upon.Improving the hashtable might be a project on its own. 
- The reqid changes are for Linux/XFRM only.Extending them to BSDs might be the next step. 
- Beyond GSoC, I'm currently working on addition of `ike-sa-init-full-transcript-auth` keyword as part of IKEv2 downgrade-prevention draft.

## Acknowledgements 

Overall it's been a great experience, and easily the most I've learned from a single project.  
Thanks to my mentor, Andrew, for the reviews, the patience with my early patches, and for pointing me at the right parts of the code.  
Thanks also to the wider Libreswan community on the IRC. 
