#!/bin/sh
#possible $1 values: chrome, chromium, firefox, firefox-esr, falkon, palemoon, vivaldi, edge, konqueror4, konqueror3
#if run as root, set global default browser, as well as for the first system user
#if run as a user, set default browser for the user
#if $1 is zero, determine a default browser
#xdg-settings command writes to $HOME/.config/mimeapps.list file

if [ "$( id -u )" = "0" ] ; then
  ASROOT="1"
  # echo "running as root"
fi

BRW_ID="$1"
if [ "$BRW_ID" = "_find_" ] ; then
  unset BRW_ID
fi

if [ -z "$BRW_ID" ] ; then
  #determine a default browser
  if [ -f "/usr/bin/google-chrome-stable" ] ; then
    BRW_ID="chrome"
  elif [ -f "/usr/bin/chromium" ] ; then
    BRW_ID="chromium"
  elif [ -f "/usr/bin/firefox" ] ; then
    BRW_ID="firefox"
  elif [ -f "/usr/bin/firefox-esr" ] ; then
    BRW_ID="firefox-esr"
  elif [ -f "/usr/bin/falkon" ] ; then
    BRW_ID="falkon"
  elif [ -f "/usr/bin/palemoon" ] ; then
    BRW_ID="palemoon"
  elif [ -f "/usr/bin/vivaldi-stable" ] ; then
    BRW_ID="vivaldi"
  elif [ -f "/usr/bin/microsoft-edge" ] ; then
    BRW_ID="edge"
  elif [ -f "/usr/bin/konqueror" ] ; then
    BRW_ID="konqueror4"
  elif [ -f "/opt/trinity/bin/konqueror" ] ; then
    BRW_ID="konqueror3"
  fi
fi

if [ -z "$BRW_ID" ] ; then
  echo "[I]: No candidate browser found, the default browser to be unset ..."
  BRW_ID="_none_"
else
  echo "Browser candidate: $BRW_ID"
fi

if [ "$BRW_ID" = "chrome" ] ; then
  BRW_NAME="Google Chrome"
  BRW_EXECUT="/usr/bin/google-chrome-stable"
  BRW_SHRTCT="google-chrome.desktop"
elif [ "$BRW_ID" = "chromium" ] ; then
  BRW_NAME="Chromium"
  BRW_EXECUT="/usr/bin/chromium"
  BRW_SHRTCT="chromium.desktop"
elif [ "$BRW_ID" = "firefox" ] ; then
  BRW_NAME="Firefox"
  BRW_EXECUT="/usr/bin/firefox"
  BRW_SHRTCT="firefox.desktop"
elif [ "$BRW_ID" = "firefox-esr" ] ; then
  BRW_NAME="FirefoxESR"
  BRW_EXECUT="/usr/bin/firefox-esr"
  BRW_SHRTCT="firefox-esr.desktop"
elif [ "$BRW_ID" = "falkon" ] ; then
  BRW_NAME="Falkon"
  BRW_EXECUT="/usr/bin/falkon"
  BRW_SHRTCT="org.kde.falkon.desktop"
elif [ "$BRW_ID" = "palemoon" ] ; then
  BRW_NAME="Palemoon"
  BRW_EXECUT="/usr/bin/palemoon"
  BRW_SHRTCT="palemoon.desktop"
elif [ "$BRW_ID" = "vivaldi" ] ; then
  BRW_NAME="Vivaldi"
  BRW_EXECUT="/usr/bin/vivaldi-stable"
  BRW_SHRTCT="vivaldi-stable.desktop"
elif [ "$BRW_ID" = "edge" ] ; then
  BRW_NAME="Edge"
  BRW_EXECUT="/usr/bin/microsoft-edge"
  BRW_SHRTCT="microsoft-edge.desktop"
elif [ "$BRW_ID" = "konqueror4" ] ; then
  BRW_NAME="Konqueror4"
  BRW_EXECUT="/usr/bin/konqueror"
  BRW_SHRTCT="konqbrowser.desktop"
