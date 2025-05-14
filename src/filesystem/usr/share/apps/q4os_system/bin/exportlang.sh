#!/bin/sh #sourced script
#script to re-export locale variables

if [ ! -f "/etc/default/locale" ] ; then
  return
fi

for IN_LANG1 in "LANG" "LANGUAGE" "LC_ADDRESS" "LC_IDENTIFICATION" "LC_MEASUREMENT" "LC_MONETARY" "LC_NAME" "LC_NUMERIC" "LC_PAPER" "LC_TELEPHONE" "LC_TIME"
do
  ELANG1="$( cat /etc/default/locale | tr -d '"' | grep "$IN_LANG1=" | awk -F'=' '{ print $2 }' )"
  if [ -n "$ELANG1" ] ; then
    # echo "$IN_LANG1 <> $ELANG1"
    export "$IN_LANG1"="$ELANG1"
    # dbus-update-activation-environment --systemd "$IN_LANG1"
  fi
  unset ELANG1
done

#fix for the first system user login, specifially for armbian systems, as they set up some locale variables in profile.d
if [ -f "$HOME/.addlangenv.sh" ] ; then
  if [ -n "$LANGUAGE" ] && [ "$LANGUAGE" != "$LANG" ] ; then 
    export LANGUAGE="$LANG"
  fi
  if [ -n "$LC_ALL" ] ; then
    #fix not to override $LANG variables in Q4OS scripts
    #using LC_ALL is not recommended, it overrides other locale variables
    unset LC_ALL
  fi
fi
