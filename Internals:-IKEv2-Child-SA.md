Use name of exchange (INIT, AUTH, CREATE_CHILD, INFORMATIONAL) in name
of state. Auth ones may extend with EAP?

From the comments in pluto_constants.h (only describes V1):

<code>

`* The name of the state describes the last message sent, not the`
`* message currently being input or output (except during retry).`
`* In effect, the state represents the last completed action.`
`* All routines are about transitioning to the next state`
`* (which might actually be the same state).`
`*`
`* IKE V1 messages are sometimes called [MAQ][IR]n where`
`* - M stands for Main Mode (Phase 1);`
`*   A stands for Aggressive Mode (Phase 1);`
`*   Q stands for Quick Mode (Phase 2)`
`* - I stands for Initiator;`
`*   R stands for Responder`
`* - n, a digit, stands for the number of the message from this role`
`*   within this exchange`
`*`
`* It would be more convenient if each state accepted a message`
`* and produced one.  This is not the case for states at the start`
`* or end of an exchange.  To fix this, we pretend that there are`
`* MR0 and QR0 messages before the MI1 and QR1 messages.`
`*`
`* STATE_MAIN_R0 and STATE_QUICK_R0 are ephemeral states (not`
`* retained between messages) representing the state that accepts the`
`* first message of an exchange that has been read but not yet processed`
`* and accepted.`

</code>

This should be extended to v2.

We may or may not need "0" states for each side of each exchange: that
depends on how the internal logic unfolds. Typically, each exchange
needs its own state object (struct state) to record progress through the
exchange. Generally those would be born in an I0 or R0 state since no
message has been sent at the start.

Tricky point: V2's Auth can successfully end with an IKE SA and an IPSec
SA, or it can successfully end with just an IKE SA. It would seem that
distinct states would be needed to represent those, but in fact they can
be accurately represented: in the former case, there ought to be two
state objects, one for the IKE SA (in STATE_V2_AUTH_\[IR\]) and one for
the IPsec SA (in STATE_V2_CHILD_\[IR\]).

Radical thought: It might be nice if the terminal states of an exchange
had a name that suggested what has been accomplished: not just an
exchange step number, but an SA established. There need not be a
terminal state if there is no accomplishment (i.e. the state object does
not survive). That makes all the tests for "is an SA established?" read
more clearly. Such a change should be apply to v1 states too. I'm not
sure how this extends to or meshes with XAUTH/EAP states.

    Just the initiator side.
    STATE_V2_INIT_I0 = STATE_PARENT_I0 , STATE_V2_INIT_R0 = STATE_PARENT_R0
    STATE_V2_INIT_I  = STATE_PARENT_I1 ,  STATE_V2_INIT_R = STATE_PARENT_R1
    STATE_V2_AUTH_I  = STATE_PARENT_I2  , STATE_V2_IKE_R  = STATE_PARENT_R2
    STATE_V2_IKE_I   = STATE_PARENT_I3  ,

    STATE_V2_CHILD_I0 STATE_V2_CHILD_R
    STATE_V2_CHILD_I2

    STATE_V2_CHILD_REKEY_I0
    STATE_V2_CHILD_REKEY_I

So far this is just a scribbling of ideas. How to name the IKEv2 states.

Do we need "STATE_" prefix to every state enum?


I'm used to it. Without "STATE_" the name could refer to a
message. But some creativity might come up with something clear and
shorter (Hugh).

<!-- -->

    STATE_PARENT_I1 -> IKE_V2_I1
    STATE_PARENT_I2 -> IKE_V2_I2
    STATE_PARENT_I3 -> IKE_V2_I3

    STATE_PARENT_R1 -> IKE_V2_R1
    STATE_PARENT_R2 -> IKE_V2_R2

    IKE_V2_K1 initiate a Rekey (not Reauthentication). Essentially we duplicated a parent and now initiatiing a rekey
    IKE_V2_K

alternative:

    STATE_PARENT_I1 -> STATE_IKE_I1
    STATE_PARENT_I2 -> STATE_IKE_I2
    STATE_PARENT_I3 -> STATE_IKE_I3

    STATE_PARENT_R1 -> STATE_IKE_R1
    STATE_PARENT_R2 -> STATE_IKE_R2

New child states when a Child SA is negotiated as part of
ISAKMP_v2_SA_INIT, aka with Parent SA. During this process also parent
advances its state. The following state name may not have entry in
smc/svm table. Still they are states????


    V2_CHILD_I0 (If we are initiating as part of parent SA Negotiation. On initiator we duplicate when we get R1 back)
    V2_CHILD_I1 if iniiated as part of chreate child SA
    V2_CHILD_R0 responding as part of parenet
    V2_CHILD_R1 initiated as a create child sa
    V2_CHILD_I2 established child
    V2_CHILD_R2 established child

