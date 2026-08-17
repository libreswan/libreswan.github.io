IKEv1's DPD (Dead Peer Detection) and IKEv2's LIVENESS mechanism are
very different beasts.  But so is how Libreswan v3/v4, and v5
implemented these features.

Consequently when migrating from a v3 or v4 Libreswan configuration
using IKEv1 and DPD, to a v5 Libreswan configuration using IKEv2 and
LIVENESS, both differences are at play.

## Why was DPD seemingly renamed to LIVENESS?

Because the very different mechanism is confirming that the other end
is still alive.  The IKEv2 RFC puts it this way:

_If there has only been outgoing traffic on all of the SAs associated
 with an IKE SA, it is essential to confirm LIVENESS of the other
 endpoint to avoid black holes.  If no cryptographically protected
 messages have been received on an IKE SA or any of its Child SAs
 recently, the system needs to perform a LIVENESS check in order to
 prevent sending messages to a dead peer.  (This is sometimes called
 "dead peer detection" or "DPD", although it is really detecting live
 peers, not dead ones.)  Receipt of a fresh cryptographically
 protected message on an IKE SA or any of its Child SAs ensures
 LIVENESS of the IKE SA and all of its Child SAs._

## IKEv1 vs IKEv2

(in the below "parent" and "child" are used, while they are not part
of the RFCs, they hopefully help clarify relationships)

In IKEv1, a "child" IPsec SA can out-live the "parent" ISAKMP SA used
to create it (i.e., the "child" IPsec SA can be orphaned).  In IKEv2,
a "child" Child SA can **never** out-live the "parent" IKE SA used to
create it.  Consequently, deleting an IKEv2 "parent" IKE SA implicitly
deletes all children.

In IKEv1, a "child" IPsec SA needing to exchange control messages with
its peer when there's no "parent" ISAKMP SA, must first create the
"parent" ISAKMP SA.  In IKEv2 that can never happen, "child" Child SA
needing to exchange control messages with its peer always has its
"parent" IKE SA available.

In IKEv1, each control exchange between two "parent" ISAKMP SAs is
performed independently, this means that the timeout of one exchange
does not necessarily mean that the "parent" ISAKMP SA has failed.  In
IKEv2, the control exchanges between two "parent" IKE SAs are
serialized, this means that a timeout of the current exchange means
that the "parent" IKE SA has failed, and should be deleted (which, per
above, includes all "children").

The consequence is that:

- in IKEv1 an explicit DPD exchange between "parent" ISAKMP SAs is
  used to confirm the LIVENESS of a "child" IPsec SA

- in IKEv2, only when the "child" Child SA's "parent" IKE SA have
  initiated no recent exchange does a LIVENESS (empty NOTIFY) need to
  be initiated

  If the IKEv2 "child" Child SA's "parent" IKE SA already has an
  exchange outstanding then that exchange serves as the LIVENESS probe
  (should it timeout, the "parent" IKE SA and all "child" Child SAs
  are declared dead)

As a result:

- IKEv1 detects and reports a DPD failures

- IKEv2 detects and reports a re-transmit timeout (only sometimes
  attributes it to a LIVENESS exchange)

## IKEv2 uses `retransmit-timeout=` not `dpdtimeout=`

With IKEv2, should **any** exchange (including LIVENESS) take longer
than `retransmit-timeout` to complete, then the connection is declared
dead.

What happens next is described below.

When migrating, set the IKEv2 connection's `retransmit-timeout=` to
the smaller of the IKEv1 connection's `dpdtimeout=` or
`retransmit-timeout=`.

_Historic note: it would appear that old code required both
`dpddelay=` and `dpdtimeout=` to be non-zero before IKEv2 LIVENESS was
enabled (even though the value `dpdtimeout=` was meaningless and being
ignored)._

## `dpdaction=` was obsoleted

Instead what happens when a connection fails is determined by the UP
and ROUTE (ONDEMAND) policy bits.

`dpdaction=restart` is replaced by policy UP. `dpdaction=hold` is
replaced by ROUTE (ONDEMAND).  `dpdaction=clear` is replaced by
`failure-shunt=none`?

These changes apply to both IKEv1 and IKEv2.

_Historic note: `dpdaction=` never fully described what was needed to
manage a connection.  For instance, `dpdaction=clear` didn't specify
what action to take once the (cough) `clear` was cleared._

### a connection with policy UP, tries to say UP

In v5, when an established connection with policy `UP` (`auto=up`,
`ipsec up conn`) fails, it will commence revival:

- the kernel policy/state are replaced with on-demand kernel policy
  (shunts, traps)

- and a retry timer is started

Either outbound traffic, or the retry timer will cause the connection
to start negotiation:

- during negotiation, the on-demand kernel policy is replaced by a
  negotiating kernel policy (typically a block)

Once the connection establishes:

- the negotiating policy is replaced by the established SAs

- the revival timer is cancelled

Should the negotiation fail, then the above restarts (but with a
larger revival timer).

This behaviour replaces `dpdaction=restart`.

### a connection with policy ROUTE (ONDEMAND), goes back to ROUTE (ONDEMAND)

In v5, when established connection with policy ROUTE (ONDEMAND)
(`auto=route`, `ipsec route conn`) fails, it goes back to goes back to
ROUTE (ONDEMAND):

- the kernel policy/state are replaced with on-demand kernel policy
  (shunts, traps)

Outbound traffic will then cause the connection to start negotiation:

- during negotiation, the on-demand kernel policy is replaced by a
  negotiating kernel policy (typically a block)

Once the connection establishes:

- the negotiating policy is replaced by the established SAs

Should the negotiation fail, then the connection goes back to
on-demand.

## IKEv2 honours `dpddelay=`

The `dpddelay` determines how long before Pluto suspects a connection
has failed, and initiates either a DPD or LIVENESS check.

Remember, with IKEv2, any recent successful exchange serves to confirm
LIVENESS.  And there's no point queuing a LIVENESS exchange when
there's already an exchange outstanding.
