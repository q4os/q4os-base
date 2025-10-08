#!/bin/sh

deactivate_this () {
  echo "Disabling this script to run for good ..."
  sudo -n rm -f /usr/share/wayland-sessions/plasma.desktop
  sudo -n dpkg-divert --rename --remove /usr/share/wayland-sessions/plasma.desktop
  sudo -n rm -f /etc/sudoers.d/90_sudo_tmp01 #remove temporary passwordless config
  kwriteconfig --file "$HOME/.local/share/q4os/.frstlogq4.stp" --group "install" --key "timestamp" "$( date +%Y-%m-%d-%H-%M-%S )"
  kwriteconfig --file "$HOME/.local/share/q4os/.frstlogq4.stp" --group "install" --key "desc" "do_not_delete_this_file"
}

deinit1 () {
  echo "Deinitialization of environment ..."

  pkill --signal SIGCONT qapt_lock.exu

  if ps -ef | grep -v 'grep' | grep -q 'twin' ; then
    echo "Stopping Twin window manager ..."
    $TDEDIR/bin/dcopquit twin
    # rm -f "$TWINRCTMPCFG"
  fi
  if ps -ef | grep -v 'grep' | grep -q 'kwin' ; then
    echo "Stopping Kwin window manager ..."
    pkill kwin_wayland
    pkill kwin
    killall -sKILL kwin_wayland
  fi
  $TDEDIR/bin/artsshell -q terminate
  $TDEDIR/bin/dcopserver_shutdown --wait
  export PATH="$ORIG_PATH"
  export XDG_CONFIG_DIRS="$ORIG_XDG_CONFIG_DIRS"
  unset ORIG_PATH
  unset ORIG_XDG_CONFIG_DIRS
  unset ROOTXAUTH1
  unset SYSTEM_INSTALL
  unset TEXTDOMAIN
  # unset XDG_CONFIG_HOME

  if [ -n "$WAYLAND_DISPLAY" ] ; then
    echo "Reverting back window decorations ..."
    kwriteconfig6 --file "kwinrc" --group "org.kde.kdecoration2" --key "ButtonsOnLeft" --delete
    kwriteconfig6 --file "kwinrc" --group "org.kde.kdecoration2" --key "ButtonsOnRight" --delete
  fi

  echo "\n>> $SRCFNAME1 almost finished: $( date +%Y-%m-%d-%H-%M-%S ) <<"

  local ACTION1="$1"
  if [ "$ACTION1" = "--reboot" ] ; then
    echo "Rebooting ..."
    systemctl reboot
    sleep 20 #necessary for login process not to continue
  elif [ "$ACTION1" = "--restartx" ] ; then
    echo "Rebooting ..."
    systemctl reboot #todo: restart xserver instead of reboot
    sleep 20 #necessary for login process not to continue
  elif [ "$ACTION1" = "--logout" ] ; then
    echo "Logout ..."
    loginctl terminate-user "$ACTIVE_USER"
    sleep 20 #necessary for login process not to continue
  elif [ "$ACTION1" = "--continue-session" ] ; then
    echo "Continue session ..."
    if [ "$XDG_SESSION_TYPE" = "wayland" ] && [ -f "/usr/bin/startplasma-wayland" ] ; then
      # pkill -f xdg-desktop-portal-kde
      # pkill -f xdg-desktop-portal-gtk
      # pkill xdg-*
      # echo "[dbg:]listing_processes:" ; ps -ef ; echo "[dbg:]----listing_processes_finished----"
      rm -f $XAUTHORITY
      unset XDG_SESSION_CLASS
      unset QT_QPA_PLATFORMTHEME
      unset XAUTHORITY
      unset DISPLAY
      unset WAYLAND_DISPLAY
      echo "Running Plasma Wayland ..."
      startplasma-wayland 2>/dev/null 1>/dev/null
      # /usr/lib/x86_64-linux-gnu/libexec/plasma-dbus-run-session-if-needed /usr/bin/startplasma-wayland
    fi
  fi
}

# --------------------
# --- script start ---
# --------------------
if [ -f "$HOME/.local/share/q4os/.frstlogq4.stp" ] ; then
  deactivate_this
  exit
fi

. gettext.sh
export TEXTDOMAIN="q4os-base"

SRCFNAME1="$( basename "$0" )"
START_DT="$( date +%Y-%m-%d-%H-%M-%S )"
LOGT_FILE="$HOME/.local/share/q4os/log/${SRCFNAME1}_$START_DT.log"
mkdir -p "$( dirname "$LOGT_FILE" )"

