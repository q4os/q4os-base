#!/bin/sh

if [ "$( id -u )" != "0" ] ; then
  echo "[E] This script needs root privileges, exiting ..."
  exit 10
fi

LOCCL="$1"
if [ -z "$LOCCL" ] ; then
  LOCCL="C.UTF-8"
  echo "[E] No locale specified, falling to locale: $LOCCL"
  dash /usr/share/apps/q4os_system/bin/dpkg_reconfigure_ni.sh "locales" "default_environment_locale" "$LOCCL"
  exit 11
fi
if [ "$LOCCL" = "C" ] ; then
  LOCCL="C.UTF-8"
  echo "Setting locale: $LOCCL"
  dash /usr/share/apps/q4os_system/bin/dpkg_reconfigure_ni.sh "locales" "default_environment_locale" "$LOCCL"
  exit
fi
if [ "$LOCCL" = "POSIX" ] ; then
  LOCCL="C.UTF-8"
  echo "Setting locale: $LOCCL"
  dash /usr/share/apps/q4os_system/bin/dpkg_reconfigure_ni.sh "locales" "default_environment_locale" "$LOCCL"
  exit
fi
if [ "$LOCCL" = "None" ] ; then
  LOCCL="C.UTF-8"
  echo "Setting locale: $LOCCL"
  dash /usr/share/apps/q4os_system/bin/dpkg_reconfigure_ni.sh "locales" "default_environment_locale" "$LOCCL"
  exit
fi
if [ "${#LOCCL}" -lt "5" ] ; then
  echo "[E] Too short locale \"$LOCCL\", not adding this to generate."
  exit 12
fi
echo "Setting locale: $LOCCL"
if [ -z "$( cat /etc/locale.gen | grep -v "^#" | grep "^$LOCCL UTF-8" )" ] ; then
  sed -i "/#\s*$LOCCL/s/#//g" /etc/locale.gen #uncomment lines with matched locale
  sed -i "/$LOCCL/s/^[ \t]*//g" /etc/locale.gen #remove leading whitespaces from that lines
  dpkg-reconfigure -fnoninteractive locales #generate locales
else
  echo "Locale already generated, continue .."
fi

if [ "$2" = "--set" ] ; then
  dash /usr/share/apps/q4os_system/bin/dpkg_reconfigure_ni.sh "locales" "default_environment_locale" "$LOCCL"
else
  dash /usr/share/apps/q4os_system/bin/dpkg_reconfigure_ni.sh "locales" "default_environment_locale" "$LANG" #in dependency of debconf cache, 'dpkg-reconfigure' could disable record in /etc/default/locale, so we need to reset it
fi