Child states if we create as part of CREATE_CHILD_SA exchange.

    -- The Parent SA just stays in I3/R2.
    -- We create/duplicate a state.
    -- Add new keying material etc.
    -- Complete the negotiate.
    -- Inhert the Children from parent
    -- expire the parent. Switch to IKE_V2_I3/IKE_V2_R2

V2_CHILD_I1 V2_CHILD_I2 V2_CHILD_R1 V2_CHILD_R2

When Parent is Re keying using the old parent. I guess we duplicate and
send new SPI/COOKIES over the old one to negotiate. Newly duplicated
parent need a name too

    V2_REKEY_I1
    V2_REKEY_I2
    V2_REKEY_R1
    V2_REKEY_R1

Rekey Child SA over the existing parents.

    V2_CHILD_REKEY_I1
    V2_CHILD_REKEY_I2
    V2_CHILD_REKEY_R1
    V2_CHILD_REKEY_R2

Multiple Child SA, Pluto code seems to support multiple child SA.

Hugh's current preference: (as of Dec 2016 Anotny is implementing basic
structure for the following set started with IPsec SA.) Started with
Child SA (3 kinds, the one comes with AUTH, IPsec Rekey and IKE Rekey).
Once that is finished Parent SA names will be changed.

    STATE_V2_INIT_I0 /* ephemiral: sent nothing yet (MAY NOT BE NEEDED) */
    STATE_V2_INIT_I /* sent INIT I */
    STATE_V2_AUTH_I /* received INIT R; sent AUTH I */

    STATE_V2_IKE_I /* terminal: created IKE SA, either from AUTH or CREATE_CHILD_SA */
    STATE_V2_IPSEC_I /* terminal: created Child SA, either from CREATE_CHILD_SA or AUTH exchange */

    Since CREATE_CHILD exchange can create a child or a parent, I want to just call it a CREATE exchange.  But perhaps we will find it convenient to break the cases down into NEW_IPSEC, REKEY_IKE, and REKEY_IPSEC.

    STATE_V2_CREATE_I0 /* ephemeral: sent nothing yet */
    STATE_V2_CREATE_I /* sent first message of CREATE_CHILD exchange */
    ??? don't we need a terminal state for state IPSEC/ESP state object? They will have their own nonce, key, subnets, ESP...

    STATE_V2_REKEY_IKE_I0 /* ephemeral: sent nothing yet */
    STATE_V2_REKEY_IKE_I /* sent first message (via parrent to rekey parent. Terminal state is STATE_V2_IKE_I */

    STATE_V2_CHILD_REKEY_I0
    STATE_V2_CHILD_REKEY_I /* sent first message (via parent to rekey child sa. Terminal state is  STATE_V2_CREATE_I*/

Guidelines when you want to improve the name/story:

As of 2016 a state has three values(strings associated with): here is a
example of STATE_V2_IPSEC_I


    enum state_kind {STATE_V2_IPSEC_I}  include/pluto_constants.h

    /* State of exchanges */
    static const char *const state_name[] = { "STATE_V2_IPSEC_I" } in programs/pluto/pluto_constants.c

    char *const state_story[] = { "IPsec SA established",         /* STATE_V2_IPSEC_I */ }  in programs/pluto/pluto_constants.c


    When these three are combained in a log line it will look like
    "004 "westnet-eastnet-ikev2a" #2: STATE_V2_IPSEC_I: IPsec SA established tunnel mode {ESP=>0x6f792e5b <0x46fcae51 xfrm=AES_GCM_C_256-NONE NATOA=none NATD=none DPD=passive"

## Current as of 3.20+

When suggesting improvements keep in mind all there to avoid duplicate
text. The 4th part is the the comment. Which is also important.

