Often code changes cause log messages to change which, in turn, causes
test cases to fail.

Here's two suggestions for how to more efficiently handle this:

- use `sed -i -e ... testing/pluto/*.console.txt` to update test output

- use `./kvm modified ...` to limit runs to just the modified tests

For instance, lets say the log message 'established IKE SA' is being
changed to 'EsTaBlIsHeD IKE SA':

Start by running the testsuite:

```
./kvm install check
```

it will quickly start to report failures. lots of failures!  CNTRL-C
the test.  To get a list of tests that failed so far:

```
./kvm failed
```

and to see what is different:

```
./kvm diff
- established IKE SA
+ EsTaBlIsHeD IKE SA
```

or:

```
./kvm diff EsTaBlIsHeD IKE SA
```

Now mass edit the testsuite to hopefully fix this:

```
sed -i -e 's;established IKE SA;EsTaBlIsHeD IKE SA;' testing/pluto/*/*.console.txt
```

_Note: this will also edit WIP tests that aren't normally run; that's
ok._

List the modified tests, and check them:

```
./kvm modified
./kvm modified check
```

_Note: this will run WIP modified tests which aren't expected to pass;
that's ok._

Use:

```
./kvm failed
```

to see the results for the good tests.

Finally, resume the test run, picking up from where things left off:

```
./kvm recheck
```
