## Introduction

Postquantum Preshared Keys (**PPK**) are an addition to the IKEv2
protocol to ensure that currently encrypted traffic which is stored is
safe against against future quantum computer decryption. A PPK is shared
securely out-of-band and is used as an input into the SKEYSEED
generation. This means that even if the IKEv2 DiffieHellman is
compromised, an attacker cannot obtain the key material (KEYMAT). The
PPK method is specified in
[RFC8784](https://datatracker.ietf.org/doc/rfc8784/).

## Implementation

To allow the use of PPK's in libreswan, the following options were
added:

- The values 16435, 16436 and 16437 were picked as numbers for PPK_USE,
  PPK_IDENTITY and NO_PPK_AUTH Notify messages, respectively. The
  numbers were assigned by IANA (on 7th February 2018).

<!-- -->

- Changes were made in source files (programs/pluto/*ikev2_\*.c*) where
  IKEv2 is implemented.

<!-- -->

- The secret reading/handling code in lib/libswan was updated to support
  PPKs.

<!-- -->

- New test cases were added. These can be found as *ikev2-ppk-\**
  folders in the testing/pluto/ directory.

## Configuring a PPK and connection in libreswan

Each PPK has its own PPK_ID - a unique string that identifies which PPK
to use.

In libreswan PPK are stored in the *secrets file* (eg
/etc/ipsec.secrets)

Two types of PPK are supported: *static* and *dynamic*.

**Important note:** *Dynamic* PPK will be removed in version 3.24., and
re-added in later versions.

**1.** *Static PPK* is represented with two strings separated by spaces.
The first string is PPK_ID and the second one PPK. The keyword for
.secrets file in libreswan is PPKS.

e.g. 10.1.0.1 10.2.0.1 : PPKS "lsw1"
"very_long_string_that_is_a_postquantum_preshared_key"

**2.** *Dynamic PPK* (work in progress) is represented with two strings
separated by spaces. The first string is PPK_ID and the second one is a
path to another file which the PPKs will be taken from. This file should
also have only two strings in it. The first one would be *offset* and
the second one a long string that will be used as a *one-time pad*. Each
time when a PPK should be loaded into the libreswan, the string of fixed
length will be taken from a second string with an offset from first
string. After this PPK has been used, libreswan overrides that part of a
string with zeros (0x30) and updates the offset to offset+PPK size. This
way each time two peers establishing an IPSEC tunnel will use a
different PPK for it. ''

The *ppk* option is specified in the connection configuration. Accepted
values are *never/no*, *propose/yes* and *insist*.

The PPK option is only valid when using IKEv2.

It is *recommended* that the PPK has length of **at least 256 bits**, in
order to provide real security against quantum computer attacks.

## Source code

The code is commited into libreswan master branch, and PPK feature is
available in libreswan as of release 3.23.

Code commit:

[<https://github.com/libreswan/libreswan/commit/d8e0c68c0dc19d95dfcf19fec934e9dc69c293ac>](https://github.com/libreswan/libreswan/commit/d8e0c68c0dc19d95dfcf19fec934e9dc69c293ac)

The main developer of this feature is Vukasin Karadzic, and this has
been done as a summer project under the mentorship of Paul Wouters and
Tuomo Soini.

For any questions, found bugs or suggestions feel free to contact him on
vukasin.karadzic@gmail.com or send an e-mail to
swan-dev@lists.libreswan.org mailing list.