#!/bin/sh

if [ "$( id -u )" != "0" ] ; then
  echo "Only root can run this script, exiting ..."
  exit 10
fi

GRBENTRS="$( grep '^menuentry ' /boot/grub/grub.cfg | grep -iv 'system setup.*uefi-firmware' | wc -l )"
if [ -z "$GRBENTRS" ] ; then
  GRBENTRS="0"
fi
echo "Number of grub entries: $GRBENTRS"
if [ "$GRBENTRS" -le "1" ] ; then
  echo "Disabling grub menu ..."
  sed -i 's/^GRUB_TIMEOUT_STYLE=.*/GRUB_TIMEOUT_STYLE=hidden/' /etc/default/grub
  sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=1/' /etc/default/grub
fi
if [ "$1" = "--update-grub" ] ; then
  update-grub
fi
