#!/bin/sh
#get the most recent version of 'linux-headers-*' and 'linux-image-*' packages
#q4os possible values: amd64, 686-pae, 686, arm64, armmp
#quark possible values: generic
#todo: potential values: rt-amd64, rt-686-pae, armmp-pae, armmp-lpae

# CARCH="$( dpkg --print-architecture )"
QAPTDISTR_A="$( dash /usr/share/apps/q4os_system/bin/print_qaptdistr.sh )"

if [ "$QAPTDISTR_A" = "bullseye" ] || [ "$QAPTDISTR_A" = "bookworm" ]  || [ "$QAPTDISTR_A" = "trixie" ] ; then
  KERNEL_TP="$( uname -r  | awk -F'-' '{ print $NF }' )"
  if [ "$KERNEL_TP" = "pae" ] ; then
    KERNEL_TP="686-pae"
  fi
  if [ "$KERNEL_TP" != "amd64" ] && [ "$KERNEL_TP" != "686-pae" ] && [ "$KERNEL_TP" != "686" ] && [ "$KERNEL_TP" != "arm64" ] && [ "$KERNEL_TP" != "armmp" ] ; then
    unset KERNEL_TP
  fi
elif [ "$QAPTDISTR_A" = "jammy" ] ; then
  KERNEL_TP="generic-hwe-22.04" #generic-hwe-22.04 | generic
elif [ "$QAPTDISTR_A" = "noble" ] ; then
  KERNEL_TP="generic-hwe-24.04" #generic-hwe-24.04 | generic
else
  unset KERNEL_TP
fi

if [ -z "$KERNEL_TP" ] ; then
  echo "unknown"
  exit "1"
fi

echo "$KERNEL_TP"
exit "0"
