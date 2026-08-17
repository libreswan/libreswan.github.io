### Background

Yes, it's DocBook!

The original Libreswan documentation which dates back to the 1990's,
and like any good UNIX documentation, was written using nroff.

Then during the early 2000's, DocBook became flavour of the month
within sections of the Linux community.  It seems Libreswan was
dragged into this fad, and had its documentation converted; badly.

Since then, there's been a slow effort to clean things up.

So here we are.

### Entities

The documentation makes use of entities.  For instance, instead of
writing:

```
<literal>yes</literal>
```

just

```
&yes;
```

can be used.  The list so-far is in mk/entities.xml, but plenty are
missing.

### Add Historic Notes

Distros with old releases are, unfortunately, common.  Having documentation on when
features are added will help the reader (and a provide a reason to update). For instance:

_The option ... was added in Libreswan 4.3_

_The option ... was deprecated in Libreswan 5.2_.

### Be Cautious with experimental features

Documenting a new experimental feature consider adding <caution> to the documentation.
