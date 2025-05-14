#!/bin/sh

if [ -z "$QDSK_SESSION" ] ; then
  QDSK_SESSION="unknown" #fallback

  if [ -n "$( echo "$DESKTOP_SESSION" | grep -i "trinity" )" ] || [ -n "$( echo "$XDG_CURRENT_DESKTOP" | grep -i "trinity" )" ] || [ -n "$( echo "$XDG_SESSION_DESKTOP" | grep -i "trinity" )" ] ; then
    QDSK_SESSION="trinity"
  elif [ -n "$( echo "$DESKTOP_SESSION" | grep -i "plasma" )" ] || [ -n "$( echo "$XDG_CURRENT_DESKTOP" | grep -i "plasma" )" ] || [ -n "$( echo "$XDG_SESSION_DESKTOP" | grep -i "plasma" )" ] ; then
    QDSK_SESSION="plasma"
  elif [ -n "$( echo "$DESKTOP_SESSION" | grep -i "lxqt" )" ] || [ -n "$( echo "$XDG_CURRENT_DESKTOP" | grep -i "lxqt" )" ] || [ -n "$( echo "$XDG_SESSION_DESKTOP" | grep -i "lxqt" )" ] ; then
    QDSK_SESSION="lxqt"
  elif [ -n "$( echo "$DESKTOP_SESSION" | grep -i "xfce" )" ] || [ -n "$( echo "$XDG_CURRENT_DESKTOP" | grep -i "xfce" )" ] || [ -n "$( echo "$XDG_SESSION_DESKTOP" | grep -i "xfce" )" ] ; then
    QDSK_SESSION="xfce"
  elif [ -n "$( echo "$DESKTOP_SESSION" | grep -i "kde" )" ] || [ -n "$( echo "$XDG_CURRENT_DESKTOP" | grep -i "kde" )" ] || [ -n "$( echo "$XDG_SESSION_DESKTOP" | grep -i "kde" )" ] ; then
    QDSK_SESSION="plasma"
  elif [ -n "$DESKTOP_SESSION" ] ; then
    QDSK_SESSION="$DESKTOP_SESSION"
  elif [ -n "$XDG_CURRENT_DESKTOP" ] ; then
    QDSK_SESSION="$XDG_CURRENT_DESKTOP"
  elif [ -n "$XDG_SESSION_DESKTOP" ] ; then
    QDSK_SESSION="$XDG_SESSION_DESKTOP"
  else
    QDSK_SESSION="unknown"
  fi

  if [ "$QDSK_SESSION" = "default" ] ; then
    #todo: tdm sources - set some env-variable to identify desktop to log into, if “default” option is set in tdm, and modify this script accordingly
    QDSK_SESSION="unknown"
  fi
fi

echo "$QDSK_SESSION"
