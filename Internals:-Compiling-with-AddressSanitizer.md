AddressSanitizer (or ASAN) is a programming tool that detects memory
corruption bugs such as buffer overflows or accesses to a dangling
pointer (use-after-free). AddressSanitizer is based on compiler
instrumentation and directly-mapped shadow memory. For more information
see the \[Wikipedia Page
<https://en.wikipedia.org/wiki/AddressSanitizer>\] page and the \[Google
ASAN <https://code.google.com/p/address-sanitizer/wiki/>\] page.

To enable ASAN (which requires clang or gcc \>= 4.8) for libreswan, you
need to change the linking flags. This can be done by setting the
USERLINK environment variable, or setting this variable in the file
Makefile.inc.local. See also the USERLINK setting in mk/config.mk.

    export USERLINK="-Wl,-z,relro,-z,now -g -pie -fsanitize=address"

On libreswan-3.14 and above you can compile with ASAN support using:

    make ASAN="-fsanitize=address" programs

You will also need to install libasan (using yum, dnf or apt-get)

Enabling ASAN will cause it to throw reports to stderr. Use
libreswan-3.14 or the git master code which fixes _stackmanager to
ignore these. On older versions you can run:

    ASAN_OPTIONS=detect_leaks=0 ipsec _stackmanager start

The IKE daemon pluto will throw leak reports on stderr which confuses
some init systems, such as systemd. The initsystems will also redirect
these messages elsewhere. So the easiest way to start libreswan and get
the ASAN reporting on the console is to use:

    ipsec _stackmanager start
    ipsec pluto --config /etc/ipsec.conf --nofork --stderrlog

In another terminal, run the tests you want to add with
adding/upping/removing any connections. When done run:

    ipsec whack --shutdown

The ASAN messages will now appear on the terminal you started pluto on.

Note that you should <b>not</b> enable --leak-detective and not link
against ElectricFence, because those mechanisms try to do similar things
and you will just make it harder to debug any ASAN messages you will
get,