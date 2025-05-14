#!/bin/sh
#performs one-shot upgrade and delete itself if cron script
#could be used as cron job, as copied into /etc/cron.xxx/

export DEBCONF_FRONTEND="noninteractive"
export DEBIAN_FRONTEND="noninteractive"
export APTG_OPT0="--allow-unauthenticated --allow-downgrades --assume-yes -o Dpkg::Options::=--force-confold"

if [ "$( id -u )" != "0" ] ; then
 echo "Only root can run, exiting ..."
 exit 20
fi

if [ -n "$( readlink -f $0 | grep "/etc/cron." )" ] ; then
  echo "Info: this script is cron job."
  IS_CRON_JOB="true"
fi

dash /usr/share/apps/q4os_system/bin/qapt_fix.sh --noninteractive
if [ "$?" != "0" ] ; then
  echo "Package system inconsistent, exiting .."
  exit 10
fi

check-apt-busy
if [ "$?" = "1" ] ; then
  echo "Package system busy, repeat a bit later .."
  exit 10
fi
apt-get --assume-yes update

check-apt-busy
if [ "$?" = "1" ] ; then
  echo "Package system busy, repeat a bit later .."
  exit 10
fi
apt-get $APTG_OPT0 dist-upgrade

check-apt-busy
if [ "$?" = "1" ] ; then
  echo "Package system busy, repeat a bit later .."
  exit 10
fi
apt-get $APTG_OPT0 autoremove

if [ -n "$IS_CRON_JOB" ] ; then echo "Removing this script: \"$0\"" ; rm $0 ; fi
exit 0
