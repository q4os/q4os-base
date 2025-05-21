#!/bin/sh
#compile and install libdvdcss2 using libdvd-pkg package
#this script must be strictly non-interactive as used in installers

if dash /usr/share/apps/q4os_system/bin/print_package_version.sh "libdvdcss2" > /dev/null ; then
  echo "Package\"libdvdcss2\" is installed."
  exit
fi

if [ "$( id -u )" != "0" ] ; then
  echo "Only root can run, exiting ..."
  exit 11
fi

if ! dash /usr/share/apps/q4os_system/bin/print_package_version.sh "libdvd-pkg" > /dev/null ; then
  echo "Installing \"libdvd-pkg\" package ..."
  APT_OPT0="-o DPkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold -o DPkg::Lock::Timeout=-1 --assume-yes --ignore-hold --allow-downgrades --allow-change-held-packages"
  DEBCONF_FRONTEND="noninteractive" DEBIAN_FRONTEND="noninteractive" apt-get $APT_OPT0 install libdvd-pkg
fi

if ! dash /usr/share/apps/q4os_system/bin/print_package_version.sh "libdvd-pkg" > /dev/null ; then
  echo "Error installing \"libdvd-pkg\" package, exiting ..."
  exit 12
fi

if ! check-apt-busy > /dev/null ; then
  echo "Package system is busy, waiting to release .."
  dash /usr/share/apps/q4os_system/bin/qapt_wsr.sh > /dev/null #waiting for apt safe ready
  echo " .. released."
fi

echo "Building and installing \"libdvdcss2\" ..."
DEBCONF_FRONTEND="noninteractive" DEBIAN_FRONTEND="noninteractive" dpkg-reconfigure --frontend="nonintercative" libdvd-pkg

if ! dash /usr/share/apps/q4os_system/bin/print_package_version.sh "libdvdcss2" > /dev/null ; then
  echo "Error. Build not successful, exiting ..."
  exit 13
fi
