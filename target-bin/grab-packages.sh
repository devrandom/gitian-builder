#!/bin/sh

# Get an installed package manifest

set -e

cd /var/cache/apt/archives

# make sure all packages with installed versions are downloaded
dpkg-query -W -f '${Package}=${Version}\n' | xargs -n 50 apt-get install -q --reinstall -y -d > /tmp/download.log
grep "cannot be downloaded" /tmp/download.log && { echo Could not download some packages, please run gbuild --upgrade 1>&2 ; exit 1 ; }
sha256sum *.deb | sort --key 2
