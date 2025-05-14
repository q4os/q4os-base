#!/bin/sh

if [ -z "$1" ] ; then
  echo "Need a dpi argument, exiting ..."
  exit 110
fi
[ -n "$1" ] && [ "$1" -eq "$1" ] 2>/dev/null
if [ $? -ne "0" ]; then
  echo "Dpi argument is not a number, exiting ..."
  exit 111
fi
# if [ "$1" -lt "64" ] || [ "$1" -gt "512" ] ; then
#   echo "Dpi argument out of range, exiting ..."
#   exit 112
# fi

if [ "$( id -u )" = "0" ] ; then
  ASROOT="1"
fi

if [ "$1" = "0" ] ; then
  FFDPI="false"
  DPI_VALUE=""
else
  FFDPI="true"
  DPI_VALUE="$1"
fi

if [ "$ASROOT" = "1" ] ; then
  /opt/trinity/bin/kwriteconfig --file "/etc/trinity/kcmfonts" --group "General" --key "forceFontDPIEnable" "$FFDPI"
  /opt/trinity/bin/kwriteconfig --file "/etc/trinity/kcmfonts" --group "General" --key "forceFontDPI" "$DPI_VALUE"
  chmod a+r /etc/trinity/kcmfonts
  /opt/trinity/bin/kwriteconfig --file "/etc/trinity/q4osrc" --group "Screen" --key "force_screen_dpi" "$DPI_VALUE"
  chmod a+r /etc/trinity/q4osrc
else
  /opt/trinity/bin/kwriteconfig --file "kcmfonts" --group "General" --key "forceFontDPIEnable" "$FFDPI"
  /opt/trinity/bin/kwriteconfig --file "kcmfonts" --group "General" --key "forceFontDPI" "$DPI_VALUE"
  /opt/trinity/bin/kwriteconfig --file "q4osrc" --group "Screen" --key "force_screen_dpi" "$DPI_VALUE"
  if [ -z "$DPI_VALUE" ] ; then
    #remove entries from user's config to enable kreadconfig to read the global one
    sed -i '/^forceFontDPIEnable=/d' "$HOME/.trinity/share/config/kcmfonts"
    sed -i '/^forceFontDPI=/d' "$HOME/.trinity/share/config/kcmfonts"
    sed -i '/^force_screen_dpi=/d' "$HOME/.trinity/share/config/q4osrc"
  fi
fi
