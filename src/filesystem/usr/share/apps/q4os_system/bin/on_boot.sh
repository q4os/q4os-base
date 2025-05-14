#!/bin/sh

if [ -f "/tmp/.q4os_on_boot_script_done.stp" ] ; then
  echo "Script already ran, exiting ..."
  exit
fi

echo "Running hooks ..."
for SCRPT1 in /usr/share/apps/q4os_system/bhooks/bhook3_*.sh ; do
  if [ -f "$SCRPT1" ] ; then
    echo "Sourcing sript ... $SCRPT1"
    . $SCRPT1
  fi
done
echo "Finished hooks ..."

echo "Acquire dmesg messages for q4hw-info script .."
DMESG_HELPER_FL0="/tmp/.dmsglgf_sys_0.tmp"
LANG="C" dmesg > "$DMESG_HELPER_FL0"
chmod a+r "$DMESG_HELPER_FL0"

touch "/tmp/.q4os_on_boot_script_done.stp"
journalctl --no-pager -u on_boot.service -all > /var/log/onbootsrv.log
