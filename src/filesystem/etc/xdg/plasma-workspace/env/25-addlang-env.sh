#first login language setting
if [ -f "$HOME/.addlangenv.sh" ] ; then
  . /usr/share/apps/q4os_system/bin/exportlang.sh
  # dbus-update-activation-environment --systemd LANG #check: do we need that ?
  rm -f $HOME/.addlangenv.sh
fi