|                         |                         |                                      |                                                                                       |
|-------------------------|-------------------------|--------------------------------------|---------------------------------------------------------------------------------------|
| state_name              | state_kind              | state_story                          | comment                                                                               |
| STATE_IKEv2_BASE        | STATE_IKEv2_BASE        | invalid state - IKEv2 base           | state when faking a state                                                             |
| STATE_PARENT_I1         | STATE_PARENT_I1         | sent v2I1, expected v2R1             | IKE_SA_INIT: sent initial message, waiting for reply                                  |
| STATE_PARENT_I2         | STATE_PARENT_I2         | sent v2I2, expected v2R2             | IKE_AUTH: sent auth message, waiting for reply                                        |
| STATE_PARENT_I3         | STATE_PARENT_I3         | PARENT SA established                | IKE_AUTH done: received auth response                                                 |
| STATE_PARENT_R1         | STATE_PARENT_R1         | received v2I1, sent v2R1             | IKE_SA_INIT: sent response                                                            |
| STATE_PARENT_R2         | STATE_PARENT_R2         | received v2I2, PARENT SA established |                                                                                       |
| STATE_V2_AUTH_CHILD_I0  | STATE_V2_AUTH_CHILD_I0  | received R1 v2 AUTH CHILD            | ephemeral: duplicated from I2 send nothing yet.                                       |
| STATE_V2_AUTH_CHILD_I   | STATE_V2_AUTH_CHILD_I   | Child sent AUTH v2I2 expect v2R2     | sent I2 AUTH exchange only after v3.23 or 24, Dec 2017                                |
| STATE_V2_CREATE_I0      | STATE_V2_CREATE_I0      | STATE_V2_CREATE_I0                   | ephemeral: sent nothing yet.                                                          |
| STATE_V2_CREATE_I       | STATE_V2_CREATE_I       | sent IPSec Child req wait response   | sent first message of CREATE_CHILD exchange                                           |
| STATE_V2_REKEY_IKE_I0   | STATE_V2_REKEY_IKE_I0   | STATE_V2_REKEY_IKE_I0                | ephemeral: sent nothing yet terminal state STATE_PARENT_R2                            |
| STATE_V2_REKEY_IKE_I    | STATE_V2_REKEY_IKE_I    | STATE_V2_REKEY_IKE_I                 | sent first message (via parrent) to rekey parent. Terminal state is STATE_V2_IKE_I    |
| STATE_V2_REKEY_CHILD_I0 | STATE_V2_REKEY_CHILD_I0 | STATE_V2_REKEY_CHILD_I0              | ephemeral: send nothing yet terminal state ???                                        |
| STATE_V2_REKEY_CHILD_I  | STATE_V2_REKEY_CHILD_I  | STATE_V2_REKEY_CHILD_I               | sent first message (via parent to rekey child sa. Terminal state is STATE_V2_CREATE_I |
| STATE_V2_CREATE_R       | STATE_V2_CREATE_R       | STATE_V2_CREATE_R                    | ephemeral: sent nothing yet                                                           |
| STATE_V2_REKEY_IKE_R    | STATE_V2_REKEY_IKE_R    | STATE_V2_REKEY_IKE_R                 | ephemeral: sent nothing yet terminal state STATE_PARENT_R2                            |
| STATE_V2_REKEY_CHILD_R  | STATE_V2_REKEY_CHILD_R  | STATE_V2_REKEY_CHILD_R               |                                                                                       |
| STATE_V2_IPSEC_I        | STATE_V2_IPSEC_I        | IPsec SA established                 | IPsec SA final state - CREATE_CHILD & AUTH                                            |
| STATE_V2_IPSEC_R        | STATE_V2_IPSEC_R        | IPsec SA established                 | IPsec SA final state - CREATE_CHILD & AUTH                                            |
| STATE_IKESA_DEL         | STATE_IKESA_DEL         | STATE_IKESA_DEL                      | better story needed                                                                   |
| STATE_CHILDSA_DEL       | STATE_CHILDSA_DEL       | STATE_CHILDSA_DEL                    | better story needed                                                                   |
| STATE_IKEv2_ROOF        | STATE_IKEv2_ROOF        | invalid state - IKEv2 roof           |                                                                                       |

IKEv2 State Names

## Proposed

|                                        |                      |                      |                                      |                                     |                                                                                       |
|----------------------------------------|----------------------|----------------------|--------------------------------------|-------------------------------------|---------------------------------------------------------------------------------------|
| original_name                          | state_name           | state_kind           | original_story                       | state_story                         | comment                                                                               |
| STATE_IKEv2_BASE/STATE_IKEv2_PAEENT_I0 | STATE_IKEv2_LARVAL   | STATE_IKEv2_BASE     | invalid state - IKEv2 larval         | invalid state - IKEv2 larval        | state when faking a state                                                             |
| STATE_PARENT_I1                        | STATE_IKE_INIT_I     | STATE_IKE_INIT_I     | sent v2I1, expected v2R1             | sent IKE_SA_INIT, waiting for reply | IKE_SA_INIT: sent initial message, waiting for reply                                  |
| STATE_PARENT_I2                        | STATE_IKE_AUTH_I     | STATE_IKE_AUTH_I     | sent v2I2, expected v2R2             | sent AUTH_I, expect AUTH_R          | IKE_AUTH: sent auth message, waiting for reply                                        |
| STATE_PARENT_I3                        | STATE_IKE_SA_EI      | STATE_IKE_SA_EI      | PARENT SA established                | IKE SA established                  | IKE_AUTH done: received auth response                                                 |
| STATE_PARENT_R1                        | STATE_IKE_INIT_R     | STATE_IKE_INIT_R     | received v2I1, sent v2R1             | received INIT_I, sent INIT_R        | IKE_SA_INIT: sent response                                                            |
| STATE_PARENT_R2                        | STATE_IKE_SA_R       | STATE_IKE_SA_R       | received v2I2, PARENT SA established | received AUTH_I, IKE SA established | IKE_AUTH: sent response                                                               |
|                                        | STATE_CHILD_AUTH_I0  | STATE_CHILD_AUTH_I0  |                                      | prepare to CHILD AUTH_I             |                                                                                       |
|                                        | STATE_CHILD_AUTH_I   | STATE_CHILD_AUTH_I   |                                      | send CHILD AUTH_I, expect AUTH_R    |                                                                                       |
|                                        | STATE_CHILD_AUTH_R0  | STATE_CHILD_AUTH_R0  |                                      | prepare to CHILD AUTH_R             |                                                                                       |
| STATE_V2_CREATE_I0                     | STATE_CHILD_I0       | STATE_CHILD_I0       | STATE_V2_CREATE_I0                   | prepare to CREATE_CHILD             | ephemeral: sent nothing yet                                                           |
| STATE_V2_CREATE_I                      | STATE_CHILD_I        | STATE_CHILD_I        | sent IPSec Child req wait response   | sent CREATE_CHILD, expect response  | sent first message of CREATE_CHILD exchange                                           |
| STATE_V2_REKEY_IKE_I0                  | STATE_IKE_REKEY_I0   | STATE_IKE_REKEY_I0   | STATE_V2_REKEY_IKE_I0                | prepare to rekey IKE SA             | ephemeral: sent nothing yet terminal state STATE_IKE_SA_I                             |
| STATE_V2_REKEY_IKE_I                   | STATE_IKE_REKEY_I    | STATE_IKE_REKEY_I    | STATE_IKE_REKEY_I                    | send IKE_INIT rekey request         | sent first message (via parrent) to rekey parent. Terminal state is STATE_IKE_SA_I    |
| STATE_V2_REKEY_CHILD_I0                | STATE_CHILD_REKEY_I0 | STATE_CHILD_REKEY_I0 | STATE_V2_REKEY_CHILD_I0              | prepare to rekey CHILD SA           | ephemeral: send nothing yet terminal state ???                                        |
| STATE_V2_REKEY_CHILD_I                 | STATE_CHILD_REKEY_I  | STATE_CHILD_REKEY_I  | STATE_V2_REKEY_CHILD_I               | sent REKEY_SA request               | sent first message (via parent to rekey child sa. Terminal state is STATE_V2_CREATE_I |
| STATE_V2_CREATE_R                      | STATE_CHILD_R        | STATE_CHILD_R        | STATE_V2_CREATE_R                    | received CREATE_CHILD request       | ephemeral: sent nothing yet                                                           |
| STATE_V2_REKEY_IKE_R                   | STATE_IKE_REKEY_R    | STATE_IKE_REKEY_R    | STATE_V2_REKEY_IKE_R                 | received IKE_INIT rekey request     | ephemeral: sent nothing yet terminal state STATE_PARENT_R2                            |
| STATE_V2_REKEY_CHILD_R                 | STATE_CHILD_REKEY_R  | STATE_CHILD_REKEY_R  | STATE_V2_REKEY_CHILD_R               | received REKEY_SA request           |                                                                                       |
| STATE_V2_IPSEC_I                       | STATE_CHILD_SA_EI    | STATE_CHILD_SA_EI    | IPsec SA established                 | Child SA established                | Child SA final state - CREATE_CHILD & AUTH                                            |
| STATE_V2_IPSEC_R                       | STATE_CHILD_SA_ER    | STATE_CHILD_SA_ER    | IPsec SA established                 | Child SA established                | IPsec SA final state - CREATE_CHILD & AUTH                                            |
| STATE_IKESA_DEL                        | STATE_IKE_DEL        | STATE_IKE_DEL        | STATE_IKESA_DEL                      | deleting IKE SA                     | better story needed                                                                   |
| STATE_CHILDSA_DEL                      | STATE_CHILD_DEL      | STATE_CHILD_DEL      | STATE_CHILDSA_DEL                    | deleting CHILD SA                   | better story needed                                                                   |
|                                        | STATE_IKEv2_ROOF     | STATE_IKEv2_ROOF     |                                      | invalid state - IKEv2 roof          |                                                                                       |

IKEv2 State Names - Proposal for name cleanup