#!/bin/sh

#run on first plasma login

SRCFNAME1="$( basename "$0" )"
LOGT_FILE="$HOME/.local/share/q4os/log/${SRCFNAME1}_$( date +%Y-%m-%d-%H-%M-%S ).log"
mkdir -p "$( dirname "$LOGT_FILE" )"
echo "Creation time: $( date +%Y-%m-%d-%H-%M-%S )" > "$LOGT_FILE"

( (

echo "Starting script ..."

ACTIVE_USER="$( whoami )"
FIRST_USER="$( dash /usr/share/apps/q4os_system/bin/get_first_user.sh --name )"
QAPTDISTR1="$( dash /usr/share/apps/q4os_system/bin/print_qaptdistr.sh )"
XDGCFGHOMEFULL="$(dash /usr/share/apps/q4os_system/bin/print_xdgcfghome_plasma.sh)"
echo "Active user: $ACTIVE_USER"
echo "First user: $FIRST_USER"
echo "Distro: $QAPTDISTR1"
echo "Plasma XDG homedir: $XDGCFGHOMEFULL"
echo "Lang: $LANG"

if [ "$QAPTDISTR1" != "bullseye" ] && [ "$QAPTDISTR1" != "focal" ] ; then
  echo "Seting keyboard for Plasma ..."
  dash /usr/share/apps/q4os_system/bin/kblayout_mod.sh --write-plasmaconfig
fi

if [ "$QAPTDISTR1" = "bookworm" ] || [ "$QAPTDISTR1" = "raspbian12" ] ; then
  echo "Disable power saving for Bookworm to avoid desktop freeze .. fixing Debian bug"
  # kwriteconfig5 --file "$XDGCFGHOMEFULL/powermanagementprofilesrc" --group AC --group DPMSControl --key idleTime --type int 21600
  kwriteconfig5 --file "$XDGCFGHOMEFULL/powermanagementprofilesrc" --group AC --group SuspendSession --key idleTime --type int 21600000
  kwriteconfig5 --file "$XDGCFGHOMEFULL/powermanagementprofilesrc" --group AC --group SuspendSession --key suspendType --type int 32
  # chmod a+r "$XDGCFGHOMEFULL/powermanagementprofilesrc"
fi

if [ "$ACTIVE_USER" = "$FIRST_USER" ] ; then
  echo "Exclude welcome screen from session recovery for first user ..."
  # kwriteconfig5 --file "$XDGCFGHOMEFULL/ksmserverrc" --group "General" --key "loginMode" "default"
  kwriteconfig5 --file "$XDGCFGHOMEFULL/ksmserverrc" --group "General" --key "excludeApps" "welcome-screen5.exu"
  # chmod a+r "$XDGCFGHOMEFULL/ksmserverrc"
fi

if [ "$QAPTDISTR1" = "bookworm" ] || [ "$QAPTDISTR1" = "bullseye" ] || [ "$QAPTDISTR1" = "raspbian12" ] || [ "$QAPTDISTR1" = "noble" ] || [ "$QAPTDISTR1" = "jammy" ] || [ "$QAPTDISTR1" = "focal" ] ; then
  if [ -f "$XDGCFGHOMEFULL/kcminputrc" ] ; then
    #workaround for a plasma bug, as it doesn't follow the XDG standard locations for "kcminputrc"
    #see https://www.q4os.org/forum/viewtopic.php?id=2778
    #remove as fixed by upstream
    echo "Fix cursor theme for Plasma desktop ..."
    mkdir -p $HOME/.config/
    cd $HOME/.config/
    ln -s "$XDGCFGHOMEFULL/kcminputrc" "kcminputrc"
  fi
fi

echo "Manage user directories by XDG standard ..."
cd
xdg-user-dirs-update #create $XDG_CONFIG_HOME/.userdirs.dirs file ; check if needed

# #remove initial plasma desktop shortcuts
# rm "$( xdg-user-dir DESKTOP )"/trash.desktop
# rm "$( xdg-user-dir DESKTOP )"/Home.desktop
# #fixing a kde/debian bug - the desktop directory is not translated correctly --start--
# if [ -z "$( ls "$( xdg-user-dir DESKTOP )/" )" ] ; then
#   rm -rf "$( xdg-user-dir DESKTOP )"
# fi
# xdg-user-dirs-update --force
# mkdir -p "$( xdg-user-dir DESKTOP )"
# #fixing a kde/debian bug - the desktop directory is not translated correctly --end--
# if [ ! -f "$( xdg-user-dir DESKTOP )/.directory" ] ; then
#   kwriteconfig5 --file "$( xdg-user-dir DESKTOP )/.directory" --group "Desktop Entry" --key "Encoding" "UTF-8"
#   kwriteconfig5 --file "$( xdg-user-dir DESKTOP )/.directory" --group "Desktop Entry" --key "Icon" "user-desktop"
#   kwriteconfig5 --file "$( xdg-user-dir DESKTOP )/.directory" --group "Desktop Entry" --key "Type" "Directory"
# fi

# #plasma desktop installer shortcut for live-media
# if [ -f "/usr/share/applications/debian-installer-launcher.desktop" ] ; then
#   PLSHRTC="$( xdg-user-dir DESKTOP )/debian-installer-launcher.desktop"
#   cp /usr/share/applications/debian-installer-launcher.desktop "$PLSHRTC"
#   chmod a+x "$PLSHRTC"
# fi

#remove this script after the first run
rm "$0"

) 2>&1 ) >> "$LOGT_FILE"
