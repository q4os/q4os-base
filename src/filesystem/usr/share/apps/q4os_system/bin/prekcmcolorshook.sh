#!/bin/sh

CLR_SCH="$( kreadconfig --group="KDE" --key="colorScheme" )"
kwriteconfig --file "q4osrc" --group="General" --key="colorScheme_q4os_past" "$CLR_SCH"