elif [ "$BRW_ID" = "konqueror3" ] ; then
  BRW_NAME="Konqueror3"
  BRW_EXECUT="/opt/trinity/bin/konqueror"
  BRW_SHRTCT="konqueror.desktop"
elif [ "$BRW_ID" = "_none_" ] ; then
  BRW_NAME="None"
  BRW_EXECUT="/bin/true"
  BRW_SHRTCT=""
else
  echo "[E]: $BRW_ID browser not known, exiting ..."
  exit 51
fi

if [ ! -x "$BRW_EXECUT" ] ; then
  echo "[E]: [$BRW_EXECUT] not executable, exiting ..."
  exit 52
fi

#user section:
if [ "$ASROOT" != "1" ] ; then
  echo "Setting [$BRW_NAME] as default web browser for user [$(whoami)] ..."
  # XDGCFGHOME_1="$HOME/.config"
  XDGCFGHOME_2="$(dash /usr/share/apps/q4os_system/bin/print_xdgcfghome_tde.sh)"
  XDGCFGHOME_3="$(dash /usr/share/apps/q4os_system/bin/print_xdgcfghome_plasma.sh)"
  if [ -n "$BRW_SHRTCT" ] ; then
    # XDG_CONFIG_HOME="$XDGCFGHOME_1" xdg-settings set default-web-browser "$BRW_SHRTCT"
    # XDG_CONFIG_HOME="$XDGCFGHOME_1" xdg-settings set default-url-scheme-handler http "$BRW_SHRTCT"
    # XDG_CONFIG_HOME="$XDGCFGHOME_1" xdg-settings set default-url-scheme-handler https "$BRW_SHRTCT"
    if [ "$XDGCFGHOME_2" != "$HOME/.config" ] ; then
      XDG_CONFIG_HOME="$XDGCFGHOME_2" xdg-settings set default-web-browser "kfmclient_html.desktop"
      XDG_CONFIG_HOME="$XDGCFGHOME_2" xdg-settings set default-url-scheme-handler http "kfmclient_html.desktop"
      XDG_CONFIG_HOME="$XDGCFGHOME_2" xdg-settings set default-url-scheme-handler https "kfmclient_html.desktop"
    fi
    if [ "$XDGCFGHOME_3" != "$HOME/.config" ] ; then
      XDG_CONFIG_HOME="$XDGCFGHOME_3" xdg-settings set default-web-browser "kfmclient_html.desktop"
      XDG_CONFIG_HOME="$XDGCFGHOME_3" xdg-settings set default-url-scheme-handler http "kfmclient_html.desktop"
      XDG_CONFIG_HOME="$XDGCFGHOME_3" xdg-settings set default-url-scheme-handler https "kfmclient_html.desktop"
    fi
  fi
  XDG_CONFIG_HOME="$XDGCFGHOME_2" /opt/trinity/bin/kwriteconfig --file "$HOME/.trinity/share/config/kdeglobals" --group 'General' --key 'BrowserApplication' "$BRW_SHRTCT"
  XDG_CONFIG_HOME="$XDGCFGHOME_3" /opt/trinity/bin/kwriteconfig --file "$XDGCFGHOME_3/kdeglobals" --group 'General' --key 'BrowserApplication' "$BRW_SHRTCT"
  exit
fi

#global settings section:
echo "Setting [$BRW_NAME] as a global web browser ..."
# if [ -n "$BRW_SHRTCT" ] ; then
#   xdg-settings set default-web-browser "$BRW_SHRTCT"
#   xdg-settings set default-url-scheme-handler http "$BRW_SHRTCT"
#   xdg-settings set default-url-scheme-handler https "$BRW_SHRTCT"
# fi
if [ "$BRW_EXECUT" != "/bin/true" ] ; then
  update-alternatives --set x-www-browser "$BRW_EXECUT"
