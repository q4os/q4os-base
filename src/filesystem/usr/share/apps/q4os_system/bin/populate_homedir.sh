#!/bin/sh

if [ -f "$HOME/.local/share/q4os/.extrdq4.stp" ] ; then
  echo "Homedir <$HOME> already populated, exiting ..."
  exit
fi

ACTIVE_USER="$( whoami )"
if [ "$ACTIVE_USER" = "root" ] ; then
  echo "Root account detected, exiting ..."
  exit
fi

echo "\n>> Populate homedir started: $( date +%Y-%m-%d-%H-%M-%S ) <<"

export PATH="$PATH:/opt/trinity/bin"
export TDEDIR="/opt/trinity"
export XDG_CONFIG_DIRS="/opt/trinity/etc/xdg:/etc/xdg:$XDG_CONFIG_DIRS"

FIRST_USER="$( dash /usr/share/apps/q4os_system/bin/get_first_user.sh --name )"
QAPTDISTR1="$( dash /usr/share/apps/q4os_system/bin/print_qaptdistr.sh )"
XDGCFGHOMEDIR_PLASMA="$(dash /usr/share/apps/q4os_system/bin/print_xdgcfghome_plasma.sh)"
# QDSK_SESSION="$( dash /usr/share/apps/q4os_system/bin/print_session.sh )" #got unknown
echo "Active user: $ACTIVE_USER"
echo "First user: $FIRST_USER"
echo "Distro: $QAPTDISTR1"
# echo "Session: $QDSK_SESSION"
echo "Plasma xdg config dir: $XDGCFGHOMEDIR_PLASMA"
echo "Lang: $LANG"

echo "This is the first login, extracting user files ..."
mkdir -p $HOME/.configtde/
mkdir -p $HOME/.appsetup2/log/ #depreciated log dir, remove as not needed
mkdir -p $HOME/.local/share/q4os/log/
mkdir -p $HOME/.local/share/applications/wine/Programs/ #necessary for tdebuildsycoca to know about possible wine menus
mkdir -p $HOME/.cache/ #workaround: necessary for potential gnome-keyring -> q4os-nm-wraper to be pre-setup properly
# mkdir -p $HOME/.cachetde
tar -C $HOME/ -xhzf /usr/share/apps/q4os_system/share/q4os_home.tar.gz
tar -C $HOME/ -xhzf /usr/share/apps/q4os_system/share/q4os_home_$QAPTDISTR1.tar.gz
if [ -f "/usr/share/apps/q4os_system/share/q4os_home_custom1.tar.gz" ] ; then
  tar -C $HOME/ -xhzf /usr/share/apps/q4os_system/share/q4os_home_custom1.tar.gz
fi
mkdir -p "$XDGCFGHOMEDIR_PLASMA/"
rsync -a "$HOME/.config_plasma.template/." "$XDGCFGHOMEDIR_PLASMA/"
rm -rf "$HOME/.config_plasma.template/"

if [ "$QAPTDISTR1" = "bullseye" ] || [ "$QAPTDISTR1" = "jammy" ] ; then
  #to keep backward compatibility for older installations
  echo "Copying TDEHOME files for Plasma ..."
  mkdir -p "$XDGCFGHOMEDIR_PLASMA/trinity/"
  rsync -a "$HOME/.trinitykde/." "$XDGCFGHOMEDIR_PLASMA/trinity/"
fi

echo "Writing Plasma settings ..."
/opt/trinity/bin/kwriteconfig --file "$XDGCFGHOMEDIR_PLASMA/kwalletrc" --group "Wallet" --key "Enabled" "false" #don't ask for password manager for chrome/chromium
chmod a+r "$XDGCFGHOMEDIR_PLASMA/kwalletrc"
if [ "$QAPTDISTR1" = "bookworm" ] || [ "$QAPTDISTR1" = "bullseye" ] || [ "$QAPTDISTR1" = "noble" ] || [ "$QAPTDISTR1" = "jammy" ] || [ "$QAPTDISTR1" = "raspbian12" ] ; then
  /opt/trinity/bin/kwriteconfig --file "$XDGCFGHOMEDIR_PLASMA/kcminputrc" --group "Mouse" --key "cursorSize" "0"
  /opt/trinity/bin/kwriteconfig --file "$XDGCFGHOMEDIR_PLASMA/kcminputrc" --group "Mouse" --key "cursorTheme" "breeze_cursors"
  # /opt/trinity/bin/kwriteconfig --file "$XDGCFGHOMEDIR_PLASMA/kcminputrc" --group "Mouse" --key "cursorTheme" "Breeze_Light"
  chmod a+r "$XDGCFGHOMEDIR_PLASMA/kcminputrc"
  /opt/trinity/bin/kwriteconfig --file "$HOME/.trinitykde/share/config/kcminputrc" --group "Mouse" --key "cursorTheme" "breeze_cursors"
  chmod a+r "$HOME/.trinitykde/share/config/kcminputrc"
  /opt/trinity/bin/kwriteconfig --file "$XDGCFGHOMEDIR_PLASMA/ksmserverrc" --group "General" --key "loginMode" "default"
  chmod a+r "$XDGCFGHOMEDIR_PLASMA/ksmserverrc"
