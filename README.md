# Gitian

Read about the project goals at the "project home page":https://gitian.org/ .

This package can do a deterministic build of a package inside a VM.

## Deterministic build inside a VM

This performs a build inside a VM, with deterministic inputs and outputs.  If the build script takes care of all sources of non-determinism (mostly caused by timestamps), the result will always be the same.  This allows multiple independent verifiers to sign a binary with the assurance that it really came from the source they reviewed.

## Prerequisites:

Gentoo:

    layman -a luke-jr  # needed for vmbuilder
    sudo emerge dev-vcs/git net-misc/apt-cacher-ng app-emulation/vmbuilder dev-lang/ruby
    sudo emerge app-emulation/qemu
    export KVM=qemu-system-x86_64

Ubuntu:

    sudo apt-get install git apache2 apt-cacher-ng python-vm-builder ruby
    sudo apt-get install qemu-kvm         # for KVM mode
    sudo apt-get install debootstrap lxc  # for LXC mode

OSX with MacPorts:

    sudo port install ruby coreutils
    export PATH=$PATH:/opt/local/libexec/gnubin  # Needed for sha256sum

### VirtualBox

Install virtualbox from virtualbox.org, and make sure VBoxManage is in your $PATH.

## Create the base VM for use in further builds (requires sudo, please review the script):

### KVM

    bin/make-base-vm
    bin/make-base-vm --arch i386

### LXC

    bin/make-base-vm --lxc
    bin/make-base-vm --lxc --arch i386

Set the USE_LXC environment variable to use LXC instead of KVM:
    export USE_LXC=1

### VirtualBox

Command-line VBoxManage must be in your PATH

Setup:

make-base-vm cannot yet make VirtualBox virtual machines (patches welcome-- it should be possible to use VBoxManage, boot-from-network Linux images and PXE booting to do it). So you must either get or manually create VirtualBox machines that:

1. Are named "Gitian-<suite>-<arch>" -- e.g. Gitian-lucid-i386 for a 32-bit, Ubuntu 10 machine.
2. Have a booted-up snapshot named "Gitian-Clean" .  The build script resets the VM to that snapshot to get reproducible builds.
3. Has the VM's NAT networking setup to forward port localhost:2223 on the host machine to port 22 of the VM; e.g.:
    VBoxManage modifyvm Gitian-lucid-i386 --natpf1 "guestssh,tcp,,2223,,22"

The final setup needed is to create an ssh key that will be used to login to the virtual machine:

    ssh-keygen -t dsa -f var/id_dsa -N ""
    ssh -p 2223 ubuntu@localhost 'mkdir -p .ssh && chmod 700 .ssh && cat >> .ssh/authorized_keys' < var/id_dsa.pub
    ssh -p 2223 ubuntu@localhost
    On VM: sudo bash
    On VM: mkdir -p .ssh && chmod 700 .ssh && cat ~ubuntu/.ssh/authorized_keys >> .ssh/authorized_keys

Set the USE_VBOX environment variable to use LXC instead of KVM:
    export USE_VBOX=1

## Sanity-testing

If you have everything set-up properly, you should be able to:

PATH=$PATH:$(pwd)/libexec
make-clean-vm --suite lucid --arch i386
start-target 32 lucid-i386
on-target ls -la
stop-target

## Building

Copy any additional build inputs into a directory named _inputs_.

Then execute the build using a YAML description file (can be run as non-root):

    export USE_LXC=1 # LXC only
    bin/gbuild <package>.yml

or if you need to specify a commit for one of the git remotes:

    bin/gbuild --commit <dir>=<hash> <package>.yml

The resulting report will appear in result/\<package\>-res.yml

To sign the result, perform:

    bin/gsign --signer <signer> --release <release-name> <package>.yml

Where <signer> is your signing PGP key ID and <release-name> is the name for the current release.  This will put the result and signature in the sigs/<package>/<release-name>.  The sigs/<package> directory can be managed through git to coordinate multiple signers.

After you've merged everybody's signatures, verify them:

    bin/gverify --release <release-name> <package>.yml


## Poking around

* Log files are captured to the _var_ directory
* You can run the utilities in libexec by running `PATH="libexec:$PATH"`
* To start the target VM run `start-target 32 lucid-i386` or `start-target 64 lucid-amd64`
* To ssh into the target run `on-target` or `on-target -u root`
* On the target, the _build_ directory contains the code as it is compiled and _install_ contains intermediate libraries
* By convention, the script in \<package\>.yml starts with any environment setup you would need to manually compile things on the target

TODO:
- disable sudo in target, just in case of a hypervisor exploit
- tar and other archive timestamp setter

## LXC tips

`bin/gbuild` runs `lxc-start`, which may require root.  If you are in the admin group, you can add the following sudoers line to prevent asking for the password every time:

    %admin ALL=NOPASSWD: /usr/bin/lxc-start

Recent distributions allow lxc-start to be run by non-priviledged users, so you might be able to rip-out the `sudo` calls in `libexec/*`.

If you have a runaway `lxc-start` command, just use `kill -9` on it.

The machine configuration requires access to br0 and assumes that the host address is 10.0.2.2:

    sudo brctl addbr br0
    sudo ifconfig br0 10.0.2.2/24 up

## Tests

Not very extensive, currently.

`python -m unittest discover test`
