#!/bin/bash
set -e

DEBIAN_FRONTEND=noninteractive apt-get --no-install-recommends -y install expect-dev parted tcl
root_partno=$(perl -nle 'm[^/dev/vda(\d+)\s+/\s]&&print $1' /proc/mounts)
# TODO: Delete all swap and use space
{ cat <<EOF; sleep 1; while pidof parted; do sleep 1; done; } | unbuffer -p parted /dev/vda
resizepart Fix ${root_partno} yes 100%
quit
EOF
resize2fs /dev/vda${root_partno}
