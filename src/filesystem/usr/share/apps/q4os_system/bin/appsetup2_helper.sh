#!/bin/sh

if [ "$1" = "1" ] ; then
  rm -f /etc/apt/sources.list.d/tmpsetup.list
  rm -f /etc/apt/preferences.d/pin98-tmpsetup
  rm -f /etc/apt/trusted.gpg.d/tmpsetup-key*.gpg
fi

if [ "$1" = "2" ] ; then
  rm -f /etc/apt/sources.list.d/tmpsetup.list
  rm -f /etc/apt/preferences.d/pin98-tmpsetup
  rm -f /etc/apt/trusted.gpg.d/tmpsetup-key*.gpg
  CURRDIR1="$(pwd)"
  if [ -f "$CURRDIR1/tmpsetup.list" ] ; then
    ln -f -s $CURRDIR1/tmpsetup.list /etc/apt/sources.list.d/tmpsetup.list
  fi
  if [ -f "$CURRDIR1/pin-tmpsetup" ] ; then
    ln -f -s $CURRDIR1/pin-tmpsetup /etc/apt/preferences.d/pin98-tmpsetup
  fi
  if [ -f "$CURRDIR1/tmpsetup-key1.gpg" ] ; then
    ln -f -s $CURRDIR1/tmpsetup-key1.gpg /etc/apt/trusted.gpg.d/tmpsetup-key1.gpg
  fi
  if [ -f "$CURRDIR1/tmpsetup-key2.gpg" ] ; then
    ln -f -s $CURRDIR1/tmpsetup-key2.gpg /etc/apt/trusted.gpg.d/tmpsetup-key2.gpg
  fi
fi

if [ "$1" = "3" ] ; then
  dash customhook_preapt_r.esh 2>&1
fi

# if [ "$1" = "4" ] ; then
#   echo "Package found: " "$2"
# fi

if [ "$1" = "5" ] ; then
  dash $2/hkprtstp.sh 2>&1
fi

if [ "$1" = "6" ] ; then
  killall -s TERM apt-get #or pkill --signal TERM apt-get
  #killall -s ???? dpkg ; or let dpkg to finish pending operation
fi

if [ "$1" = "7" ] ; then
  kwriteconfig --file "/etc/q4os/q4base.conf" --group "DesktopProfiler" --key "needtoapply" "0"
  if [ -n "$3" ] ; then
    kwriteconfig --file "/etc/q4os/q4base.conf" --group "DesktopProfiler" --key "appliedprofile" "$3"
  fi
  if [ -z "$( kreadconfig --file "/etc/q4os/q4base.conf" --group "DesktopProfiler" --key "defaultdesktopenv" )" ] && [ -n "$2" ] ; then
    kwriteconfig --file "/etc/q4os/q4base.conf" --group "DesktopProfiler" --key "defaultdesktopenv" "$2"
  fi
  chmod a+r /etc/q4os/q4base.conf
fi

if [ "$1" = "8" ] ; then
  dash /tmp/.custom_script.sh
fi

if [ "$1" = "9" ] ; then
  dash /usr/share/apps/q4os_system/bin/qapt_fix.sh --noninteractive 2>&1
fi

if [ "$1" = "10" ] ; then
  dash customhook_preapt_r.sh 2>&1
fi

if [ "$1" = "11" ] ; then
  dash customhook_postapt1_r.sh 2>&1
fi

if [ "$1" = "12" ] ; then
  dash /usr/share/apps/q4os_system/bin/prf_add_tderepo.sh
fi

if [ "$1" = "13" ] ; then
  mkdir -p /var/lib/appsetup2/regs/
  cp "$2" "/var/lib/appsetup2/regs/"
fi

if [ "$1" = "14" ] ; then
  flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
fi

# if [ "$1" = "n" ] ; then
#   echo '/opt/trinity/bin/tdm' | tee /etc/X11/default-display-manager
#   ln -sf /lib/systemd/system/tdm.service /etc/systemd/system/display-manager.service
# fi
