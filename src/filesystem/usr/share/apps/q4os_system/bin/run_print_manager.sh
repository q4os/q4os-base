#!/bin/sh

. gettext.sh
export TEXTDOMAIN="q4os-base"

if [ "$(dash /usr/share/apps/q4os_system/bin/print_session.sh)" != "trinity" ] ; then
  echo "Trinity session not detected. Please run this tool within Trinity desktop."
  kdialog --title "Print system" --icon "printer" --msgbox "<p>$(eval_gettext "Trinity session not detected. Please run this tool within Trinity desktop.")</p>" &
  exit 10
fi

unset LIVE_MEDIA
if [ -f "/etc/q4oslivemedia" ] ; then #detect livemedia
  LIVE_MEDIA="1"
  kdialog --caption "" --title "Print system" --icon "printer" --msgbox "<p>$(eval_gettext "Live media detected. Printers management may be limited within the live media environment. It will be fully available after Q4OS installation.")</p>"
fi

PRINTSYS_OK="1"
if [ "$( /opt/trinity/bin/kreadconfig --file="q4osrc" --group="General" --key="print_system_ok" )" != "1" ] ; then
  dpkg --compare-versions "$( dash /usr/share/apps/q4os_system/bin/print_package_version.sh cups )" gt "0" #check cups
  if [ "$?" = "0" ] ; then
    /opt/trinity/bin/kwriteconfig --file="q4osrc" --group="General" --key="print_system_ok" "1"
  else
    echo "warning: print system missing !"
    PRINTSYS_OK="0"
  fi
fi

if [ "$PRINTSYS_OK" = "0" ] ; then
  kdialog --caption "" --title "Print system" --icon "printer" --msgbox "<p>$(eval_gettext "Printing subsystem is now deactivated, you need to install <b>CUPS layer and printer driver</b> first. If you want to activate printing subsystem and full set of drivers, install following packages:")</p><p><b>cups, hplip, printer-driver-all</b></p><p>$(eval_gettext "For more detailed info read Q4OS documentation at https://www.q4os.org")</p><p></p>" &
  exit 11
fi

if [ "$(passwd --status | awk -F' ' '{ print $2 }')" = "NP" ] ; then
  PSWLESS="1"
  # echo "passwordless user detected"
fi

lpstat

if [ -f "/var/lib/q4os/enable_tdeprint_manager.stp" ] ; then
  tdecmshell printers &
elif [ -f "/usr/bin/system-config-printer" ] ; then
  /usr/bin/system-config-printer &
elif [ "$PSWLESS" = "1" ] ; then
  #workaround for passwordless dialog in 'konqueror "http://$USER@localhost:631/admin"'
  #and octet-stream bug in cups webadmin, move later to 'konqueror "http://$USER@localhost:631/admin"'
  tdecmshell printers &
elif [ -f "/opt/trinity/bin/konqueror" ] ; then
  /opt/trinity/bin/konqueror "http://$USER@localhost:631/admin" &
elif [ -f "/usr/bin/xdg-open" ] ; then
  /usr/bin/xdg-open "http://$USER@localhost:631/admin" &
else
  echo "No cups interface found, falling back ..."
  konqueror "http://$USER@localhost:631/admin" &
fi
