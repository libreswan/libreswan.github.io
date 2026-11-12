<!-- file-is-title -->

Here's several suggestions on how to handle retransmits and timeouts.
The thing to remember is that the transport essentially 100% reliable
so retransmits are not needed.

## For when Retransmits don't matter

### Append `... # sanitize-retransmits` to commands

Removes retransmits from just that commands sanitized output, so
expect to apply it liberally.

### Add `conn %default; retransmit-timeout=10s; retransmit-interval=20s`

Since most things should finish in under 10s there should never be a
retransmit.

## For when Retransmits do matter

### Add `conn %default; retransmit-timeout=5s; retransmit-interval=10s`

For when a timeout is expected.  Presumably other exchanges complete
in less than 5s.

### Add `conn %default; retransmit-timeout=9s; retransmit-interval=5s`

IKEv1 sends the full payload, and then retransmits with a fragmented
payload.  The above makes that visible.

## Past Mistakes

### `--impair timeout_on_retransmit`

It only worked reliably when the first message was expected to
timeout.

When multiple exchanges are involved (for instance IKE_INTERMEDIATE),
it could easily timeout for no reason other than the peer taking
longer than usual.

### Global Retransmit Sanitizer

The problem was that it sanitized retransmits when they were part of
the test.
