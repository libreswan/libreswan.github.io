Since running the testsuite can take significant time, it is often
convenient to run it in the background, or on a dedicated machine.

#### To run the tests in the background

To run the testsuite in a background run:

```
./kvm nohup install check
```

once the process has detached, `tail -f nohup.out` will be used to
display output.

This can be stopped using cntrl-c at any time.

`./kvm nohup` is just a short cut for:

```
nohup ./kvm check & sleep 1
tail -f nohup.out
```

#### To determine if the testsuite is still running

```
./kvm status
```

#### To stop the testsuite

```
./kvm kill
```
