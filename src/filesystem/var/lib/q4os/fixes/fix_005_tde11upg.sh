#!/bin/sh

echo "Removing TDE diversions ..."
dpkg-divert --rename --remove /opt/trinity/share/services/zip.protocol
dpkg-divert --rename --remove /opt/trinity/share/applications/tde/kamera.desktop
dpkg-divert --rename --remove /opt/trinity/share/applications/tde/k3b.desktop
dpkg-divert --rename --remove /opt/trinity/share/apps/ksplash/Themes/TDE-Classic/splash_bottom.png
dpkg-divert --rename --remove /opt/trinity/share/apps/ksplash/Themes/TDE-Classic/splash_top.png
dpkg-divert --rename --remove /opt/trinity/bin/kfile
dpkg-divert --rename --remove /opt/trinity/bin/kpersonalizer
dpkg-divert --rename --remove /opt/trinity/bin/kcontrol
dpkg-divert --rename --remove /usr/share/applications/panel-desktop-handler.desktop
if dash /usr/share/apps/q4os_system/bin/print_package_version.sh "q4os-desktop-trinity" ; then
  dpkg-divert --package q4os-desktop-trinity --divert /usr/share/applications/.panel-desktop-handler.desktop.diverted --rename /usr/share/applications/panel-desktop-handler.desktop
fi

DPIV2="$( /opt/trinity/bin/kreadconfig --file "/etc/trinity/q4osrc" --group "Screen" --key "force_screen_dpi" --default "" )"
if [ -n "$DPIV2" ] ; then
  echo "Trinity DPI: ${DPIV2}. Transiting configuration ..."
  dash /usr/share/apps/q4os_system/bin/dpi_set.sh "$DPIV2"
fi
