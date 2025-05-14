#!/bin/sh

#arguments:
#$1 = font family name
#$2 font point size

# tde bugfix - kcm fonts deletes gtkrc files, remove bugfix if repaired by upstream
mv $HOME/.trinity/share/config/gtkrc.prekcmfonts $HOME/.trinity/share/config/gtkrc
mv $HOME/.trinity/share/config/gtkrc-2.0.prekcmfonts $HOME/.trinity/share/config/gtkrc-2.0

#set gtk fonts
if [ -f "$HOME/.gtkrc-q4os" ] ; then
  sed -i "s@^  font_name=.*@  font_name=\"$1\"@" $HOME/.gtkrc-q4os
  sed -i "s@^gtk-font-name=.*@gtk-font-name=\"$1 $2\"@" $HOME/.gtkrc-q4os
fi
if [ -f "$HOME/.gtkrc-q4os-kde4" ] ; then
  sed -i "s@^  font_name=.*@  font_name=\"$1\"@" $HOME/.gtkrc-q4os-kde4
  sed -i "s@^gtk-font-name=.*@gtk-font-name=\"$1 $2\"@" $HOME/.gtkrc-q4os-kde4
fi
XDGCFGHOMEPATH="$( dash /usr/share/apps/q4os_system/bin/print_xdgcfghome_tde.sh )"
if [ -f "$XDGCFGHOMEPATH/gtk-3.0/settings_trinity.ini" ] ; then
  CFG_FILE1="settings_trinity.ini"
else
  CFG_FILE1="settings.ini"
fi
if [ -f "$XDGCFGHOMEPATH/gtk-3.0/$CFG_FILE1" ] ; then
  kwriteconfig --file "$XDGCFGHOMEPATH/gtk-3.0/$CFG_FILE1" --group "Settings" --key "gtk-font-name" "$1 $2"
fi

#todo: set qt4/5, google-chrome, wine and other fonts
