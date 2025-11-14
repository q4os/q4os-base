#!/bin/sh
#source this script from starttde
#set dpi for trinity/q4os

# if dpkg --compare-versions "$( /opt/trinity/bin/kreadconfig --file "/etc/q4os/q4base.conf" --group "OnInstall" --key "q4osbase_version" )" lt "3.7" ; then
#   ...code...
# fi

if dpkg --compare-versions "$( dash /usr/share/apps/q4os_system/bin/print_package_version.sh "tdebase-trinity" )" lt "4:14.0.11-0debian11.0.0+0" ; then
  Q4DPI="$( /opt/trinity/bin/kreadconfig --file "q4osrc" --group "Screen" --key "force_screen_dpi" )"
else
  # if [ ! -f "$HOME/.local/share/q4os/.movedpitde11.stp" ] ; then
  #   #transition from tde 14.0.10 to 14.0.11, one-shot only
  #   #keep this transition code for bullseye remove for following distros
  #   MOVE_DPI1="$( /opt/trinity/bin/kreadconfig --file "q4osrc" --group "Screen" --key "force_screen_dpi" )"
  #   if [ -n "$MOVE_DPI1" ] ; then
  #     dash /usr/share/apps/q4os_system/bin/dpi_set.sh "$MOVE_DPI1"
  #   fi
  #   unset MOVE_DPI1
  #   touch "$HOME/.local/share/q4os/.movedpitde11.stp"
  # fi
  if /opt/trinity/bin/kreadconfig --file "kcmfonts" --group "General" --key "forceFontDPIEnable" --type "bool" --default "false" ; then
    Q4DPI="$( /opt/trinity/bin/kreadconfig --file "kcmfonts" --group "General" --key "forceFontDPI" --default "" )"
  fi
fi

if [ -z "$Q4DPI" ] ; then
  Q4DPI="$( q4hw-info --probe-dpi | tail -n1 )"
  echo "screen resolution detected: $Q4DPI"
  if [ -z "$Q4DPI" ] ; then
    Q4DPI="96"
  elif [ "$Q4DPI" -lt "30" ] ; then
    Q4DPI="96"
  elif [ "$Q4DPI" -gt "92" ] && [ "$Q4DPI" -lt "100" ] ; then
    Q4DPI="96"
  elif [ "$Q4DPI" -gt "116" ] && [ "$Q4DPI" -lt "124" ] ; then
    Q4DPI="120"
  elif [ "$Q4DPI" -gt "140" ] && [ "$Q4DPI" -lt "148" ] ; then
    Q4DPI="144"
  fi
fi
echo "screen resolution: $Q4DPI"

xrandr --dpi $Q4DPI

#todo: check debian bug - dpi is hardcoded sometimes, ? by xorg drivers ?
#re-set dpi for Xft:
xrdb -quiet -merge -nocpp <<EOF
Xft.dpi: $Q4DPI
EOF

#todo: investigate and consider to set "Xft.dpi: a_value_of_q4dpi" in "~/.Xresources"

if [ "$Q4DPI" = "96" ] ; then
  unset Q4DPI
else
  export Q4DPI
fi
