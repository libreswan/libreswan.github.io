The pluto daemon handles the IKE protocol layer and instructs the kernel
about IPsec SA's.

- pluto implements the IKEv1 and IKEv2 protocols
- pluto communicates via the `whack interface`
- pluto performs IKE packet processing

The pluto main binary can call upon the helper pool to perform
crytographic intensive work such as:

- dh
- kem
- signing

## pluto files

The filenames should be fairly self-explanatory. The important files
are:

- include/ietf_constants.h contains the names and values of the IKE and
  IPsec protocol IANA registries.
- programs/pluto/ikev1\* contains IKEv1 specific processing functions
- programs/pluto/ikev2\* contains IKEv2 specific processing functions
- include/pluto_constants.h contains the names and values of our own
  options
- programs/pluto/packet.c contains the structs representing the
  IKE/IPsec registries
- lib/libswan/constants.c contains the enum_names of IETF and pluto
  constants
- programs/pluto/connections.h contains struct connection
- programs/pluto/state.h contains struct state

## pluto concepts

Pluto is event driven. The design tries to avoid threads. Some of the
scheduling currently done using select() will be replaced with a
libevent structure.

Pluto has a concept of connections and states. A connection is what you
define in a configuration file. There are a few types of connections,
differentiated by c-\>kind:

- CK_PERMANENT: static single connection which can be up or down
- CK_TEMPLATE: a connection that can have multiple instantiations. The
  template itself is never "up"
- CK_INSTANCE: An instance of a template

The reason for instantiating a template is that some parts of the
connection are variable and the template connection should not be
modified. For example:

- right=%any Roadwarriors who have different right= IP addresses
- rightprotoport=17/%any These connections can ask for any 1 port
  (usually depends on the NAT)
- rightsubnet=vnet:%priv These connections allow various subnets from
  the RFC1918 (or virtual_network=) space to be used.
- narrowing=yes (IKEv2) These connections can be dynamically narrowed on
  demand.

States represent the state of an connection or instance of of a
connection. There can be multiple states per connection in various
different states.  States are described and defined in the state
machines (in ikev1.c and ikev2.c) which list a state processing
function that will be called. These functions return an `stf_status`
code.

Pluto uses marshalling to convert the packet data to internal structs
and back. The functions used for this are in_struct() and out_struct()
which use the definitions from packet.h and packet.c

## core structs

- struct state - describes the state properties
- struct connection - describes the connection properties
- struct end - describes "this" and "that" end, which are filled in from
  "left" and "right" after orienting the connection
- struct hostpair - describes the pair of IP addresses of gateways to
  look through in connection/state matching.

### pluto contains an ipsec.conf and an ipsec.secrets parser

- lib/libipsecconf/
- lib/libswan/secrets.c

### pluto consists several parts

- pluto main program
- libswan more generic low-level functions
