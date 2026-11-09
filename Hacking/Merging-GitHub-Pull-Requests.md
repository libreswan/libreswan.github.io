<!-- file-is-title -->

Note: this is written from the POV of merging a contributors changes.  But the same applies when merging your own changes.

## Why Merge?

The goals are:

- preserve history

  Specifically, the branch that was fully tested before the merge.

- keep mainline's test results stable

  The testsuite and code changes appear on mainline as a single commit.

- keep bisect working

  Since mainline's test results are stable.

- keep GitHub happy

  GitHub recognizes a clean merge, auto-closing the Pull-Request and related bugs.

For instance, given:
```
       .- [PULL] --> TESTS -> CODE -> DOCS    <-- TESTSUITE PASSES
      /
... u0 -- [main] -> OTHER -> STUFF            <-- TESTSUITE PASSES
```
Then after the merge:
```
       .- [PULL-REQUEST] -> CODE -> TESTS -> DOCS       <-- PASSES
      /                                          \  
... u0 -- [main] -> OTHER -> STUFF -> [PASSES]   MERGE  <-- SHOULD PASS
```
The the branch, pre-merge commit and merge are all available for testing.

Since a rebase puts the test and code changes directly into mainline that no longer holds:
```
... u0 -- [main] -> OTHER -> STUFF 
                                  \
                                   TESTS      <- BREAKS TESTSUITE
                                    \
                                     CODE     <- FIXES TESTSUITE
                                      \
                                       DOCS   <- FIXES TESTSUITE
```

## What Not To Do

- **do not follow GitHub's instructions**

  Those instructions say to branch mainline and then
  pull the changes onto it.  That just seems to create a mess.

- **do not cherry-pick**

  GitHub gets confused by this, refusing to mark the pull-request
  as merged.

- **do not rebase**

  It looses history.

  GitHub gets confused by this, refusing to mark the pull-request
  as merged.

## The Setup

The notes below were made with a fresh repo set up as described below.
With so many pull-requests to deal with, occasionally starting with a
clean slate helps.

If you haven't already, I strongly recommend installing and using
`pretty-git-prompt` (this seems to be missing on Debian?).

```
sudo dnf install pretty-git-prompt
```
```
$ grep PS1 ~/.bashrc
export PS1="[\u@\h \W \$(pretty-git-prompt)]\\$ "
```

Now set up an empty repo and import libreswan:

```
mkdir git-hub
cd git-hub
git init
git remote add libreswan ...
git fetch libreswan
git checkout main
```

## Getting the `${HANDLE}` and `${BRANCH}`

At the bottom of the pull request `View command line instructions`.
From there get the GitHub `HANDLE` and `BRANCH` (it's assumed
`HANDLE`'s repo is called `libreswan.git`.  They will be used below
(I'd not bother setting these up as variables, they are too short
lived).

## Fetch the branch

```
[main]$ git remote add ${HANDLE} git@github.com:${HANDLE}/libreswan.git
[main]$ git fetch ${HANDLE}
```

At this point, it's probably a good idea to run tests.

## Merge the branch

Lets assume the branch is 100% tested and complete.
It involves the following steps:

1. Create the Merge
1. Cleanup the Merge
1. Push

### Create The Merge

```
[${BRANCH}]$ git checkout main
[main]$ git merge --no-ff ${HANDLE}/${BRANCH}
[main ^NNN]$ make -j
[main ^NNN]$ ./kvm test-clean install check
```

- `--no-ff` to stop it being squashed

  by not squashing the merge the original branch point is preserved;
  this will make tracking down regressions easier

- if there are merge conflicts consider aborting the merge

  + ask the submitter to rebase?

  + rebase yourself

  the merge can be thrown away with `git merge --abort` or `git reset --hard @{u}`

### Cleanup The Merge

```
[main]$ git commit --signoff --amend --author 'get it from a branch commit'
```

- `--signoff` you're the one certifying it is all tested

- `--author`, this gives the contributor credit

  don't worry, GIT preserves you as the COMMITTER

- at the top, add a meaningful subject line

  ```
  Merge _meaningful subject line_
  ```

  If possible, use the subject line from the pull-request
  (the pull-request instructions tell the submitter to write
  a usable subject; a crappy subject is a sign of AI).

- below the subject line, add a meaningful description

  If possible, use the description from the pull request
  (the pull-request instructions tell the submitter to write
  a usable description; a crappy subject is a sign of AI).

- list (update) fixed bugs in full

  List fixed bugs, **include the subject** so that the commit is
  self-contained:

  ```
  fix #NNN description of bug
  ```

- leave `Merge ${HANDLE}/${BRANCH}` at bottom

- consider tweaking CHANGES (or as follow up commit)

Re-test?

### Push

But first check over the results.

```
[main]$ gitk
[main]$ git push
```

## Alternatives

### The rebase merge.

Who knew.  GitHub lets us push to pull-request branches!

If the pull-request be getting stale, or you see that some tweaking is
needed, consider first rebasing:

- create a remote tracking branch

  ```
  [main]$ git fetch ${HANDLE}
  [main]$ git checkout ${BRANCH}
  ```

- give ${HANDLE} a heads up

  You're about to scribble all over their pull-request branch.

- rebase

  ```
  [${BRANCH}]$ git fetch libreswan        # i.e., true upstream
  [${BRANCH}]$ git rebase libreswan/main  # i.e., put ${BRANCH} on top
  [${BRANCH} ^NNvMM]$ git push --force    # yes, we can do this!
  [${BRANCH}]$
  ```

- merge

  ```
  [${BRANCH}]$ git checkout main
  [main]$ git merge --no-ff ${HANDLE}/${BRANCH}
  ```

now continue with the cleanup above

## Developers

Since developers can commit directly to the repo they're afforded some leeway.

### Standalone changes don't tend to be merged

For instance:

- documentation tweaks
- testsuite tweaks
- build fixes

but this doesn't apply to pull-requests or more substantive changes.

### Want to Live on the Edge?

See [Bubble Merging](https://stackoverflow.com/questions/79577497/merging-local-mainline-changes-into-upstream-mainline).
