#!/bin/sh #sourced script

echo "livemedia_localization starting ..."

WKFL1="/tmp/.geoiplookup1"
wget -T2 -t1 -qq -O- https://geoip.ubuntu.com/lookup > $WKFL1
TMZONE1="$( cat $WKFL1 | grep "TimeZone" | awk -F'<TimeZone>' '{ print $2 }' | awk -F'</TimeZone>' '{ print $1 }' )"
CTRYCODE1="$( cat $WKFL1 | grep "CountryCode" | awk -F'CountryCode' '{ print $2 }' | tr -d '<>/' )"
echo "geoip timezone detected:     $TMZONE1"
echo "geoip country code detected: $CTRYCODE1"
echo "geoip info:                  $WKFL1"

if [ -n "$TMZONE1" ] ; then
  sudo -n timedatectl set-timezone $TMZONE1
fi

if [ -n "$(cat /proc/cmdline | grep "locales=")" ] ; then
  #localization set via grub options
  if [ "$QDSK_SESSION" = "trinity" ] ; then
    pkill --signal SIGCONT qapt_lock.exu
    dash /usr/share/apps/q4os_system/bin/.addlang_ai_01.sh
    /usr/share/apps/q4os_system/bin/qapt_lock.exu --lock --sig-me &
  fi
else
  #localization hasn't been set via grub options
  if [ "$CTRYCODE1" != "US" ] && [ "$CTRYCODE1" != "GB" ] && [ "$CTRYCODE1" != "AU" ] ; then
    #show dialog to ask user for a language, preset geoip info if possible
    if [ "$QDSK_SESSION" = "trinity" ] ; then
      pkill --signal SIGCONT qapt_lock.exu
      SHOW_KD1="no" dash /usr/share/apps/q4os_system/bin/.addlang_ai_02.sh "" "$CTRYCODE1"
      /usr/share/apps/q4os_system/bin/qapt_lock.exu --lock --sig-me &
    elif [ "$QDSK_SESSION" = "plasma" ] ; then
      SHOW_KD1="no" dash /usr/share/apps/q4os_system/bin/.addlang_ai_02.sh "--only-set-locale" "$CTRYCODE1"
    fi
  fi
fi

if [ "$QDSK_SESSION" = "trinity" ] ; then
  echo "Don’t show hdd media notifier for live-installer ..."
  NOTIFRCFL1="$HOME/.trinity/share/config/medianotifierrc"
  /opt/trinity/bin/kwriteconfig --file "$NOTIFRCFL1" --group "Auto Actions" --key "media/hdd_mounted" "#NothinAction"
  /opt/trinity/bin/kwriteconfig --file "$NOTIFRCFL1" --group "Auto Actions" --key "media/hdd_unmounted" "#NothinAction"
  /opt/trinity/bin/kwriteconfig --file "$NOTIFRCFL1" --group "Auto Actions" --key "media/hdd_mounted_decrypted" "#NothinAction"
  /opt/trinity/bin/kwriteconfig --file "$NOTIFRCFL1" --group "Auto Actions" --key "media/hdd_unmounted_decrypted" "#NothinAction"
  # /opt/trinity/bin/kwriteconfig --file "$NOTIFRCFL1" --group "Auto Actions" --key "media/hdd_mounted_encrypted" "#NothinAction"
  # /opt/trinity/bin/kwriteconfig --file "$NOTIFRCFL1" --group "Auto Actions" --key "media/hdd_unmounted_encrypted" "#NothinAction"
  chmod a+r $NOTIFRCFL1
  # MEDIA_PAPLET="$HOME/.trinity/share/config/media_panelapplet_rc"
  # EXCLUDED_TYPES="$( /opt/trinity/bin/kreadconfig --file "$MEDIA_PAPLET" --group "General" --key "ExcludedTypes" )"
  # /opt/trinity/bin/kwriteconfig --file "$MEDIA_PAPLET" --group "General" --key "ExcludedTypes" "media/hdd_mounted_decrypted;media/hdd_unmounted_decrypted;$EXCLUDED_TYPES"
  # chmod a+r "$MEDIA_PAPLET"
  #need to be configured later else rewritten with the default config file
  # echo "Disable screen locking ..."
  # /opt/trinity/bin/kwriteconfig --file "$HOME/.trinity/share/config/kdesktoprc" --group "ScreenSaver" --key "Lock" "false"
  # chmod a+r $HOME/.trinity/share/config/kdesktoprc

  # echo "Don’t hide keyboard applet ..."
  # kwriteconfig --file "systemtray_panelappletrc" --group "HiddenTrayIcons" --key "Hidden" ""
fi

echo "livemedia_localization finishing ..."
