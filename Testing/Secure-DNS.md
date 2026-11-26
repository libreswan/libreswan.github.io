<!-- file-is-title -->

It's broken.

It relies on being able to generate `libreswan.org` and then use it to
sign sub-domains.  But the whole point of DNSSEC is to detect and
reject this.  Hence DNSSEC tests disable this; oops.

- Is it possible to mis-configure DNS to "trust" the bogus
  `libreswan.org` signature, and not walk further up the tree?

The correct fix is to build a full top-level domain using `.test`.
For instance:

```
east.internet.test
east.eastnet.test
...
```

but documentation on how to do this is scant.
