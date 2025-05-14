#!/bin/sh
# doublecheck apt is ready

#$1 .. delay for basic check, default 6 sec
#$2 .. delay for confirmation check, default 8 sec

# safe_ready function - wait for apt is not busy
apt_safe_ready () {
  local TIMER1="$1"
  local TIMER2="$2"
  while [ -z "$ABUSY" ] ; do
    unset ABUSY
    check-apt-busy
    if [ "$?" = "0" ] ; then
      echo "Seems ready, will be checked once more."
      sleep $TIMER2
      check-apt-busy
      if [ "$?" = "0" ] ; then
        local ABUSY="ready"
        echo "Now safe ready."
      fi
    else
      echo "Not ready, waiting."
      sleep $TIMER1
    fi
  done
  return 0
}

# script start
TMR1="$1"
if [ -z "$TMR1" ] ; then
  TMR1="6"
fi
TMR2="$2"
if [ -z "$TMR2" ] ; then
  TMR2="8"
fi
apt_safe_ready "$TMR1" "$TMR2"
