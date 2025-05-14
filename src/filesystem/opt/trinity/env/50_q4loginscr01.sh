#!/bin/sh
#source this script from starttde

# q4os specific variables
export Q4KDEHOME="$HOME/.trinity" # $( tde-config --localprefix )
export Q4DESKTOP="tde14"

export XAUTHORITY="$HOME/.Xauthority" #for sudo commands

#xdg dirs
export QDSK_SESSION="trinity"
# export DESKTOP_SESSION="trinity"
# export XDG_SESSION_DESKTOP="Trinity"
export XDG_CURRENT_DESKTOP="Trinity" #for firefox titlebar
# export XDG_CONFIG_DIRS="$HOME/.q4data:$XDG_CONFIG_DIRS"
# export XDG_DATA_DIRS=/var/lib/menu-xdg/simplified:/usr/share
export XDG_CONFIG_HOME="$(dash /usr/share/apps/q4os_system/bin/print_xdgcfghome_tde.sh)"

#these variables defines gtk apps look ; todo: it may be removed when gtk-qt-engine-trinity is installed ?
export GTK2_RC_FILES=$HOME/.gtkrc-q4os:$Q4KDEHOME/share/config/gtkrc-2.0
export GTK_RC_FILES=/etc/gtk/gtkrc:$HOME/.gtkrc:$Q4KDEHOME/share/config/gtkrc

#for QT4 lib
export KDE_SESSION_VERSION="3"
# export QT_PLATFORM_PLUGIN="kde" #not needed ?, removed 2017-01-19
# export KDEHOME="$HOME/.trinity" #don't set, as kde4 apps, like gwenview, could write something to and mess it.
# export KDE_FULL_SESSION="true" #don't set, as kde4 apps would get settings from '~/.kde' dir

#for QT5 lib
# export QT_STYLE_OVERRIDE="gtk"
# unset QT_STYLE_OVERRIDE
export QT_QPA_PLATFORMTHEME="q4ostde" #platform plugin to set complete theme to follow - icons/fonts/colors/style/etc..

#some other variables
# export KDEDIRS=$HOME/.userapps/kde3:$KDEDIRS
# export LD_LIBRARY_PATH=$HOME/.userapps/kde3/lib/kde3/plugins/styles:$LD_LIBRARY_PATH
# export PATH=$HOME/.userapps/app1/bin:$PATH
