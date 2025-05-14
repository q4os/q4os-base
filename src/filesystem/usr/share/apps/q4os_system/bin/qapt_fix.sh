#!/bin/sh

if [ "$1" = "--noninteractive" ] ; then
  export DEBCONF_FRONTEND="noninteractive"
  export DEBIAN_FRONTEND="noninteractive"
  export APTG_OPT0="--allow-unauthenticated --allow-downgrades --assume-yes -o Dpkg::Options::=--force-confold"
  export APTG_OPT1="--force-confold"
fi

#----------------------------------------------------------------------------------------------
check_pksys_fc ()
{
  local PBRK="0"
  apt-get $APTG_OPT0 check
  if [ "$?" != "0" ] ; then
    local PBRK="1"
  fi
  dpkg --audit
  if [ "$?" != "0" ] ; then
    local PBRK="1"
  fi
  return "$PBRK"
}

#----------------------------------------------------------------------------------------------
# Script start
#----------------------------------------------------------------------------------------------
if [ "$( id -u )" != "0" ] ; then
 echo "Only root can run, exiting ..."
 exit 20
fi

echo "Waiting for package system to be released .."
dash /usr/share/apps/q4os_system/bin/qapt_wsr.sh #waiting for apt safe ready
echo "Done."

check-apt-busy
if [ "$?" = "1" ] ; then
  echo "Package system busy, repeat a bit later .."
  exit 10
fi
echo "Checking package system .."

#phase 1
check_pksys_fc
if [ "$?" = "0" ] ; then
  echo "Package system ok."
  exit 0
else
  echo "Package system inconsistent, recovering ..."
  dpkg $APTG_OPT1 --configure -a
  apt-get $APTG_OPT0 -f install
fi

#phase 2
check_pksys_fc
if [ "$?" = "0" ] ; then
  echo "Package system ok."
  exit 0
else
  echo "Package system still inconsistent, recovering ..."
  apt-get --assume-yes update
  dpkg $APTG_OPT1 --configure -a
  apt-get $APTG_OPT0 -f install
fi

check_pksys_fc
if [ "$?" = "0" ] ; then
  echo "Package system ok."
  exit 0
else
  echo "Package system is in non consistent state, it has to be recovered manually."
  exit 1
fi
