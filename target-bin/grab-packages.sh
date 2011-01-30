#!/bin/sh

# Get an installed package manifest

set -e

cd /var/cache/apt/archives

#apt-get clean

dpkg-query -W -f '${Package}\n' | xargs -n 50 apt-get install --reinstall -y -d  > /dev/null
sha256sum *.deb | sort --key 2