else
  /opt/trinity/bin/kwriteconfig --file "$XDGCFGHOMEDIR_PLASMA/kcminputrc" --group "Mouse" --key "cursorTheme" "Breeze_Light"
  chmod a+r "$XDGCFGHOMEDIR_PLASMA/kcminputrc"
  # /opt/trinity/bin/kwriteconfig --file "$XDGCFGHOMEDIR_PLASMA/ksmserverrc" --group "General" --key "loginMode" "emptySession"
  # chmod a+r "$XDGCFGHOMEDIR_PLASMA/ksmserverrc"
fi

if false ; then
  #dpi setting below doesn't work for some reason, investigate
  DPICFG1="$( kreadconfig --file "/etc/q4os/q4base.conf" --group "OnInstall" --key "screen_ffdpi_plasma" )"
  echo "Get DPI from preconfig: $DPICFG1"
  if [ -n "$DPICFG1" ] && [ -x "/usr/bin/kwriteconfig5" ] ; then
    echo "Writing screen DPI setting: $DPICFG1"
    /usr/bin/kwriteconfig5 --file "$XDGCFGHOMEDIR_PLASMA/kcmfonts" --group "General" --key "forceFontDPI" "$DPICFG1"
    # dash /usr/share/apps/q4os_system/bin/dpi_set.sh "$DPICFG1"
  fi
fi

#don't start device applet for tde-14.1.1
/opt/trinity/bin/kwriteconfig --file "tdehwdevicetrayrc" --group "General" --key "Autostart" "false"

# if [ "$QAPTDISTR1" != "bullseye" ] && [ "$QAPTDISTR1" != "jammy" ] ; then
#   #workaround a nasty bug for tde-14.1.1, see https://sourceforge.net/p/q4os/tickets/202/ - TDEPowersave loads CPU at 99%
#   /opt/trinity/bin/kwriteconfig --file "tdepowersaverc" --group "Acoustic" --key "autoDimm" "false"
#   /opt/trinity/bin/kwriteconfig --file "tdepowersaverc" --group "Performance" --key "autoDimm" "false"
#   /opt/trinity/bin/kwriteconfig --file "tdepowersaverc" --group "Powersave" --key "autoDimm" "false"
#   /opt/trinity/bin/kwriteconfig --file "tdepowersaverc" --group "Presentation" --key "autoDimm" "false"
# fi

echo "Setting the default web browser ..."
dash /usr/share/apps/q4os_system/bin/set_default_browser.sh &

if [ "$ACTIVE_USER" = "$FIRST_USER" ] || [ -f "/etc/sudoers.d/90_sudo_tmp01" ] ; then
  SYSTEM_INSTALL="$( kreadconfig --file "/etc/q4os/q4base.conf" --group "OnInstall" --key "install_type" )"
fi
echo "System install: $SYSTEM_INSTALL"

if [ -n "$SYSTEM_INSTALL" ] ; then
  if ! q4hw-info --soundcard ; then
    echo "sound card not detected, writing configuration .."
    sudo -n kwriteconfig --file "/etc/q4os/q4base.conf" --group "OnInstall" --key "soundcard" "0"
    sudo -n chmod a+r /etc/q4os/q4base.conf
  fi
fi

echo "Running hooks ..."
for SCRPT1 in /usr/share/apps/q4os_system/bhooks/bhook4_*.sh ; do
  if [ -f "$SCRPT1" ] ; then
    echo "Sourcing sript ... $SCRPT1"
    . $SCRPT1
  fi
done
echo "Finished hooks ..."

/opt/trinity/bin/kwriteconfig --file "$HOME/.local/share/q4os/.extrdq4.stp" --group "install" --key "timestamp_completed" "$( date +%Y-%m-%d-%H-%M-%S )"
/opt/trinity/bin/kwriteconfig --file "$HOME/.local/share/q4os/.extrdq4.stp" --group "install" --key "desc" "do_not_delete_this_file"
# systemctl --user disable populate_homedir.service #doesn't work for some reason
echo "\n>> Populate homedir finished: $( date +%Y-%m-%d-%H-%M-%S ) <<"

journalctl --no-pager --all --user-unit populate_homedir.service > $HOME/.local/share/q4os/log/populatehomedir.log
exit 0
