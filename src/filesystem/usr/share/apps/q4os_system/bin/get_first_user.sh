#!/bin/sh

if [ -f "/etc/q4oslivemedia" ] && [ -n "$( uname -a | grep -i "ubuntu" )" ] ; then
  F1U_ID="$( getent passwd 2>/dev/null | grep -i "live session user" | grep "^ubuntu:\|^kubuntu:\|^lubuntu:\|^quarkos:\|^adminq:" | tail -n1 | awk -F':' '{ print $3 }' )"
  if [ -z "$F1U_ID" ] ; then
    F1U_ID="$( getent passwd 2>/dev/null | grep ":999:\|:1000:" | grep "^ubuntu:\|^kubuntu:\|^lubuntu:\|^quarkos:\|^adminq:" | head -n1 | awk -F':' '{ print $3 }' )"
  fi
fi
if [ -z "$F1U_ID" ] ; then
  F1U_ID="$( cat /etc/login.defs 2>/dev/null | grep "^UID_MIN" | awk -F' ' '{ print $2 }' | head -n1 )"
fi
if [ -z "$F1U_ID" ] ; then
  F1U_ID="$( cat /etc/adduser.conf 2>/dev/null | grep "^FIRST_UID=" | awk -F'=' '{ print $2 }' | head -n1 )"
fi
if [ -z "$F1U_ID" ] ; then
  F1U_ID="1000"
fi

FUSER1="$( getent passwd "$F1U_ID" 2>/dev/null )"
if [ "$?" != "0" ] || [ -z "$FUSER1" ] ; then
  exit 10
fi

if [ "$1" = "--name" ] ; then
  echo "$FUSER1" | awk -F':' '{ print $1 }'
elif [ "$1" = "--id" ] ; then
  echo "$FUSER1" | awk -F':' '{ print $3 }'
elif [ "$1" = "--group" ] ; then
  echo "$FUSER1" | awk -F':' '{ print $4 }'
else
  echo "firstuser:$FUSER1"
fi