( (
echo "\n>> Q4OS $SRCFNAME1 started: $START_DT <<"

export ORIG_PATH="$PATH"
export PATH="/opt/trinity/bin:$PATH"
export ORIG_XDG_CONFIG_DIRS="$XDG_CONFIG_DIRS"
export XDG_CONFIG_DIRS="/opt/trinity/etc/xdg:/etc/xdg:$XDG_CONFIG_DIRS"
export XDG_SESSION_CLASS="user"
export TDEDIR="/opt/trinity"

QDSK_SESSION="$( dash /usr/share/apps/q4os_system/bin/print_session.sh )"
#workaround for trinity, as tdm doesn't set variables to identify session
#remove as fixed in tdm by upstream
if [ "$QDSK_SESSION" = "unknown" ] ; then
  if ps -ef | grep -v 'grep' | grep -q '/opt/trinity/bin/tdm' ; then
    QDSK_SESSION="trinity"
    echo "Setting session variable to \"trinity\" as a workaround."
  fi
fi
export QDSK_SESSION
echo "Session: $QDSK_SESSION"

ACTIVE_USER="$( whoami )"
FIRST_USER="$( dash /usr/share/apps/q4os_system/bin/get_first_user.sh --name )"
echo "First user: $FIRST_USER"
echo "Active user: $ACTIVE_USER"
if [ "$ACTIVE_USER" = "$FIRST_USER" ] || [ -f "/etc/sudoers.d/90_sudo_tmp01" ] ; then
  /usr/share/apps/q4os_system/bin/qapt_lock.exu --lock --sig-me &
  export SYSTEM_INSTALL="$( kreadconfig --file "/etc/q4os/q4base.conf" --group "OnInstall" --key "install_type" )"
  if [ -f "$XAUTHORITY" ] ; then
    cp $XAUTHORITY /tmp/.wkrootxauth
  elif [ -f "$HOME/.Xauthority" ] ; then
    cp $HOME/.Xauthority /tmp/.wkrootxauth
  fi
  if [ -f "/tmp/.wkrootxauth" ] ; then
    chmod a+r /tmp/.wkrootxauth
    export ROOTXAUTH1="/tmp/.wkrootxauth"
  else
    echo "error: no xauthority file."
  fi
fi
echo "System install: $SYSTEM_INSTALL"

QAPTDISTR1="$( dash /usr/share/apps/q4os_system/bin/print_qaptdistr.sh )"
XDGCFGHOMEDIR_PLASMA="$( dash /usr/share/apps/q4os_system/bin/print_xdgcfghome_plasma.sh )"
echo "Distro: $QAPTDISTR1"
echo "XDG config home for plasma: $XDGCFGHOMEDIR_PLASMA"

#this code ensures that this script will not run if an x11 Plasma session was selected after starting a Wayland session
#only applies to Bookworm and Trixie installations
#fixed for Trixie installations from 11/2025
#to remove once Trixie is discontinued
if [ -f "$XDGCFGHOMEDIR_PLASMA/kmixrc" ] || [ -f "$XDGCFGHOMEDIR_PLASMA/kwinrc" ] ; then
  echo "Plasma session has been started already, a previous logon detected."
  if [ "$SYSTEM_INSTALL" != "livemedia" ] ; then
    if [ "$QAPTDISTR1" = "trixie" ] || [ "$QAPTDISTR1" = "bookworm" ] ; then
      echo "Todo: resolve xorg x wayland clash to be able to run this script $SRCFNAME1, exiting ..."
      kwriteconfig --file "$HOME/.local/share/q4os/.frstlogq4.stp" --group "install" --key "debug1" "not_allowed_to_run"
      deactivate_this
      deinit1 --continue-session
      exit
    fi
  fi
fi

xsetroot -cursor_name left_ptr
if [ "$QDSK_SESSION" = "trinity" ] ; then
  xsetroot -solid "#3272A1"
else
  xsetroot -solid "#000000"
fi

if [ "$QDSK_SESSION" = "plasma" ] ; then
  export XDG_CONFIG_HOME="$XDGCFGHOMEDIR_PLASMA"
  export TDEHOME="$(dash /usr/share/apps/q4os_system/bin/printvar_tdehome_plasma.sh)"
else
  export XDG_CONFIG_HOME="$HOME/.configtde"
fi

if [ -f "/var/lib/q4os/isquarkos.stp" ] ; then
  IS_QUARK_OS="1"
  echo "Quark OS: true"
fi

#wait for populate homedir
CTR1="120" ; while [ "$CTR1" -gt "0" ] && [ ! -f "$HOME/.local/share/q4os/.extrdq4.stp" ] ; do echo "wait for extract ..$CTR1.." ; sleep 0.2 ; CTR1="$((CTR1 - 1))" ; done ; sleep 0.1

if [ "$QDSK_SESSION" = "trinity" ] ; then
  . /opt/trinity/env/60_q4xftdpi.sh
fi

echo "starting dcopserver .."
$TDEDIR/bin/dcopserver --nosid
echo "running tdebuildsycoca .."
$TDEDIR/bin/tdebuildsycoca
if [ -f "$ROOTXAUTH1" ] ; then
  echo "running tdebuildsycoca for root .."
  sudo -n XAUTHORITY="$ROOTXAUTH1" $TDEDIR/bin/tdebuildsycoca
fi
echo "checking custom theme .."
THEME1="$( kreadconfig --file "/etc/q4os/q4base.conf" --group "General" --key "default_theme" )"
echo "custom theme: $THEME1"
if [ -n "$THEME1" ] ; then
  kdialog --passivepopup "<font size=4><p>$(eval_gettext "Configuring desktop theme ...")</p></font>" 120 &
  sleep 0.1
  echo "applying custom theme .."
  THQ_THNAME="$THEME1" ktheme_setter
  if [ -n "$SYSTEM_INSTALL" ] ; then
    echo "applying custom theme for root .."
    if [ -f "$ROOTXAUTH1" ] ; then
      sudo -n XAUTHORITY="$ROOTXAUTH1" THQ_THNAME="$THEME1" ktheme_setter
    fi
    #previous command may remove/modify the "$XDGCFGHOMEROOT/menus/tde-applications.menu" file, so fix it
    XDGCFGHOMEROOT="$(dash /usr/share/apps/q4os_system/bin/print_xdgcfghome_plasma.sh "root")/menus/tde-applications.menu"
    echo "xdgcfghomeroot: $XDGCFGHOMEROOT"
    sudo -n rm -f $XDGCFGHOMEROOT/menus/tde-applications.menu
    sudo -n mkdir -p $XDGCFGHOMEROOT/menus/
    sudo -n ln -s /opt/trinity/etc/xdg/menus/tde-applications.menu $XDGCFGHOMEROOT/menus/tde-applications.menu
  fi
  pkill -n kdialog
  echo "custom theme done."
fi

if [ "$XDG_SESSION_TYPE" = "wayland" ] && [ "$QDSK_SESSION" = "plasma" ] && [ -f "/usr/bin/kcmshell6" ] && [ -f "/usr/bin/kwin_wayland" ] ; then
  kwriteconfig6 --file "kwinrc" --group "org.kde.kdecoration2" --key "ButtonsOnLeft" ""
  kwriteconfig6 --file "kwinrc" --group "org.kde.kdecoration2" --key "ButtonsOnRight" ""
  echo "launching kwin.."
  kwin_wayland_wrapper --xwayland 2>/dev/null 1>/dev/null &
  CTR1="150" ; while [ "$CTR1" -gt "0" ] && ( ! qdbus6 org.kde.KWin 2>/dev/null 1>/dev/null ) ; do echo "wait for kwin ..$CTR1.." ; sleep 0.1 ; CTR1="$((CTR1 - 1))" ; done ; sleep 0.5
  echo " ..kwin ready."
  WLINE="$(ps -ef | grep -v " grep " | grep "/kwin_wayland " | tail -n1)"
  export WAYLAND_DISPLAY="$(echo $WLINE | awk -F'--socket ' '{ print $2 }' | awk -F' ' '{ print $1 }')"
  export DISPLAY="$(echo $WLINE | awk -F'--xwayland-display ' '{ print $2 }' | awk -F' ' '{ print $1 }')"
  export XAUTHORITY="$(echo $WLINE | awk -F'--xwayland-xauthority ' '{ print $2 }' | awk -F' ' '{ print $1 }')"
  echo "WAYLAND_DISPLAY: $WAYLAND_DISPLAY"
  echo "DISPLAY:         $DISPLAY"
  echo "XAUTHORITY:      $XAUTHORITY"
  cp $XAUTHORITY /tmp/.wkrootxauth
  chmod a+r /tmp/.wkrootxauth
  export ROOTXAUTH1="/tmp/.wkrootxauth"
else
  echo "configuring twin .."
  TWINRCTMPCFG="/tmp/.fsttwinrc_$ACTIVE_USER"
  cp "$HOME/.trinity/share/config/twinrc" "$TWINRCTMPCFG"
  # kwriteconfig --file "$TWINRCTMPCFG" --group "Style" --key "PluginLib" "twin3_plastik"
  kwriteconfig --file "$TWINRCTMPCFG" --group "Style" --key "ButtonsOnLeft" "_"
  kwriteconfig --file "$TWINRCTMPCFG" --group "Style" --key "ButtonsOnRight" "AX"
  kwriteconfig --file "$TWINRCTMPCFG" --group "Style" --key "CustomButtonPositions" "true"
  kwriteconfig --file "$TWINRCTMPCFG" --group "MouseBindings" --key "CommandActiveTitlebar2" "Nothing"
  kwriteconfig --file "$TWINRCTMPCFG" --group "MouseBindings" --key "CommandActiveTitlebar3" "Nothing"
  kwriteconfig --file "$TWINRCTMPCFG" --group "MouseBindings" --key "CommandInactiveTitlebar2" "Nothing"
  kwriteconfig --file "$TWINRCTMPCFG" --group "MouseBindings" --key "CommandInactiveTitlebar3" "Nothing"
  echo "launching twin.."
  $TDEDIR/bin/twin --disablecompositionmanager --lock --replace --config "$TWINRCTMPCFG" &
  CTR1="100" ; while [ "$CTR1" -gt "0" ] && [ -z "$( dcopfind twin )" ] ; do echo "wait for twin ..$CTR1.." ; sleep 0.1 ; CTR1="$((CTR1 - 1))" ; done ; sleep 0.1
  echo " ..twin ready."
fi

MEMTOTAL="$( q4hw-info --memtotal )"
echo "Memtotal: $MEMTOTAL"
if [ "$SYSTEM_INSTALL" = "livemedia" ] && [ -f "/usr/share/apps/q4os_system/bin/live_to_ram.sh" ] ; then
  MEMTOTAL="$MEMTOTAL" dash /usr/share/apps/q4os_system/bin/live_to_ram.sh
fi

if [ -n "$SYSTEM_INSTALL" ] ; then
  kdialog --passivepopup "<font size=4><p>$(eval_gettext "Configuring the system ...")</p></font>" 6 &
else
  kdialog --passivepopup "<font size=4><p>$(eval_gettext "Configuring the profile ...")</p></font>" 6 &
fi

#screen scaling
if [ -n "$SYSTEM_INSTALL" ] ; then
  PROBE_DPI="$( q4hw-info --probe-dpi | tail -n1 )"
  echo "dpi probed: $PROBE_DPI"
  if [ "$PROBE_DPI" -lt "40" ] || [ "$PROBE_DPI" -gt "130" ] ; then
    MSG2="<p>$(eval_gettext "You may want to enlarge text and widgets size to improve readability. Click OK to run a configuration tool for screen setup and scaling.")</p>"
    if false && [ -z "$IS_QUARK_OS" ] && [ "$QDSK_SESSION" = "plasma" ] && [ -f "/usr/bin/kcmshell6" ] ; then
      #disabled now, todo: first fix "kcmshell6 kcm_kscreen" bug - it doesn't exit when clicked the ok button, likely kde bug
      #we need to start the full kded for display resolution to be saved in $HOME/.local/share/kscreen/
#       export KDE_FULL_SESSION="true"
#       export KDE_SESSION_VERSION="6"
#       /usr/bin/kded6 &
      /usr/bin/kdialog --icon "message" --title "$(eval_gettext "Display setup")" --msgbox "$MSG2"
      echo "[dbg:]before:kcm_kscreen"
      /usr/bin/kcmshell6 kcm_kscreen
      echo "[dbg:]after:kcm_kscreen"
      # kbuildsycoca6
      sleep 1 #need to write to $HOME/.local/share/kscreen/; why ?
      DPICFG1="$( /usr/bin/kreadconfig6 --file "kcmfonts" --group "General" --key "forceFontDPI" )"
#       /usr/lib/x86_64-linux-gnu/libexec/kactivitymanagerd stop &
#       pkill -f kactivitymanagerd ; killall kactivitymanagerd
#       pkill kded6
#       unset KDE_FULL_SESSION
#       unset KDE_SESSION_VERSION
      if [ -n "$DPICFG1" ] && [ "$DPICFG1" -gt "130" ] ; then
        TDEHOME="" dash /usr/share/apps/q4os_system/bin/dpi_set.sh "$DPICFG1"
      fi
    elif false && [ -z "$IS_QUARK_OS" ] && [ "$QDSK_SESSION" = "plasma" ] && [ -f "/usr/bin/kcmshell6" ] ; then
      kdialog --icon "message" --title "Q4OS" --caption "$(eval_gettext "Display setup")" --msgbox "$MSG2"
      FORCE_TSCR="1" /opt/trinity/bin/screenscalerp.exu
      . /opt/trinity/env/60_q4xftdpi.sh
    elif [ -z "$IS_QUARK_OS" ] && [ "$QDSK_SESSION" = "plasma" ] && [ -f "/usr/bin/kcmshell5" ] ; then
      #we need to start the full kded for display resolution to be saved in $HOME/.local/share/kscreen/
      export KDE_FULL_SESSION="true"
      export KDE_SESSION_VERSION="5"
      LD_BIND_NOW=true /usr/lib/x86_64-linux-gnu/libexec/kf5/start_kdeinit_wrapper --kded +kcminit_startup
      /usr/bin/kdialog --icon "message" --title "$(eval_gettext "Display setup")" --msgbox "$MSG2"
      /usr/bin/kcmshell5 kcm_kscreen
      kbuildsycoca5
      sleep 1 #need to write to $HOME/.local/share/kscreen/; why ?
      DPICFG1="$( /usr/bin/kreadconfig5 --file "kcmfonts" --group "General" --key "forceFontDPI" )"
      kdeinit5_shutdown
      kactivitymanagerd stop || killall kactivitymanagerd
      unset KDE_FULL_SESSION
      unset KDE_SESSION_VERSION
      if [ -n "$DPICFG1" ] && [ "$DPICFG1" -gt "130" ] ; then
        TDEHOME="" dash /usr/share/apps/q4os_system/bin/dpi_set.sh "$DPICFG1"
      fi
    elif [ "$QDSK_SESSION" = "trinity" ] ; then
      kdialog --icon "message" --title "Q4OS" --caption "$(eval_gettext "Display setup")" --msgbox "$MSG2"
      /opt/trinity/bin/screenscalerp.exu
      . /opt/trinity/env/60_q4xftdpi.sh
    else
      echo "No screen scaling tool to use."
      # kdialog --icon "message" --title "Q4OS" --caption "$(eval_gettext "Display setup")" --msgbox "<p>$(eval_gettext "No screen scaling tool found.")</p>"
    fi
  fi
fi

if [ -n "$SYSTEM_INSTALL" ] ; then
  if ! q4hw-info --soundcard ; then
    echo "sound card not detected .."
    if [ "$QDSK_SESSION" = "trinity" ] ; then
      kdialog --icon "message" --title "Q4OS" --caption "setup" --msgbox "$(eval_gettext "Sound card not detected, system sound was disabled.")"
    fi
  fi
  q4hw-info --wireless
  if [ "$?" = "0" ] ; then
    echo "wifi card detected."
    WIRLS_CARD="1"
  else
    echo "wifi card not detected."
  fi
  q4hw-info --thinkpad-r51
  if [ "$?" = "0" ] ; then
    echo "we are on thinkpad r51 .."
    kdialog --icon "message" --title "Q4OS" --caption "setup" --msgbox "<p>$(eval_gettext "IBM Thinkpad R51 laptop detected, extra configuration will be performed.")</p>"
  fi
  q4hw-info --eeepc
  if [ "$?" = "0" ] ; then
    echo "we are on asus eee laptop .."
    kdialog --icon "message" --title "Q4OS" --caption "setup" --msgbox "<p>$(eval_gettext "Asus Eee PC laptop detected, extra configuration will be performed.")</p>"
  fi
  # q4hw-info --nvidia-drv
  # if [ "$?" = "0" ] ; then
  #   echo "nvidia proprietary video driver available."
  #   kdialog --icon "message" --title "Q4OS" --caption "setup" --msgbox "<p>$(eval_gettext "NVIDIA proprietary graphics driver is available. You will be able to easily setup NVIDIA driver using installer from the <b>Q4OS Software Centre</b>.")</p>"
  # else
  #   echo "no nvidia proprietary video driver available."
  # fi
fi

if [ -n "$SYSTEM_INSTALL" ] ; then
  if [ "$( kreadconfig --file "/etc/q4os/q4base.conf" --group "DesktopProfiler" --key "needtoapply" )" != "0" ] ; then
    WANT_PROFILER="1"
  else
    WANT_PROFILER="0"
  fi
  echo "Profile installation wanted: $WANT_PROFILER"
fi

if [ -n "$SYSTEM_INSTALL" ] ; then
  WANT_WINET="1"
  # WANT_WINET="0"
  # if [ "$QDSK_SESSION" = "trinity" ] ; then
  #   WANT_WINET="1"
  # elif [ "$WANT_PROFILER" = "1" ] ; then
  #   WANT_WINET="1"
  # fi
  echo "Internet wanted: $WANT_WINET"

  RUN_WIFICON="0"
  if [ "$WANT_WINET" = "1" ] && [ "$WIRLS_CARD" = "1" ] && [ -x "/opt/trinity/bin/tdewificonnect" ] ; then
    echo " [w1:] wifi card present and tdewificonnect ready."
    if [ -z "$( nmcli --terse -f NAME,TYPE connection | grep "wireless$" )" ] ; then
      echo " [w1:] no wifi connections found in the system."
      if ! dash /usr/share/apps/q4os_system/bin/tst_dwnl.sh "" "5" ; then
        echo " [w1:] internet link probed, seems not to be available."
        #run the connection tool only if:
        #-wireless card detected
        #-no wifi connections exist yet, to prevent creating double connections ; todo: solve it cleaner
        #-internet inaccesible
        RUN_WIFICON="1"
        echo " [w1:] request to run wifi connection tool ..."
      fi
    fi
  fi
  # if [ "$QAPTDISTR1" = "noble" ] ; then
  #   RUN_WIFICON="0"
  #   echo " [w1:] request not to run wifi connection tool for noble ..."
  # fi
  if [ -f "/tmp/.forcetdewifiman.stp" ] ; then
    #for testing purposes, to force running wifi connection tool on the first boot
    #may be removed as not needed
    RUN_WIFICON="1"
    echo " [w1:] request by kernel parameter to run wifi connection tool ..."
  fi
  echo "Run wifi connection tool: $RUN_WIFICON"

  if [ "$RUN_WIFICON" = "1" ] ; then
    kdialog --icon "message" --title "Q4OS" --caption "WiFi setup" --msgbox "<p>$(eval_gettext "Wireless network card detected, WiFi support enabled.")</p><p>$(eval_gettext "Click OK to run WiFi connection tool to create a network connection.")</p>"
    while [ "$RUN_WIFICON" = "1" ] ; do
      echo " [w1:] running tdewificonnect ..."
      ( tdewificonnect --icon "network" 2>&1 ) > $HOME/.local/share/q4os/log/tdewificonnect.log
      echo " [w1:] tdewificonnect finished, checking if a connection has been created .."
      WIFI_CREATED="$( nmcli --terse -f UUID,NAME,TYPE connection | grep "wireless$" | awk -F':' '{ print $1 }' | tail -n1 )"
      echo " [w1:] wifi_created: "$( nmcli --terse -f NAME,UUID,TYPE connection | grep "wireless$" )""
      if [ -n "$WIFI_CREATED" ] ; then
        kdialog --passivepopup "<font size=4><p>$(eval_gettext "Trying to setup wireless network ...")</p></font>" 40 &
        echo " [w1:] connection has been created: $WIFI_CREATED , trying to setup wireless network ..."
        sleep 1.5
        COUNTER1="7"
        while [ -z "$INET_OK" ] && [ "$COUNTER1" -gt "0" ] ; do
          sleep 1 ; COUNTER1="$(( COUNTER1 - 1 ))" ; echo $COUNTER1
          if dash /usr/share/apps/q4os_system/bin/tst_dwnl.sh "" "6" > /dev/null ; then
            INET_OK="1" ; echo " [w1:] internet ok, connected."
          fi
        done
        pkill -n kdialog
        if [ -z "$INET_OK" ] ; then
          echo " [w1:] couldn't connect to internet ..."
          sudo -n nmcli connection delete uuid "$WIFI_CREATED"
          kdialog --icon "message" --title "Q4OS" --caption "WiFi setup" --msgbox "<p>$(eval_gettext "Connection not successful, check the Wifi password please.")</p>"
        else
          unset RUN_WIFICON ; echo " [w1:] success connecing ..."
        fi
      else
        unset RUN_WIFICON ; echo " [w1:] no connection has been created ..."
      fi
    done
  elif [ "$WIRLS_CARD" = "1" ] && [ "$QDSK_SESSION" = "trinity" ] ; then
    kdialog --icon "message" --title "Q4OS" --caption "WiFi setup" --msgbox "<p>$(eval_gettext "Wireless network card detected, WiFi support enabled.")</p>"
  fi
fi

LANG_PACK_FAIL="0"
if [ "$SYSTEM_INSTALL" = "live" ] || [ "$SYSTEM_INSTALL" = "classic" ] ; then
  if [ "$QDSK_SESSION" != "plasma" ] ; then
    pkill --signal SIGCONT qapt_lock.exu
    dash /usr/share/apps/q4os_system/bin/.addlang_ai_01.sh
    LANG_PACK_FAIL="$?"
  fi
fi
if [ "$SYSTEM_INSTALL" = "preinstall" ] ; then
  pkill --signal SIGCONT qapt_lock.exu
  dash /usr/share/apps/q4os_system/bin/.addlang_ai_02.sh
  LANG_PACK_FAIL="$?"
fi
if [ -n "$SYSTEM_INSTALL" ] ; then
  /usr/share/apps/q4os_system/bin/qapt_lock.exu --lock --sig-me &
fi
if [ "$SYSTEM_INSTALL" = "livemedia" ] && [ -f "/usr/share/apps/q4os_system/bin/livemedia_localization.sh" ] ; then
  . /usr/share/apps/q4os_system/bin/livemedia_localization.sh
fi

#set $LANG to a new value generated by previous scripts
if [ -n "$SYSTEM_INSTALL" ] && [ -f "$HOME/.addlangenv.sh" ] ; then
  #remove all xdg dirs before locale change
  mkdir /tmp/.desktoptmpdir/ ; cp "$( xdg-user-dir DESKTOP )"/* /tmp/.desktoptmpdir/ #backup possible files
  if [ "$( readlink -s -f "$( xdg-user-dir PUBLICSHARE )" )" != "$HOME" ] ; then rm -rf "$( xdg-user-dir PUBLICSHARE )" ; fi
  if [ "$( readlink -s -f "$( xdg-user-dir TEMPLATES )" )" != "$HOME" ] ; then rm -rf "$( xdg-user-dir TEMPLATES )" ; fi
  if [ "$( readlink -s -f "$( xdg-user-dir DOWNLOAD )" )" != "$HOME" ] ; then rm -rf "$( xdg-user-dir DOWNLOAD )" ; fi
  if [ "$( readlink -s -f "$( xdg-user-dir VIDEOS )" )" != "$HOME" ] ; then rm -rf "$( xdg-user-dir VIDEOS )" ; fi
  if [ "$( readlink -s -f "$( xdg-user-dir MUSIC )" )" != "$HOME" ] ; then rm -rf "$( xdg-user-dir MUSIC )" ; fi
  if [ "$( readlink -s -f "$( xdg-user-dir PICTURES )" )" != "$HOME" ] ; then rm -rf "$( xdg-user-dir PICTURES )" ; fi
  if [ "$( readlink -s -f "$( xdg-user-dir DOCUMENTS )" )" != "$HOME" ] ; then rm -rf "$( xdg-user-dir DOCUMENTS )" ; fi
  if [ "$( readlink -s -f "$( xdg-user-dir DESKTOP )" )" != "$HOME" ] ; then rm -rf "$( xdg-user-dir DESKTOP )" ; fi
  rm -f $HOME/.configtde/user-dirs.dirs
  rm -f $HOME/.configtde/user-dirs.locale
  . /usr/share/apps/q4os_system/bin/exportlang.sh #export changed $LANG locales
  # dbus-update-activation-environment --systemd LANG
  xdg-user-dirs-update ; xdg-user-dirs-update --force #recreate xdg dirs after locale change
  cp /tmp/.desktoptmpdir/* "$( xdg-user-dir DESKTOP )"/ #restore possible files
else
  xdg-user-dirs-update
fi
XDG_CONFIG_HOME="$HOME/.config" xdg-user-dirs-update #create '$HOME/.config/user-dirs.*' to workaround tde bug https://sourceforge.net/p/q4os/tickets/83/

echo "Seting country and language, based on: $LANG"
dash /usr/share/apps/q4os_system/bin/langckeyctde2.sh
sudo -n dash /usr/share/apps/q4os_system/bin/langckeyctde2.sh

if [ "$SYSTEM_INSTALL" = "livemedia" ] || [ "$SYSTEM_INSTALL" = "preinstall" ] ; then
  echo "Setting system keyboard ..."
  DETECT_KBLAYOUT="$( dash /usr/share/apps/q4os_system/bin/dowqi18.sh "--print-tdecode" "$LANG" | grep "^Keyboard_Code: " | awk -F': ' '{ print $2 }' )"
  DETECT_KBMODEL="$( /opt/trinity/bin/kreadconfig --file "/etc/default/keyboard" --group "" --key "XKBMODEL" | tr -d '"' )"
  echo "Keyboard layout/model detected: $DETECT_KBLAYOUT/$DETECT_KBMODEL"
  sudo -n KB_SYS_LAYOUT="$DETECT_KBLAYOUT" KB_SYS_MODEL="$DETECT_KBMODEL" dash /usr/share/apps/q4os_system/bin/kblayout_mod.sh --write-sys
fi

#!!! Warning !!! : 'kwriteconfig' removes all lang entries from .desktop files ! - do not use for .desktop files !!!
# kwriteconfig --file "$( xdg-user-dir TEMPLATES )/.directory" --group "Desktop Entry" --key "Icon" "folder-templates"
# kwriteconfig --file "$( xdg-user-dir DOWNLOAD )/.directory" --group "Desktop Entry" --key "Icon" "folder-download"
# kwriteconfig --file "$( xdg-user-dir VIDEOS )/.directory" --group "Desktop Entry" --key "Icon" "folder-videos"
kwriteconfig --file "$( xdg-user-dir MUSIC )/.directory" --group "Desktop Entry" --key "Icon" "folder-sound"
kwriteconfig --file "$( xdg-user-dir PICTURES )/.directory" --group "Desktop Entry" --key "Icon" "folder-image"
kwriteconfig --file "$( xdg-user-dir DOCUMENTS )/.directory" --group "Desktop Entry" --key "Icon" "folder-documents"
kwriteconfig --file "$( xdg-user-dir DESKTOP )/.directory" --group "Desktop Entry" --key "Encoding" "UTF-8"
kwriteconfig --file "$( xdg-user-dir DESKTOP )/.directory" --group "Desktop Entry" --key "Icon" "user-desktop"
kwriteconfig --file "$( xdg-user-dir DESKTOP )/.directory" --group "Desktop Entry" --key "Type" "Directory"

# #create user desktop icons
# cp "/opt/trinity/share/apps/kdesktop/Desktop/My_Computer" "$( xdg-user-dir DESKTOP )/q4os_My_Computer.desktop"
# cp "/opt/trinity/share/apps/kdesktop/Desktop/My_Documents" "$( xdg-user-dir DESKTOP )/q4os_My_Documents.desktop"
# cp "/opt/trinity/share/apps/kdesktop/Desktop/My_Network_Places" "$( xdg-user-dir DESKTOP )/q4os_My_Network_Places.desktop"
# cp "/opt/trinity/share/apps/kdesktop/Desktop/Trash" "$( xdg-user-dir DESKTOP )/q4os_Trash.desktop"
# cp "/opt/trinity/share/apps/kdesktop/Desktop/Web_Browser" "$( xdg-user-dir DESKTOP )/q4os_Web_Browser.desktop"

if [ "$QAPTDISTR1" != "bookworm" ] && [ "$QAPTDISTR1" != "bullseye" ] && [ "$QAPTDISTR1" != "noble" ] && [ "$QAPTDISTR1" != "jammy" ] && [ "$QAPTDISTR1" != "raspbian12" ] ; then
  if [ -z "$(kreadconfig --file "$XDGCFGHOMEDIR_PLASMA/kxkbrc" --group "Layout" --key "LayoutList")" ] ; then
    #need to write keybard layout already here as plasma session scripts don't affect session settings
    echo "Seting keyboard for Plasma user ..."
    dash /usr/share/apps/q4os_system/bin/kblayout_mod.sh --write-plasmaconfig
  fi
fi

if [ -n "$SYSTEM_INSTALL" ] && [ "$LANG_PACK_FAIL" != "0" ] ; then
  echo "language pack installation failed, creating desktop shortcut .."
  cp "/usr/share/apps/q4os_system/share/.instlq4langpack.desktop" "$( xdg-user-dir DESKTOP )/instlq4langpack.desktop"
  cp "/usr/share/apps/q4os_system/bin/.addlang_ai_01.sh" "$HOME/.addlang_ai_01.sh"
fi

#disabled as moved to the populate_homedir systemd service, remove this snippet later
if false ; then
echo "Setting the default web browser ..."
dash /usr/share/apps/q4os_system/bin/set_default_browser.sh
fi

echo "Running hooks ..."
for SCRPT1 in /usr/share/apps/q4os_system/bhooks/bhook2_*.sh ; do
  if [ -f "$SCRPT1" ] ; then
    echo "Sourcing sript ... $SCRPT1"
    . $SCRPT1
  fi
done
echo "Finished hooks ..."

#WINEDLLOVERRIDES="mshtml=" wineboot -u & #creates wine configuration in $HOME dir

if [ "$SYSTEM_INSTALL" = "preinstall" ] ; then
  # sudo -n passwd -d "$ACTIVE_USER"
  sudo -n XAUTHORITY="$ROOTXAUTH1" tdepasswd --icon "message" --title "" --caption "" --nofork "$ACTIVE_USER"
  sudo -n ctrl-autologin --disable
fi

if [ -f "/var/lib/q4os/.swprfl-acndrq-10.tmp" ] || [ -f "/var/lib/q4os/.swprfl-acndrq-20.tmp" ] || [ -f "/var/lib/q4os/.swprfl-acndrq-30.tmp" ] ; then
  #to enable removal
  sudo -n mv /var/lib/q4os/.swprfl-acndrq-* /tmp/
  sudo -n chown $ACTIVE_USER /tmp/.swprfl-acndrq-*
  sudo -n chmod a+rw /tmp/.swprfl-acndrq-*
fi

sudo -n $TDEDIR/bin/dcopserver_shutdown --wait
deactivate_this

if [ "$SYSTEM_INSTALL" = "livemedia" ] ; then
  deinit1 --continue-session
  exit
fi

if [ -n "$SYSTEM_INSTALL" ] ; then
  ENDMESSAGE="<p>$(eval_gettext "Congratulations, setup has finished.")</p>"
  if [ "$WANT_PROFILER" = "1" ] ; then
    if dash /usr/share/apps/q4os_system/bin/tst_dwnl.sh "" "5" ; then
      echo "sw profiler execute .."
      pkill --signal SIGCONT qapt_lock.exu
      HIDE_DECORATION1="1" TDE_DEBUG="1" swprofiler.exu
      pkill kdialog
    fi
    #re-read desktop profiler result
    if [ "$( kreadconfig --file "/etc/q4os/q4base.conf" --group "DesktopProfiler" --key "needtoapply" )" != "0" ] ; then
      ENDMESSAGE="$ENDMESSAGE<p>$(eval_gettext "No desktop profile has been applied yet. It's highly recommended to run <b>Desktop Profiler</b> tool and apply one of available profiles as soon as possible.")</p>"
    fi
  fi

  if [ -f "/tmp/.swprfl-acndrq-30.tmp" ] || [ -f "/var/lib/q4os/.swprfl-acndrq-30.tmp" ] ; then
    #reboot
    rm -f /tmp/.swprfl-acndrq-30.tmp
    rm -f /var/lib/q4os/.swprfl-acndrq-30.tmp
    ENDMESSAGE="$ENDMESSAGE<p>$(eval_gettext "Click Ok to reboot your computer now.")</p>"
    kdialog --icon "message" --title "Q4OS" --caption "setup" --msgbox "$ENDMESSAGE"
    deinit1 --reboot
    exit
  elif [ -f "/tmp/.swprfl-acndrq-20.tmp" ] || [ -f "/var/lib/q4os/.swprfl-acndrq-20.tmp" ] ; then
    #restart X server
    rm -f /tmp/.swprfl-acndrq-20.tmp
    rm -f /var/lib/q4os/.swprfl-acndrq-20.tmp
    ENDMESSAGE="$ENDMESSAGE<p>$(eval_gettext "Click Ok to reboot your computer now.")</p>" # todo: ENDMESSAGE="$ENDMESSAGE<p>Click OK to get login screen now.</p>"
    kdialog --icon "message" --title "Q4OS" --caption "setup" --msgbox "$ENDMESSAGE"
    deinit1 --restartx
    exit
  elif [ -f "/tmp/.swprfl-acndrq-10.tmp" ] || [ -f "/var/lib/q4os/.swprfl-acndrq-10.tmp" ] ; then
    #re-login
    rm -f /tmp/.swprfl-acndrq-10.tmp
    rm -f /var/lib/q4os/.swprfl-acndrq-10.tmp
    ENDMESSAGE="$ENDMESSAGE<p>$(eval_gettext "Click OK to get login screen now.")</p>"
    kdialog --icon "message" --title "Q4OS" --caption "setup" --msgbox "$ENDMESSAGE"
    deinit1 --logout
    exit
  fi

  if [ "$WANT_PROFILER" = "1" ] ; then
    kdialog --icon "message" --title "Q4OS" --caption "setup" --msgbox "$ENDMESSAGE"
  fi
fi

deinit1 --continue-session

) 2>&1 ) >> "$LOGT_FILE"
