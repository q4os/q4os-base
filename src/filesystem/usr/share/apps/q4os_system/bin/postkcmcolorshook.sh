#!/bin/sh
# todo: make all colors stuff in tde source code instead

CLR_SCH1="$1" #CLR_SCH1="$( kreadconfig --group="KDE" --key="colorScheme" )"
CLR_SCH0="$( kreadconfig --file "q4osrc" --group="General" --key="colorScheme_q4os_past" )"
if [ "$CLR_SCH1" = "$CLR_SCH0" ] ; then
  #colors has not changed, so exit
  exit
fi

# # fixing tde bug - no all colors are applied into start or kickoff menu
# if [ "$( kreadconfig --file="kickerrc" --group="General" --key="LegacyKMenu" )" = "false" ] ; then
#   dcop kicker kicker restart
# else
#   if [ "$( kreadconfig --group="General" --key="widgetStyle" )" = "q4os_tstyle01" ] ; then
#     dcop kicker kicker restart
#   else
#     dcop kicker kicker configure
#   fi
# fi
# dcop kicker kicker restart
dcop kicker kicker quit

# set gtk3 colors for apps
dash /usr/share/apps/q4os_system/bin/colorize_gtk3.sh

# set gtk2 colors for google chrome frame
# .. only chromium uses gtk2 at the moment, google-chrome doesn't use gtk2 anymore, remove later
if [ -f "/program_files/google-chrome-q4/bin/colorize_gchr_frame.dash" ] ; then
  dash /program_files/google-chrome-q4/bin/colorize_gchr_frame.dash
fi
if [ -f "/opt/program_files/google-chrome-q4/bin/colorize_gchr_frame.dash" ] ; then
  dash /opt/program_files/google-chrome-q4/bin/colorize_gchr_frame.dash
fi
if [ -f "/opt/program_files/q4os-chromium/bin/colorize_gchr_frame.dash" ] ; then
  dash /opt/program_files/q4os-chromium/bin/colorize_gchr_frame.dash
fi

/opt/trinity/bin/kicker
dcop kicker kicker configure #for sure
dcop kicker SystemTrayApplet iconSizeChanged #for sure
