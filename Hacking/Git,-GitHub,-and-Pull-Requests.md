Libreswan accepts patches using [Pull
Requests](https://github.com/libreswan/libreswan/pulls) on
[GitHub](https://www.github.com/libreswan/libreswan/)
(the real action happens elsewhere).

This is an overview of how the whole process can work.

_If you're a GSoC candidate and are still getting familiar with the
nuances of Git and GitHub, this hopefully helps._

_If you're just looking for a `git` crib-sheet then this is the wrong
place._

_If you're already familiar with `git` then this, again, is the wrong
place._

## Set Your Self Up

- if you can, install `pretty-git-prompt`

  In the example, .bashrc contains something like:

  ```
  export PS1="[\u@\h \W \$(pretty-git-prompt)]\\$ "
  ```

- create an account on [GitHub](https://www.github.com/) and,
  from there, create a clone of
  [Libreswan](https://github.com/libreswan/libreswan/)

  + if you haven't, set up an SSH key for your account

  Lets call the account `HANDLE`

- clone your repo onto your development machine

  ```
  $ git clone git@github.com/HANDLE/libreswan
  $ cd libreswan
  [libreswan main]$
  ```

  to fetch updates from this repo, use:

  ```
  [libreswan main]$ git fetch origin
  ```

- add a _remote_ pointing back at the public libreswan repo

  ```
  [libreswan main]$ git remote add libreswan git@github.com:libreswan/libreswan
  ```

  to update from this repo use:

  ```
  [libreswan main]$ git fetch libreswan
  ```

- to update your local repo and push it upstream:

  ```
  [libreswan main]$ git fetch libreswan
  [libreswan main]$ git rebase libreswan/main
  [libreswan main]$ git push
  ```

Being able to access both your personal repo, and the official repo
locally makes life easier (and avoids a fight with GitHub).

_The astute reader will note that this page is a `git pull` free
zone._

## Create Your Draft Pull Request

Branches are _your call_, but lets assume you create one.

_We find creating a separate local build tree and branch for each
problem is easier then a single build tree with lots of branches._

- look through [Programming Conventions](/Hacking/Programming-Conventions)

- create a branch

  Lets assume you're working on bug 555, and you like booring names.
  After creating the branch it is rebased so it is up-to-date with
  mainline.

  ```
  [libreswan main]$ git checkout -b 555 main
  [libreswan 555]$ git fetch libreswan
  [libreswan 555]$ git rebase libreswan/main
  [libreswan 555]$ git push --set-upstream origin 555
  ```

- hack away

  At this point, the number of commits doesn't matter; things will be
  cleaned up later.

The result may look like:

```
.---MAIN-
 \
  `-HACK-TEST-TEST-HACK-... <- your local changes
```

If you're looking for early feedback, consider creating a Draft Pull
Request.

## Clean up your changes

Your final pull-request should be something that you're proud of; and
not a long series of embarrassing fixes to one line of code.

But before you start, push your changes to your local repo so you've a
backup.

In the following, these commands:
```
git push
git rebase -i
gitk
git reset HEAD^
```

are all your friends.  Get friendly; and if you like using something
like `code` get friendly with that.

While reviewing your changes, here are some things to consider:

### Get Your Changes Organized

For an initial small pull-request, up to three commits are common.  In
no specific order:

- code changes

  Small repeated changes should be squashed together.

  What is especially frustrating for a reviewer is an initial change,
  and then a series of fixes to a single piece of code - it makes
  reviewing impossible.

  On the other hand, a series of similar separate changes, provided
  they build and work, probably won't get a raised eyebrow.  Just
  mention the rationale in the pull-request.

  _To be specific, when moving the whack structure fields to an array,
  the changes were made incrementally.  This is because the changes
  proved fragile (unexpected things broke), so being able to changes
  individually proved prudent._

- documentation changes

  In larger projects (yes Libreswan is anything but large), it's
  common for documentation and code be reviewed separately.  Hence we
  encourage the habit of keeping the two separate.

- testsuite changes

  Testsuite changes can often be huge, mechanical and distracting.
  Hence, we ask that the testsuite changes be kept separate.

  Don't forget to update (and yes, that includes the reviewer):

  + `TESTLIST` - the test is `good`
  + `description.txt` - keep it up-to-date

As things get more ambitious the pull-request will contain more
commits.

The command sequence:
```
git fetch libreswan
git rebase -i libreswan/main
```
is useful here.

### Cleanup The Commit Messages

First ask yourself, would the commit message be better served as a
comment in the code?

- someone reading the code will appreciate background text

- someone reading the change logs will appreicate what was changed and
  the bugs it fixed

Commits tend to look like:

```
ikev2: add option ...

Rough idea of what this does.

close #BUG1 bug subject line
see #BUG2 other bug subject line
```

or

```
testing: add my-new-test
```

or

```
documentation: document "option" in ipsec.conf
```

### Look for other tweaks

- should commits be split?

  For instance: we like to keep the following separate:

  + `testsuite/` changes; they swamp everything else
  + `lib/` additions with their tests in `testing/programs`
  + `programs/` changes

  Here's one method, using `git reset`.
  changes; and library + testing/programs changes separate to
  programs/pluto changes

  ```
  [libreswan 555]$ git push # make a backup
  [libreswan 555]$ git reset --soft HEAD^
  [libreswan 555]$ git status
  testing/pluto/TESTLIST
  testing/pluto/basic-pluto-01/description.txt
  programs/pluto/plutomain.c
  [libreswan 555]$ git commit programs/pluto/plutomain.c
  ...
  [libreswan 555]$ git commit testing/pluto/
  ...
  [libreswan 555]$ git status
  [libreswan 555]$ # git push --force
  ```

  _The astute reader will note that, contrary to test-first-dogma, the
  testsuite changes were put after the code changes.  We're not
  fussed._

- should commits be re-ordered?

  For instance, a series of commits that eacn need testsuite changes
  could be be interspersed with the testsuite changes.

  We're telling a story and sometimes the story reads better when
  told a different way.

  `git rebase -i` helps here

- should I rebase?

  Perhaps?  Especially when the branch is getting old, or
  there's stuff in mainline that will affect your code.

  Just remember that a rebase will invalidate testing;
  **and a rebase is not a merge**.  To get specific:

  ```
  [libreswan 555↑2]$ git fetch libreswan
  [libreswan 555↑2]$ git rebase libreswan/main
  [libreswan 555↑120]$
  ```

- should mainline be merged into the branch?

  **NO**

  The result is a tangled mess.

  (There's probably an exception for long lived GSoC branches, which
  need all changes to be on a single branch, but lets ignore that for
  now).

- should a value statement, framing this "Enterprise Ready" holistic
  work ensuring an end-to-end mission statement using strategic
  pillars, be included?

  Er, NO!

- confirm all the commits build

  Of course, it isn't always possible, explain that in the Pull
  Request.

- test the final commit

  We're not asking that you run the full testsuite or even an
  individual test; however doing that will likely help everyone.

  Testing earlier commits can also help.

## Create that Pull Request:

- the subject will likely be copy/pasted into the Merge line

- the description will likely be copy/pasted into the Merge's description

- be sure to address the question "how was this tested"

## I've got feedback

Here are some common cases:

- tweak the code

  make the changes to the top of your branch but then
  use `rebase -i` or some such to combine them with
  the original code

- rebase

  ```
  git fetch libreswan
  git rebase libreswan/main
  ```

  there's a chance things go north, when that happens `git rebase
  --abort` helps; and remember the original work is still upstream in
  case recovery is needed.

## What happens next

Things will now look something like:

```
         .-FIX-.
        /       \
  .---MAIN-MAIN-MAIN-...
   \
    `-CODE-TEST-DOCS... <- your branch
```

Once it's reviewed and OK, it will be merged using command line tools.
The result is:

```
         .-FIX-.
        /       \
  .---MAIN-MAIN-MAIN-Merge:
   \                  /
    `-CODE-TEST------'
```

or even:

```
  .------------------Merge:
   \                  /
    `-CODE-TEST-DOCS-'
```

- it isn't fast forwarded

- it isn't squashed

- the branch point, merge point, and last branch commit should all
  have good test results

  Nightly loves to find and test branch and merge points!

For what really happens see [Merging GitHub Pull
Requests](/Hacking/Merging-GitHub-Pull-Requests).

## Reverting

Revert (your changes) early.  Revert (your changes) often.

## Further reading:

- learn about the
  [Foxtrot](https://www.atlassian.com/blog/it-teams/stop-foxtrots-now)
  merge and other ways to tie your repo in knots

  Our repo should block them, but better to get head.
