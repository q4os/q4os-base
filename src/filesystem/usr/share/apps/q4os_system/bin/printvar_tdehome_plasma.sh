#!/bin/sh
#prints plasma TDEHOME directory relative to the home directory
#$1 = username, or empty for the current user

if [ -z "$1" ] && [ "$QDSK_SESSION" = "plasma" ] && [ -n "$TDEHOME" ] ; then
  echo "$TDEHOME"
  exit
fi

if [ -z "$1" ] ; then
  HOMEDIR1="$HOME"
else
  HOMEDIR1="$( getent passwd "$1" | cut -d: -f6 )"
fi
if [ ! -d "$HOMEDIR1" ] ; then
  echo "/tmp" #fallback
  exit 10
fi

TDEHOME1="$( /opt/trinity/bin/kreadconfig --file "/etc/q4os/q4base.conf" --group "General" --key "tdehome_plasma" )"
if [ -z "$TDEHOME1" ] ; then
  TDEHOME1=".trinitykde"
fi
echo "$HOMEDIR1/$TDEHOME1"
