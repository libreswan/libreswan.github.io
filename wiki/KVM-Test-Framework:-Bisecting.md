## Tracking down regressions (using git bisect)

### The easy way

This workflow works best when the regression is recent.  I.e., the
last few commits where nothing significant has happened (for instance,
os upgrade, test rename, ...).

The command `./kvm install check diff` exits with a `git bisect`
friendly status code which means it can be combined with `git bisect
run` to automate regression testing.

For instance, lets say unpushed commits have caused a regression in
`basic-pluto-01`.  First set up `git bisect`:

```
git bisect start
git bisect bad # tip is bad
```

Since there are unpushed changes, `@{u}` or upstream mainline, is a
good first guess at a good commit:

```
git checkout @{u}
./kvm install check diff testing/pluto/basic-pluto-01
```

Assuming it passes (if it doesn't time to go further back), mark it
good and then let `git bisect` loose:

```
git bisect good
git bisect run ./kvm install check diff testing/pluto/basic-pluto-01
```

`git bisect visualize` is a good way to monitor progress.  Finally,
cleanup:

```
git bisect reset
```

### The hard way

This workflow works best when trying to track down a regression in an
older version of libreswan.

Two repo directories are used:

1.  `rutdir` aka `repo-under-test`
    this contains the sources that will be built and installed into the
    test domains and is what git bisect will manipulate

2.  `benchdir` aka `testbench`
    this contains the test scripts used to drive `rutdir`

(testing uses this)

Start by checking out the two repositories (existing repositories can
also be used, carefully):

```
git clone https://github.com/libreswan/libreswan.git rutdir
git clone https://github.com/libreswan/libreswan.git benchdir
```

and then cd to `rutdir` directory:

```
cd rutdir
```

Next, configure `benchdir` so that it compiles and installs libreswan
from `rutdir` but runs tests from `benchdir`.  Do this by pointing the
`benchdir` `KVM_SOURCEDIR` (`/source`) at `rutdir` vis:

```
# remember $PWD is rutdir`
echo KVM_SOURCEDIR=$(realpath ../rutdir)            >>../benchdir/Makefile.inc.local
echo KVM_TESTINGDIR=$(realpath ../benchdir/testing) >>../benchdir/Makefile.inc.local
```

Now, (re-)transmogrify `benchdir` so that, within the domains,
`/source` points at `repo-under-test`:

```
../benchdir/kvm transmogrify
```

in the command building the Linux domain look for output like:

```
--filesystem=target=bench,type=mount,accessmode=squash,source=/.../benchdir \
--filesystem=target=source,type=mount,accessmode=squash,source=/.../rutdir \
--filesystem=target=testing,type=mount,accessmode=squash,source=/.../benchdir/testing \
```

Finally run the tests (remember testing/pluto/basic-pluto-01 is the
test that started failing):

```
# start with the bad commit
git bisect start
git bisect bad
# next checkout and confirm the good commit
# NOTE: run benchdir/kvm from rutdir directory
git checkout <good-commit>
../benchdir/kvm install check diff testing/pluto/basic-pluto-01
git bisect good
```

if you're lucky, the test requires no manual intervention and:

```
git bisect run ../benchdir/kvm install check diff testing/pluto/basic-pluto-01
```

also works.  Finally, cleanup with:

```
git bisect reset
```

TODO: figure out how to get `../benchdir/kvm diff` to honour
`$(KVM_TESTINGDIR)` so that it can handle a test somewhere other than
in the benchdir.
