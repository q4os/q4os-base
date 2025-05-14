#!/bin/sh
#prints trinity XDG_CONFIG_HOME directory for a user
#$1 = username, or empty for the current user

if [ -z "$1" ] && [ "$QDSK_SESSION" = "trinity" ] && [ -n "$XDG_CONFIG_HOME" ] ; then
  echo "$XDG_CONFIG_HOME"
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

XDGCFGHOME1="$( /opt/trinity/bin/kreadconfig --file "/etc/q4os/q4base.conf" --group "General" --key "xdgcfghome_trinity" )"
if [ -z "$XDGCFGHOME1" ] ; then
  XDGCFGHOME1=".config"
fi
echo "$HOMEDIR1/$XDGCFGHOME1"