fi
/opt/trinity/bin/kwriteconfig --file '/etc/trinity/kdeglobals' --group 'General' --key 'BrowserApplication' "$BRW_SHRTCT"
/opt/trinity/bin/kwriteconfig --file '/etc/xdm/kdeglobals' --group 'General' --key 'BrowserApplication' "$BRW_SHRTCT"
chmod a+r /etc/trinity/kdeglobals
chmod a+r /etc/xdm/kdeglobals

#first user section:
FIRST_USER="$( dash /usr/share/apps/q4os_system/bin/get_first_user.sh --name )"
XDGCFGHOME_FU_2="/home/$FIRST_USER/.configtde"
XDGCFGHOME_FU_3="$(dash /usr/share/apps/q4os_system/bin/print_xdgcfghome_plasma.sh "$FIRST_USER")"
# echo "First user: $FIRST_USER"
if [ -n "$FIRST_USER" ] ; then
  echo "Setting [$BRW_NAME] as default web browser for user [$FIRST_USER] ..."
  if [ -n "$BRW_SHRTCT" ] ; then
    # sudo -n -u "$FIRST_USER" XDG_CONFIG_HOME="/home/$FIRST_USER/.config" xdg-settings set default-web-browser "$BRW_SHRTCT"
    # sudo -n -u "$FIRST_USER" XDG_CONFIG_HOME="/home/$FIRST_USER/.config" xdg-settings set default-url-scheme-handler http "$BRW_SHRTCT"
    # sudo -n -u "$FIRST_USER" XDG_CONFIG_HOME="/home/$FIRST_USER/.config" xdg-settings set default-url-scheme-handler https "$BRW_SHRTCT"
    if [ "$XDGCFGHOME_FU_2" != "$HOME/.config" ] ; then
      sudo -n -u "$FIRST_USER" XDG_CONFIG_HOME="$XDGCFGHOME_FU_2" xdg-settings set default-web-browser "kfmclient_html.desktop"
      sudo -n -u "$FIRST_USER" XDG_CONFIG_HOME="$XDGCFGHOME_FU_2" xdg-settings set default-url-scheme-handler http "kfmclient_html.desktop"
      sudo -n -u "$FIRST_USER" XDG_CONFIG_HOME="$XDGCFGHOME_FU_2" xdg-settings set default-url-scheme-handler https "kfmclient_html.desktop"
    fi
    if [ "$XDGCFGHOME_FU_3" != "$HOME/.config" ] ; then
      sudo -n -u "$FIRST_USER" XDG_CONFIG_HOME="$XDGCFGHOME_FU_3" xdg-settings set default-web-browser "kfmclient_html.desktop"
      sudo -n -u "$FIRST_USER" XDG_CONFIG_HOME="$XDGCFGHOME_FU_3" xdg-settings set default-url-scheme-handler http "kfmclient_html.desktop"
      sudo -n -u "$FIRST_USER" XDG_CONFIG_HOME="$XDGCFGHOME_FU_3" xdg-settings set default-url-scheme-handler https "kfmclient_html.desktop"
    fi
  fi
  sudo -n -u "$FIRST_USER" XDG_CONFIG_HOME="$XDGCFGHOME_FU_2" /opt/trinity/bin/kwriteconfig --file "/home/$FIRST_USER/.trinity/share/config/kdeglobals" --group 'General' --key 'BrowserApplication' "$BRW_SHRTCT"
  sudo -n -u "$FIRST_USER" XDG_CONFIG_HOME="$XDGCFGHOME_FU_3" /opt/trinity/bin/kwriteconfig --file "$XDGCFGHOME_FU_3/kdeglobals" --group 'General' --key 'BrowserApplication' "$BRW_SHRTCT"
  # chown "$FIRST_USER:$FIRST_USER" "/home/$FIRST_USER/.trinity/share/config/kdeglobals"
  # chown "$FIRST_USER:$FIRST_USER" "$XDGCFGHOME_FU_3/kdeglobals"
fi
