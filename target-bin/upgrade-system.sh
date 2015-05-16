#!/bin/sh

# Upgrade system

set -e

mkdir -p /var/cache/gitian

# remove obsolete grub, it causes package dependency issues
apt-get -q -y purge grub > /dev/null 2>&1 || true

# prevent upgrade of grub-pc, it fails to find a boot drive in lxc containers
echo grub-pc hold | dpkg --set-selections || true

# upgrade packages
DEBIAN_FRONTEND=noninteractive apt-get -y dist-upgrade > /dev/null > /var/cache/gitian/upgrade.log 2>&1

touch /var/cache/gitian/initial-upgrade
