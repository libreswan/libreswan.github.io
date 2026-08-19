## KVM Test framework

Libreswan's test framework can be run using KVM guests, and the `./kvm`
script. The framework assumes a Linux host with virtualisation instructions.

For an overview of the network see [Topology](/Testing/Topology).

## TL;DR?

You must set up your [host system](/Testing/KVM/1.-Setup-The-Host).

But with that done, you could try:

```
git clone https://github.com/libreswan/libreswan
cd libreswan
./kvm install check testing/pluto/my-test
```

But we recommend that you go through the numbered steps.

## `./kvm`

The KVM test framework is driven using the top level script `./kvm`.

- it supports tab completion

  Add `complete -o filenames -C './kvm' ./kvm` to `.bashrc`.

- it supports sequences

  For instance `./kvm install check` is short hand for `./kvm install
  && ./kvm check`
