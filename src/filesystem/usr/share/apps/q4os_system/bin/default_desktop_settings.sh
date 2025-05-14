#!/bin/sh

echo
if [ "$QDSK_SESSION" = "trinity" ] ; then
  echo "This script will revert default desktop user settings."
else
  echo "This script is applicable for Trinity desktop only, exiting ..."
  exit 10
fi
read -p "Press \"Ctrl+C\" to cancel, \"Enter\" to continue ..." XYZ

ln -f -s /usr/share/applications/q4os-welcome-screen.desktop $(dash /usr/share/apps/q4os_system/bin/print_xdgcfghome_tde.sh)/autostart/q4os-welcome-screen.desktop

LSWSCR="$HOME/.trinity/shutdown/defdesksett.sh"
mkdir -p $HOME/.trinity/shutdown
echo "#/bin/sh" > $LSWSCR
echo "THQ_THNAME=Q4OS_Default ktheme_setter" >> $LSWSCR
echo "rm -f $LSWSCR" >> $LSWSCR
chmod +x $LSWSCR

echo "Done, login again please."
