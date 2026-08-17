## TL;DR?

```
./kvm check testing/pluto/test-name
```
or
```
./kvm check
```

## Running the testsuite

The testsuite is driven using the top-level script `./kvm`

Here are the commands

```
./kvm install
```

update the KVMs ready for a new test run

````
./kvm check
```

run the testsuite, previous results are saved in `BACKUP/-date-`

```
./kvm recheck
```

run the testsuite, but skip tests that already passed

```
./kvm results
```

list the results from the test run

```
./kvm diffs
```

display differences between the test results and the expected results,
exit non-zero if there are any

```
./kvm test-clean
```

```
./kvm uninstall
```

remove build and test vms, forcing a rebuild

```
./kvm clean
```

remove build and test VMs and test results, forcing a fresh build and
test run

## Combining commands

the operations can be combined on a single line:

```
./kvm test-clean install check recheck diff
```

and individual tests can be selected (see Running a Single Test, below):

```
./kvm install check diff testing/pluto/*ikev2*
```

To stop `./kvm` use control-c or `./kvm kill` from another terminal.

## Updating Certificates

The full testsuite requires a number of certificates.  If not present,
then `./kvm check` will automatically generate them using the domain
`linux`.  Just note that the certificates have a limited lifetime.
Should the test system detects out-of-date certificates then `./kvm
check` will barf.

To rebuild the certificates run:

```
./kvm keys
```
