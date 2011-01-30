# Gitian

Read about the project goals at the "project home page":https://gitian.org/ .

This package can do a deterministic build of a package inside a VM.

## Deterministic build inside a VM

This performs a build inside a VM, with deterministic inputs and outputs.  If the build script takes care of all sources of non-determinism (mostly caused by timestamps), the result will always be the same.  This allows multiple independent verifiers to sign a binary with the assurance that it really came from the source they reviewed.

## Synopsis:

Install prereqs:

    sudo apt-get install python-vm-builder qemu-kvm apt-cacher
    sudo service apt-cacher start

Create the base VM for use in further builds (requires sudo, please review the script):

    bin/make-base-vm

Copy any additional build inputs into a directory named _inputs_.

Then execute the build using a YAML description file (can be run as non-root):

    bin/gbuild <package>-desc.yml

The resulting report will appear in result/\<package\>-res.yml
