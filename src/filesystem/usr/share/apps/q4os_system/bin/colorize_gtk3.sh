#!/bin/sh

get_tde_hex_color () {
  #local COLOR1="$( cat $HOME/.trinity/share/config/kdeglobals | grep "^$1=" | awk -F= '{print $2}' )"
  local COLOR1="$( /opt/trinity/bin/kreadconfig --file="$3" --group="$2" --key="$1" )"

  if [ -z "$COLOR1" ] ; then
    echo ""
    return 0
  fi

  local A_IN1=$( echo $COLOR1 | awk -F, '{print $1}' )
  local A_IN2=$( echo $COLOR1 | awk -F, '{print $2}' )
  local A_IN3=$( echo $COLOR1 | awk -F, '{print $3}' )
  local A_OUT1=$( printf "%02x\n" $A_IN1 )
  local A_OUT2=$( printf "%02x\n" $A_IN2 )
  local A_OUT3=$( printf "%02x\n" $A_IN3 )
  # local A_OUT1=$( echo "scale=3; $A_IN1/255.1" | bc -l )
  # local A_OUT2=$( echo "scale=3; $A_IN2/255.1" | bc -l )
  # local A_OUT3=$( echo "scale=3; $A_IN3/255.1" | bc -l )

  echo "${A_OUT1}${A_OUT2}${A_OUT3}"
  return 0
}

XDGCFGHOMEPATH="$( dash /usr/share/apps/q4os_system/bin/print_xdgcfghome_tde.sh )"
if [ -f "$XDGCFGHOMEPATH/gtk-3.0/settings_trinity.ini" ] ; then
  CFG_FILE1="settings_trinity.ini"
else
  CFG_FILE1="settings.ini"
fi
if [ -n "$( cat $XDGCFGHOMEPATH/gtk-3.0/$CFG_FILE1 | grep 'gtk-theme-name=' | grep -v '^#' | grep 'Q4OS01' )" ] ; then
  C_THEME="Q4OS01"
fi
if [ -n "$( cat $XDGCFGHOMEPATH/gtk-3.0/$CFG_FILE1 | grep 'gtk-theme-name=' | grep -v '^#' | grep 'Q4OS02' )" ] ; then
  C_THEME="Q4OS02"
fi
if [ -z "$C_THEME" ] ; then
  exit 10
fi

GTKRCFILE="$HOME/.themes/$C_THEME/gtk-3.0/gtk.css"
mkdir -p "$( dirname $GTKRCFILE )"
cp /usr/share/apps/q4os_system/share/gtk3rc_template "$GTKRCFILE"
sed -i "s:_subst_theme_name_:$C_THEME:" $GTKRCFILE

#substitue colors, fallback to default q4os theme, if color not found
COLOR2="$( get_tde_hex_color "windowBackground" "General" "kdeglobals" )"
if [ -z "$COLOR2" ] ; then COLOR2="ffffff" ; fi
sed -i "s:_subst_theme_base_color_:$COLOR2:" $GTKRCFILE
COLOR2="$( get_tde_hex_color "background" "General" "kdeglobals" )"
if [ -z "$COLOR2" ] ; then COLOR2="e9e9e9" ; fi
sed -i "s:_subst_theme_bg_color_:$COLOR2:" $GTKRCFILE
COLOR2="$( get_tde_hex_color "foreground" "General" "kdeglobals" )"
if [ -z "$COLOR2" ] ; then COLOR2="000000" ; fi
sed -i "s:_subst_theme_fg_color_:$COLOR2:" $GTKRCFILE
COLOR2="$( get_tde_hex_color "selectBackground" "General" "kdeglobals" )"
if [ -z "$COLOR2" ] ; then COLOR2="ffdd76" ; fi
sed -i "s:_subst_selected_bg_color_:$COLOR2:" $GTKRCFILE
COLOR2="$( get_tde_hex_color "selectForeground" "General" "kdeglobals" )"
if [ -z "$COLOR2" ] ; then COLOR2="030303" ; fi
sed -i "s:_subst_selected_fg_color_:$COLOR2:" $GTKRCFILE
COLOR2="$( get_tde_hex_color "linkColor" "General" "kdeglobals" )"
if [ -z "$COLOR2" ] ; then COLOR2="0000c0" ; fi
sed -i "s:_subst_link_color_:$COLOR2:" $GTKRCFILE
COLOR2="$( get_tde_hex_color "visitedLinkColor" "General" "kdeglobals" )"
if [ -z "$COLOR2" ] ; then COLOR2="800080" ; fi
sed -i "s:_subst_visited_link_color_:$COLOR2:" $GTKRCFILE
COLOR2="$( get_tde_hex_color "activeBackground" "WM" "kdeglobals" )"
if [ -z "$COLOR2" ] ; then COLOR2="97adc3" ; fi
sed -i "s:_subst_active_title_bar_color_:$COLOR2:" $GTKRCFILE
COLOR2="$( get_tde_hex_color "inactiveBackground" "WM" "kdeglobals" )"
if [ -z "$COLOR2" ] ; then COLOR2="d2d2d2" ; fi
sed -i "s:_subst_inactive_title_bar_color_:$COLOR2:" $GTKRCFILE
COLOR2="$( get_tde_hex_color "activeForeground" "WM" "kdeglobals" )"
if [ -z "$COLOR2" ] ; then COLOR2="ffffff" ; fi
sed -i "s:_subst_active_title_text_color_:$COLOR2:" $GTKRCFILE
COLOR2="$( get_tde_hex_color "inactiveForeground" "WM" "kdeglobals" )"
if [ -z "$COLOR2" ] ; then COLOR2="ffffff" ; fi
sed -i "s:_subst_inactive_title_text_color_:$COLOR2:" $GTKRCFILE
