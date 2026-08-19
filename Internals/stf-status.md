States (enum state_kind values) reflect where we are in a negotiation,
between events. During the processing of events, many things are up in
the air and the state will be in transition. During processing, the fine
details of where we are in negotiation is reflected in where we are in
the code.

In IKEv1, it was pretty easy to treat the place in the sequence of
messages of a negotiation as the state of negotiation: a message was
either accepted or rejected. Furthermore, in a particular kind of
exchange, each payload came in a standard-specified message. IKEv2 lets
payloads be in any of several messages and you can drag out or compress
the exchange as much as you want. This means that the state of
negotiation may not be the same as the place in the sequence of messages
of an exchange. If the payloads were in a fixed order, even if not in a
fixed message, you could think of the state as being the position in the
sequence of payloads. On the downside, this multiplies the number of
states.

The state needs to reflect what has been done and (perhaps implicitly)
what still needs to be done. At least for all points between events.

Currently, known stf_result states are (include/pluto_constants.h):

    typedef enum {
        STF_IGNORE,             /* don't respond */
        STF_SUSPEND,            /* unfinished -- don't release resources */
        STF_OK,                 /* success */
        STF_INTERNAL_ERROR,     /* discard everything, we failed */
        STF_FATAL,              /* just stop. we can't continue. */
        STF_DROP,               /* just stop, delete any state, and don't log or respond */
        STF_FAIL,               /* discard everything, something failed.  notification_t added.
                     * values STF_FAIL + x are notifications.
                     */
        STF_ROOF = STF_FAIL + 65536 /* see RFC and above */
    } stf_status;