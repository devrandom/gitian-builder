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

or if you need to specify a commit for one of the git remotes:

    bin/gbuild --commit <dir>=<hash> <package>-desc.yml

The resulting report will appear in result/\<package\>-res.yml

## Poking around

* Log files are captured to the _var_ directory
* You can run the utilities in libexec by running `PATH="libexec:$PATH"`
* To start the target VM run `start-target 32 lucid-i386` or `start-target 64 lucid-amd64`
* To ssh into the target run `on-target` or `on-target -u root`
* On the target, the _build_ directory contains the code as it is compiled and _install_ contains intermediate libraries
* By convention, the script in \<package\>-desc.yml starts with any environment setup you would need to manually compile things on the target

TODO:
- disable sudo in target, just in case of a hypervisor exploit
- tar and other archive timestamp setter
