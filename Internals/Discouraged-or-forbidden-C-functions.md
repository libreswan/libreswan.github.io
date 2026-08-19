Most of the libreswan code is written in C. The standard C libraries
come with many functions people use. Some of these functions are
dangerous to use or for other reasons should not be used with libreswan.
Some of these functions are never allowed, some are strongly
discouraged.

**TODO: clarify which environments each function is intended for:** Some
of these substitutions are for all code, some are for userland code, and
some are only for Pluto itself.

## malloc() and friends

Libreswan's Pluto uses a builtin memory leak detection system that can
be activated by starting Pluto with the --leak-detective option. To
facilitate this, the standard memory allocation functions are wrapped in
our own functions, such as alloc_bytes(), clone_bytes(), alloc_thing()
and pfree() and pfreeany(). Using a free() on memory allocated with
alloc_bytes() will lead to a crash. Using a pfree() on memory allocated
by malloc will also lead to a crash.

There are a few objects in Pluto that are allocated and freed using
malloc(3), free(3) and friends. In each case there is a reason and that
reason is documented carefully. It is VERY important to match allocation
and deallocation mechanisms.

**TODO: there is no man page for the allocation functions**

Therefor, alloc(3), calloc(3), realloc(3) and free(3) should only be
used in exceptional circumstances.

See *lib/libswan/alloc.c* for details.

## \*cmp(3) functions: strcmp(3), strncmp(3), strcasecmp(3), strncasecmp(3), memcmp(3)

These functions yield a signed result indicating the ordering of the
arguments:

> functions return an integer less than, equal to, or greater than zero
> if s1 (or the first n bytes thereof) is found, respectively, to be
> less than, to match, or be greater than s2.

It turns out that almost all calls are used to determine simple
equality. The result returned by the \*cmp functions is inconvenient for
that: an == 0 needs to be added. Worse, if they are used as if they
returned a boolean value, the sense is opposite: equality (0) is treated
as FALSE.

So we provide wrappers to make the code clear: a \*eq macro for each
\*cmp function. This makes the code much more readable.

Bonus macro: startswith() captures an idoimatic use of strneq, testing
whether a string starts with a particular literal.

**TODO: there is no man page for streq() or strneq()**

See *lib/libswan/constants.c* for details.

## strcpy() and strncpy()

Everyone knows that strcpy(3) is dangerous because the destination might
be overrun if the source string is too large.

strncpy(3) is the perfect function to fill a fixed-length buffer from a
string and padding it with NULs. It turns out that this functionality
isn't frequently needed. At the moment, not once in Libreswan.

Some people think that strncpy(3) is the proper replacement for
strcpy(3). With care, this can be managed. There are at least three
problems with this. strncpy(3) pads the whole destination with NUL
characters, almost always much more than is needed. If there is
insufficient room, strncpy(3) does not ensure that the resulting
destination string is NUL terminated (which is what the programmer
usually wanted). If the resulting string is truncated, this is done
silently, without any way of informing the caller and hence with no way
of reporting a problem.

Pluto's jam_str() addresses these problems, and slightly more. It
demands that the destination have at least one byte. In return, it
guarantees that the result in destination is NUL-terminated. It does not
pad. It returns a pointer that can be used to determine if overflow
happened, and, if not, where one could concatenate to the result. It
remains up to the caller to emit diagnostics on overrun.

When talking with the kernel, there are cases where fixed length buffers
perhaps need to be NUL-padded. For example, network interface names in
BSD (but not Linux) should be NUL-padded. This requirement is not well
documented. To be on the safe side, we define and use the
fill_and_terminate() macro. It is like strncpy but it makes sure that
the last byte in the destination is '\0'. This means that in certain
cases we cannot use the longest values names.

**TODO: there is no man page for jam_str()**

See *lib/libswan/constants.c* for details.

## gets(3), sprintf(3)), strcat(3)

Each of these functions makes it hard or impossible to ensure that the
destination buffer isn't overrun. Only use them when you can simply
prove that there will be no overrun.

## strcat() and strncat()

strcat(3) can easily overrun the destination buffer: avoid it.
strncat(3) helps prevent this problem, but it is a bit awkward. Slightly
surprising is that the length does not include the terminating NUL
character. Use our own add_str() instead. This is similar to OpenBSD's
strlcat()

See *lib/libswan/constants.c* for details.

## thread related functions

Pluto is written to handle events based on timers or packets one by one
serially. Threads really interfere with this model. The only threads
allowed currently are within the authentication code, the crypto helper
code, Xauth, and the PAM helper code. Unless you have talked to the
developers and they agree, additional threading code will be rejected.
See \[some page about pluto\]