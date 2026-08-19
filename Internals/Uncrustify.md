Cleaning up the formatting is a good idea.

Doing it on a "flag day" is necessary.

It will create a break in history -- we need to mitigate this.

The process should be idempotent so we can regularly re-apply it.

The process should be incorporated into the makefiles so it is reliably
reproduceable.

It is imaginable that it be done with some git hooks so only pretty code
is checked in.

Linux kernel style should be the baseline. Some modifications might be
worthwhile.

Hugh thinks that it is a mistake to remove all redundant braces.
Sometimes they add clarity.

Formatting tables legibly is an art and may not be handled well by a
program.

How should parameters be aligned? In declarations? In calls?

- Below and inside open parent? Requires tabs followed by spaces
  (requires extra care when editing). Kernel style. Although uncrustify
  seems to be off by one column.

<!-- -->

- One tab in? In declarations, this is same as body indentation,
  confusing?

Leave empty lines between cases, but don't force any.

Brace at end of if(...), even if multiline.

Non-scalar initializers are problematic. Formatting isn't idempotent.
There isn't an obvious rule for algorithmic layout.

libreswan 3.4 is the release where we ran uncrustify. The configurations
and instructions used are in docs/uncrustify/