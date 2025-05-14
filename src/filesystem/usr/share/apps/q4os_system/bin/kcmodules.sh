#!/bin/sh
# un/hide items from control panel

#----------------------------------------------------------------------------------------------
qwrite_desktop_shortcut ()
{
  local FILE="$1"
  local KEY="$2"
  local VALUE="$3"
  echo "Updating: File: $FILE ; Key: $KEY ; Value: $VALUE"
  sed -i "/^$/d" $FILE
  sed -i "/^#/d" $FILE
  sed -i "/^$2=/d" $FILE
  echo "# added by qwrite_desktop_shortcut\n$KEY=$VALUE" >> $FILE
}

#----------------------------------------------------------------------------------------------
update_ctlrpanel_entries ()
{
  qwrite_desktop_shortcut '/opt/trinity/share/applications/tde/tdm.desktop' 'Hidden' "$1"
  qwrite_desktop_shortcut '/opt/trinity/share/applications/tde/twindecoration.desktop' 'Hidden' "$1"
  qwrite_desktop_shortcut '/opt/trinity/share/applications/tde/ksplashthememgr.desktop' 'Hidden' "$1"
  qwrite_desktop_shortcut '/opt/trinity/share/applications/tde/kcmlaunch.desktop' 'Hidden' "$1"
  qwrite_desktop_shortcut '/opt/trinity/share/applications/tde/icons.desktop' 'Hidden' "$1"
  qwrite_desktop_shortcut '/opt/trinity/share/applications/tde/style.desktop' 'Hidden' "$1"
  qwrite_desktop_shortcut '/opt/trinity/share/applications/tde/kthememanager.desktop' 'Hidden' "$1"
}

#----------------------------------------------------------------------------------------------
# Script start
#----------------------------------------------------------------------------------------------
if [ "$( id -u )" != "0" ] ; then
 echo "Only root can run, exiting ..."
 exit 100
fi

if [ "$1" = "--lock" ] ; then
  ACTN="true"
fi
if [ "$1" = "--unlock" ] ; then
  ACTN="false"
fi

if [ -z "$ACTN" ] ; then
 echo "Usage1: kcmodules.sh --lock"
 echo "Usage2: kcmodules.sh --unlock"
 echo "Bad arguments, exiting ..."
 exit 110
fi

echo "Checking control panel items ..."
update_ctlrpanel_entries "$ACTN"
#tdebuildsycoca
echo " Done."
