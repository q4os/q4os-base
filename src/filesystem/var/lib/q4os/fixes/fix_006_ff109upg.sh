#!/bin/sh

#this script fixes a weird bug for firefox release
#firefox needs to be fully removed and installed again after 108->109 upgrade, otherwise language pack sideloading fails

if [ "$( id -u )" != "0" ] ; then
 echo "Only root can run, exiting ..."
 exit 10
fi

if [ ! -f "/etc/firefox/syspref.js" ] ; then
 #checking, if firefox is upgraded
 echo "Previous Firefox version not detected, this doesn't look like an upgrade, exiting ..."
 exit
fi

if [ -f "/var/lib/q4os/ff109upgrade.stp" ] ; then
 echo "Firefox already fixed, exiting ..."
 exit
fi

echo "Waiting for package system to be released .."
dash /usr/share/apps/q4os_system/bin/qapt_wsr.sh "3" "3" #waiting for apt safe ready

if dpkg --compare-versions "$( dash /usr/share/apps/q4os_system/bin/print_package_version.sh "firefox" )" lt "109" ; then
 echo "Firefox hasn't been upgraded yet, exiting ..."
 exit
fi

apt-get -y update
dpkg --force-all --remove firefox
apt-get -y -f install
dash /usr/share/apps/q4os_system/bin/qapt_fix.sh "--noninteractive"
touch "/var/lib/q4os/ff109upgrade.stp"
