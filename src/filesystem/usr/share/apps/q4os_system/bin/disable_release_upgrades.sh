#!/bin/sh

#this script disables upgrades between ubuntu/quarkos releases as it's not supported by quarkos

if [ ! -f "/var/lib/q4os/isquarkos.stp" ] ; then
  echo "[I] Quarkos not detected, exiting ..."
  exit
fi

if [ "$( id -u )" != "0" ] ; then
  echo "[E] This script needs root privileges, exiting ..."
  exit 10
fi

if [ -f "/etc/update-manager/release-upgrades" ] ; then
  sed -i 's/^Prompt=lts$/Prompt=never/' "/etc/update-manager/release-upgrades"
  sed -i 's/^Prompt=normal$/Prompt=never/' "/etc/update-manager/release-upgrades"
else
  mkdir -p "/etc/update-manager/"
  cat > "/etc/update-manager/release-upgrades" << EOF
# Default behavior for the release upgrader.

[DEFAULT]
# Default prompting and upgrade behavior, valid options:
#
#  never  - Never check for, or allow upgrading to, a new release.
#  normal - Check to see if a new release is available.  If more than one new
#           release is found, the release upgrader will attempt to upgrade to
#           the supported release that immediately succeeds the
#           currently-running release.
#  lts    - Check to see if a new LTS release is available.  The upgrader
#           will attempt to upgrade to the first LTS release available after
#           the currently-running one.  Note that if this option is used and
#           the currently-running release is not itself an LTS release the
#           upgrader will assume prompt was meant to be normal.
Prompt=never
EOF
fi
