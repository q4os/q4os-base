#!/bin/sh

unset LC_ALL
export LANG="C"

if [ -z "$1" ] ; then
  exit 10
fi

EXIT_CODE="0"
if [ -n "$( LANG="C" dpkg -s "$1" 2>&1 | grep -i '^status: deinstall' )" ] ; then
  VERS1="0"
  EXIT_CODE="20"
elif [ -n "$( LANG="C" dpkg -s "$1" 2>&1 | grep -i '^status: install ok config-files' )" ] ; then
  VERS1="0"
  EXIT_CODE="22"
elif [ -n "$( LANG="C" dpkg -s "$1" 2>&1 | grep -i '^status: install ok unpacked' )" ] ; then
  # VERS1=""
  EXIT_CODE="50"
elif [ -n "$( LANG="C" dpkg -s "$1" 2>&1 | grep -i '^status: install ok half-configured' )" ] ; then
  # VERS1=""
  EXIT_CODE="51"
elif [ -z "$( LANG="C" dpkg -s "$1" 2>&1 | grep -i '^status: install ok installed' )" ] ; then
  VERS1="0"
  EXIT_CODE="30"
fi

if [ -z "$VERS1" ] ; then
  VERS1="$( LANG="C" dpkg -s "$1" 2>&1 | grep -i '^version: ' | grep -vi "\-version" | head -n1 | awk '{ print $2 }' )"
fi
if [ -z "$VERS1" ] ; then
  VERS1="0"
  EXIT_CODE="100"
fi

echo "$VERS1"
exit "$EXIT_CODE"
