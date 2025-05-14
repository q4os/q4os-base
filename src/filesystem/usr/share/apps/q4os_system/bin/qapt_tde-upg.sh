#!/bin/sh
#helper script for Trinity upgrade, to be called from postinst on q4os-base upgrade

#$1 .. name for marking stamp
#$2 .. tde version to upgrade to
#$3 .. notify user about the tde upgrade <true|false>

SSTAMP="/var/lib/q4os/qtde_upgrade_$1.stamp"
if [ -f "$SSTAMP" ] ; then #detect this script has been applied yet
  echo "$0 has been applied yet, no action, exiting ..."
  exit
fi

if [ -z "$2" ] ; then
  echo "Missing arguments, exiting ..."
  exit
fi

echo "Waiting for package system to be released .."
dash /usr/share/apps/q4os_system/bin/qapt_wsr.sh #waiting for apt to be safe ready
echo "Released."

if dpkg --compare-versions "$( dash /usr/share/apps/q4os_system/bin/print_package_version.sh "tdebase-trinity-bin" )" lt "$2" ; then
  echo "TDE hasn't been upgraded, exiting ..."
  exit
else
  echo "Ok, TDE has been upgraded, continue."
fi

echo "Refreshing Q4OS, as TDE has been upgraded ..."
cd /opt/trinity/share/applications/tde
# sed -i 's@^Categories=.*@Categories=Qt;TDE;System;@' kjobviewer.desktop
# sed -i 's@^Categories=.*@Categories=Qt;TDE;System;Applet;@' tdenetworkmanager.desktop
#sed -i 's@^OnlyShowIn=.*@OnlyShowIn=@' Home.desktop #do not show in accessories submenus
sed -i 's@^Categories=.*@Categories=Qt;TDE;System;@' kmix.desktop
rm -rf /.trinity #glitch: kwriteconfig makes this directory to rootfs, remove it; probably TDEHOME=/root must be set for kwriteconfig to fix the glitch
# kcmodules --lock

# echo "Updating grub config files" #update grub to show new q4os version in boot menu
# update-grub && true

FUSRNAME="$( dash /usr/share/apps/q4os_system/bin/get_first_user.sh --name )"
if [ "$3" = "true" ] && dash /usr/share/apps/q4os_system/bin/print_package_version.sh "q4os-desktop-trinity" ; then
  QAPDIST="$( dash /usr/share/apps/q4os_system/bin/print_qaptdistr.sh )"
  if [ "$QAPDIST" = "bullseye" ] ; then
    Q4RLS="Gemini"
  elif [ "$QAPDIST" = "bookworm" ] ; then
    Q4RLS="Aquarius"
  elif [ "$QAPDIST" = "trixie" ] ; then
    Q4RLS="Andromeda"
  elif [ "$QAPDIST" = "focal" ] ; then
    Q4RLS="Focal"
  elif [ "$QAPDIST" = "jammy" ] ; then
    Q4RLS="Jammy"
  elif [ "$QAPDIST" = "noble" ] ; then
    Q4RLS="Noble"
  fi
  echo "Adding TDE startup notification ..."
  sudo -n -u $FUSRNAME mkdir -p "/home/$FUSRNAME/.trinity/Autostart/"
  AUTORUNSCR="/home/$FUSRNAME/.trinity/Autostart/msginfo1.sh"
  echo "kdialog --caption \"\" --title \"System update\" --icon q4oslogo2 --msgbox \"<p><b>Q4OS $(get-q4os-version) $Q4RLS</b></p><p>Trinity desktop has been upgraded to version <b>$2</b>.</p>\" &" > $AUTORUNSCR
  echo "rm -f $AUTORUNSCR" >> $AUTORUNSCR
  chmod a+rwx $AUTORUNSCR
fi
if [ -d "/home/$FUSRNAME/.local/share/q4os/log/" ] ; then
  echo "Copying logfile ..."
  sudo -n -u $FUSRNAME cp /tmp/.qapttdeupgrade.log /home/$FUSRNAME/.local/share/q4os/log/qapttdeupgrade_$( date +%Y-%m-%d-%H-%M-%S ).log
fi

mkdir -p $( dirname "$SSTAMP" ) ; touch "$SSTAMP"

echo "Script finished."
exit 0
