Pluto previously had its own stylistic conventions but they were
abandoned and starting from Libreswan 3.4 only Linux Kernel coding style
is accepted.

Please read the [Coding Style](https://www.kernel.org/doc/Documentation/CodingStyle) document thoroughly.

Your editor likely has a way to configure this.  In EMACS it's called _linux style_.

Idiom's are not requirements.

## Here are some additional hints

- you can use checkpatch.pl utility from kernel to check your patches
  before committing.

  git diff | checkpatch.pl --no-tree --no-signoff -

## An example
```
void fun(char *s)
{
        if (s == NULL) {
                return "";
        }

        switch (*s) {
        default:
                s++;
                return s;
        case '\0':
                return s;
        }
}
```

- notice:
  + no line should have trailing whitespace<br>emacs: `(setq-default show-trailing-whitespace t)`
  + leading whitespace should use spaces, not tabs
  + indentation should be precise
  + there should be no empty lines at the end of a file.
  + a single space separates a control flow reserved word and its operand.
  + no space follows a function name
  + opening braces are not on their own line (switch-case being an exception)

- try to keep lines shorter than 80 columns

- changelogs look something like:

```
ikev2: implement that missing protocol

See RFC magic description.
close #555 maybe a bug
```

- don't use case fall-through

- the operand of return need not be parenthesised

- be careful with types.  For example, use `size_t` and `ssize_t`.
  Use `const` wherever possible.

- really try to avoid casts

- we assume and use `<stdbool.h>`

- we like enums (they help the compiler check parameters)

- streq(a,b) is clearer than strcmp(a,b) == 0.
  memeq is clearer than memcmp.
  zero is clearer than memset (but zero(&array) not zero(array)!).

- to initialise a structure use `{0}`

- use passert() and pexpect(), not assert.

- side-effects of expressions are to be avoided.
  BAD:  if (i++ == 9)
  OK:	i++;

- variables are to have as small a scope as is possible
  (definitions can go any where; not just at the start of the function)

  + we like local-to-loop as in `for (unsigned i = 0; i < ...; i++)`
  + move definitions into inner blocks whenever possible.
  + merge definition with initialisation when possible

  User "static" to limit a variable or function scope to a file.

- some common names:

  + `c` is a connection
  + `md` is a message digest
  + `st` is an SA (state), either IKE or Child
  + `e` is err_t
  + `d` is diag_t

- open arrays are ok

  but check ITEMS_FOR_EACH() et.al.

- "magic numbers" are suspect.  Most integers in code stand for
  something.  They should be given a name (using enum or #define), and
  that name used consistently.

  It is especially bad if the same number appears in two places in a way
  that requires both to be changed together (eg. an array bound and
  a loop bound).  Often sizeof or elemsof() can help.

- Conditional compilation is to be avoided.  It makes testing hard.

  When conditionally compiling large chunks of text, it is good to put
  comments on #else and #endif to show what they match with.  I use !
  to indicate the sense of the test:

  #ifdef CRUD
  #else /* !CRUD */
  #endif /* !CRUD */

  #ifndef CRUD
  #else /* CRUD */
  #endif /* CRUD */

- Never put two statements on one line.  Especially empty statements.
  REALLY BAD: if (cat);

  Exception: some macro definitions.
  Exception; jam_string(buf, sep); sep = ","

- don't micro-optimise with `inline` functions in headers

  ditto macros

  Just put them in .[hc]:
  + the LTO compiler will inline them anyway
  + the performance bottle neck is elsewhere

- macros are used as a poor-developer alternative to templates et.al.

- you can use __STD_ARGS__ in macros

- you can use ({}) in macros

## Headers

- `.c` files include in the following order:

  + system headers; using `#include <system-header.h>`
  + libreswan headers; using `#include "header.h"`

  Headers from `include/` are also typically included before headers from the local file.

- headers have a full(C) a the top

- headers are wrapped in

  ```
  #ifndef HEADER_H
  #define HEADER_H
  #endif
  ```

  so that duplicate includes do-no-harm

- library headers explicitly include their dependencies

  (pluto, with `defs.h` is a different story)

  A common idiom is for the `.c` file to include the `.h` file at the top (which helps to ensure this).

- all functions and variables that are exported from a .c file should
  be declared in that file's corresponding header file.

  Make sure
  that the .c file includes the header so that the declaration and the
  definition will be checked for consistency by the compiler.

  There is no excuse for the "extern" keyword in a .c file.

  There is almost no excuse for the declaration of an object within a
  .h file to NOT have the "extern" keyword.  We are a lax about
  this for function declarations (because a definition is clearly
  marked by the presence of the function body).

  Technical detail: C has declarations of variables and functions.
  Some of these are definitions.  Some are even "tentative definitions".
  We don't want definitions or tentative definitions within .h files.
  We don't want declarations that are not definitions within .c files.
  "extern" usually signifies a variable declaration that isn't a definition.

## Memory Management

- we use custom wrappers around malloc() and free(); see `lswalloc.h`

  + it guarantees zero on allocate, and scrambled on free

  + it includes macros to overallocate buffers and allocate arrays

  + if you mix it with malloc() et.al., pluto will core dump

  + it detects unreleased memory

- in addition, many structures are reference counted; see `refcnt.h`

- calls to NSS often require the use of the NSS allocator

- we do not use alloca() nor dynamic arrays

## Logging

Most objects include a logger (`state->logger`, `md->logger`, ...) that contains context (prefix) for the message; removing the need to include context in the message.

Log messages are not complete sentences, i.e., they don't start with a capital or end in a full stop, use `;` to break long messages.

There are two ways to emit log messages:

- llog() and family
  short and sharp
- LLOG_JAMBUF() and family
  for when constructing the log message requires code

oh, and two more:

- show
  wrapper around llog that emits line breaks between text blocks (see whack_status)
- verbose
  wrapper around llog that indents debug messages; and can have optional messages

## Byte and String Buffers - chunk_t, and shunk_t, and hunk like objects

- when manipulating bytes and string we use hunk like objects; they contain a `.ptr` (or buffer) and a `.len` field

- for raw bytes, such as received over the wire, we use the predefined chunk_t type

  + Functions and macros to manipulate byte buffers can be found in `chunk.h` and `hunk.h`.

  + To detect an empty buffer test `.len==0` and not `.ptr=NULL`.
```
struct {
  unsigned len;
  uint8_t *ptr;
}
```
- for strings, such as when processing config files, we strongly prefer the predefined `shunk_t` type

  + Unlike C's traditional `const char *` it has a bound.

  + Functions and macros to manipulate string buffers can be found in `shunk.h` and `hunk.h`.

  + To detect an empty buffer test `.len==0` and not `.ptr=NULL`.
```
struct {
  unsigned len;
  const void *ptr;
}
```

- finally other structures can contain .ptr and .len making them hunk like

  + DANGER: some hunk like objects declare ptr as an array

- NSS has a similar, but annoyingly different, SECItem

  (chunk_t predates Libreswan using NSS, hence the difference)

## Names

Libreswan has two types of name tables for converting between names an numeric values: `enum_names` and `sparse_names`.  The former is good for enums where values are consecutive; the latter where values are discontinuous.
