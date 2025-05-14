#!/bin/bash

#read, modify and write keyboard configuration, system and user wide
#read /etc/q4os/q4base.conf, or debian's /etc/default/keyboard, or /etc/X11/xorg.conf.d/00-keyboard.conf, or guess from $LANG
#pick any non "us" layout if present, else "us"
#output - add us keyboard and print modified values for system and trinity kxkbrc

echo "Running keyboard configuration script, arg ["$1"], user ["$(id -un)"] ..."

#--------------------------------------------------------------
#section-1: read values
#
#read debian's /etc/default/keyboard, or /etc/X11/xorg.conf.d/00-keyboard.conf, or guess from $LANG
#--------------------------------------------------------------
KB_READ_LAYOUT="$KB_SYS_LAYOUT"
KB_READ_VARIANT="$KB_SYS_VARIANT"
KB_READ_OPTIONS="$KB_SYS_OPTIONS"
KB_READ_MODEL="$KB_SYS_MODEL"

if [ -z "$KB_READ_LAYOUT" ] ; then
  SYSCFGFL3="/etc/q4os/q4base.conf"
  echo "Reading: $SYSCFGFL3"
  KB_READ_LAYOUT="$( /opt/trinity/bin/kreadconfig --file "$SYSCFGFL3" --group "OnInstall" --key "kxkblayout" )"
  KB_READ_VARIANT="$( /opt/trinity/bin/kreadconfig --file "$SYSCFGFL3" --group "OnInstall" --key "kxkbvariant" )"
  KB_READ_OPTIONS="$( /opt/trinity/bin/kreadconfig --file "$SYSCFGFL3" --group "OnInstall" --key "kxkboptions" )"
  KB_READ_MODEL="$( /opt/trinity/bin/kreadconfig --file "$SYSCFGFL3" --group "OnInstall" --key "kxkbmodel" )"

  if [ -z "$KB_READ_LAYOUT" ] ; then
    SYSCFGFL1="/etc/default/keyboard"
    echo "Reading: $SYSCFGFL1"
    KB_READ_LAYOUT="$( /opt/trinity/bin/kreadconfig --file "$SYSCFGFL1" --group "" --key "XKBLAYOUT" | tr -d '"' )"
    KB_READ_VARIANT="$( /opt/trinity/bin/kreadconfig --file "$SYSCFGFL1" --group "" --key "XKBVARIANT" | tr -d '"' )"
    KB_READ_OPTIONS="$( /opt/trinity/bin/kreadconfig --file "$SYSCFGFL1" --group "" --key "XKBOPTIONS" | tr -d '"' )"
    KB_READ_MODEL="$( /opt/trinity/bin/kreadconfig --file "$SYSCFGFL1" --group "" --key "XKBMODEL" | tr -d '"' )"

    if [ -z "$KB_READ_LAYOUT" ] ; then
      SYSCFGFL2="/etc/X11/xorg.conf.d/00-keyboard.conf"
      echo "Reading: $SYSCFGFL2"
      KB_READ_LAYOUT="$( cat "$SYSCFGFL2" | grep 'XkbLayout' | head -n1 | tr -d '"' | awk -F' ' '{ print $3 }' )"
      KB_READ_VARIANT="$( cat "$SYSCFGFL2" | grep 'XkbVariant' | head -n1 | tr -d '"' | awk -F' ' '{ print $3 }' )"
      KB_READ_OPTIONS="$( cat "$SYSCFGFL2" | grep 'XkbOptions' | head -n1 | tr -d '"' | awk -F' ' '{ print $3 }' )"
      KB_READ_MODEL="$( cat "$SYSCFGFL2" | grep 'XkbModel' | head -n1 | tr -d '"' | awk -F' ' '{ print $3 }' )"

      if [ -z "$KB_READ_LAYOUT" ] ; then
        echo "Probing lang env: $LANG"
        KB_READ_LAYOUT="$( dash /usr/share/apps/q4os_system/bin/dowqi18.sh "--print-tdecode" "$LANG" | grep "^Keyboard_Code: " | awk -F': ' '{ print $2 }' )"
        KB_READ_VARIANT=""
        KB_READ_OPTIONS=""
        KB_READ_MODEL=""

        if [ -z "$KB_READ_LAYOUT" ] ; then
          echo "Fallback: us"
          KB_READ_LAYOUT="us"
          KB_READ_VARIANT=""
          KB_READ_OPTIONS=""
          KB_READ_MODEL=""
        fi
      fi
    fi
  fi
fi
echo "Init_read_layout: $KB_READ_LAYOUT"

#pick any non "us" layout if present, else "us"
HLP_LYT_1="$( echo "$KB_READ_LAYOUT" | awk -F',' '{ print $1 }' )"
HLP_LYT_2="$( echo "$KB_READ_LAYOUT" | awk -F',' '{ print $2 }' )"
if [ -n "$HLP_LYT_1" ] && [ "$HLP_LYT_1" != "us" ] ; then
  KB_READ_LAYOUT="$HLP_LYT_1"
  KB_READ_VARIANT="$( echo "$KB_READ_VARIANT" | awk -F',' '{ print $1 }' )"
elif [ -n "$HLP_LYT_2" ] && [ "$HLP_LYT_2" != "us" ] ; then
  KB_READ_LAYOUT="$HLP_LYT_2"
  KB_READ_VARIANT="$( echo "$KB_READ_VARIANT" | awk -F',' '{ print $2 }' )"
elif [ "$HLP_LYT_1" = "us" ] ; then
  KB_READ_LAYOUT="us"
  KB_READ_VARIANT="$( echo "$KB_READ_VARIANT" | awk -F',' '{ print $1 }' )"
elif [ "$HLP_LYT_2" = "us" ] ; then
  KB_READ_LAYOUT="us"
  KB_READ_VARIANT="$( echo "$KB_READ_VARIANT" | awk -F',' '{ print $2 }' )"
else
  KB_READ_LAYOUT="us"
  KB_READ_VARIANT=""
fi

echo "Read [system]:"
echo " read_layout:  $KB_READ_LAYOUT"
echo " read_variant: $KB_READ_VARIANT"
echo " read_options: $KB_READ_OPTIONS"
echo " read_model:   $KB_READ_MODEL"


#--------------------------------------------------------------
#section-2: calculate new values
#
#calculate output: add us keyboard and print modified values for system and trinity kxkbrc
#--------------------------------------------------------------
if [ -n "$KB_READ_VARIANT" ] ; then
  HLP_LAYVARTDE="$KB_READ_LAYOUT($KB_READ_VARIANT)"
else
  HLP_LAYVARTDE="$KB_READ_LAYOUT"
fi

case "$KB_READ_LAYOUT" in
  us)
    KB_TDELIVE_LAYOUT="$HLP_LAYVARTDE"
    KB_TDE_LAYOUT="$HLP_LAYVARTDE"
    KB_PLASMA_LAYOUT="$KB_READ_LAYOUT"
    KB_PLASMA_VARIANT="$KB_READ_VARIANT"
    KB_SYS_WRITE_LAYOUT="$KB_READ_LAYOUT"
    KB_SYS_WRITE_VARIANT="$KB_READ_VARIANT"
  ;;
  de|es|gb|fr|pt|it|dk|ch|cz|sk|pl|br|fi|hr|hu|ie|is|nl|no|ro|se|si|be|lv)
    KB_TDELIVE_LAYOUT="$HLP_LAYVARTDE,us"
    KB_TDE_LAYOUT="$HLP_LAYVARTDE"
    KB_PLASMA_LAYOUT="$KB_READ_LAYOUT"
    KB_PLASMA_VARIANT="$KB_READ_VARIANT"
    KB_SYS_WRITE_LAYOUT="$KB_READ_LAYOUT,us"
    KB_SYS_WRITE_VARIANT="$KB_READ_VARIANT"
    FLG1_TGGL="1"
  ;;
  *)
    KB_TDELIVE_LAYOUT="us,$HLP_LAYVARTDE"
    KB_TDE_LAYOUT="$HLP_LAYVARTDE,us"
    KB_PLASMA_LAYOUT="$KB_READ_LAYOUT,us"
    KB_PLASMA_VARIANT="$KB_READ_VARIANT"
    KB_SYS_WRITE_LAYOUT="us,$KB_READ_LAYOUT"
    if [ -n "$KB_READ_VARIANT" ] ; then
      KB_SYS_WRITE_VARIANT=",$KB_READ_VARIANT"
    fi
    FLG1_TGGL="1"
  ;;
esac

#set out kb_options
KB_SYS_WRITE_OPTIONS="$KB_READ_OPTIONS"
if [ "$FLG1_TGGL" = "1" ] ; then
  if [ -z "$KB_SYS_WRITE_OPTIONS" ] ; then
    KB_SYS_WRITE_OPTIONS="grp:alt_shift_toggle"
  elif echo "$KB_SYS_WRITE_OPTIONS" | grep -q 'grp:alt_shift_toggle' ; then
    echo > /dev/null
  else
    KB_SYS_WRITE_OPTIONS="$KB_SYS_WRITE_OPTIONS,grp:alt_shift_toggle"
  fi
fi

#set out kb_model
KB_SYS_WRITE_MODEL="$KB_READ_MODEL"
if [ -z "$KB_SYS_WRITE_MODEL" ] ; then
  KB_SYS_WRITE_MODEL="pc105"
fi

echo "Output [system]:"
echo " calc_sys_layout:  $KB_SYS_WRITE_LAYOUT"
echo " calc_sys_variant: $KB_SYS_WRITE_VARIANT"
echo " calc_sys_options: $KB_SYS_WRITE_OPTIONS"
echo " calc_sys_model:   $KB_SYS_WRITE_MODEL"
echo "Output [user]:"
echo " calc_tdelive_kxkb_layout: $KB_TDELIVE_LAYOUT"
echo " calc_tde_kxkb_layout:     $KB_TDE_LAYOUT"
echo " calc_plasma_kxkb_layout:  $KB_PLASMA_LAYOUT"
echo " calc_plasma_kxkb_variant: $KB_PLASMA_VARIANT"

if [ -z "$1" ] || [ "$1" = "--only-show" ] ; then
  exit
fi


#--------------------------------------------------------------
#section-3: write to desired locations according to $1 argument
#--------------------------------------------------------------
if [ "$1" = "--write-sys" ] ; then
  #need to be root
  echo "Writing system keyboard configuration [$1] .."
  # SYSCFGFLW="/etc/X11/xorg.conf.d/00-keyboard.conf"
  # if [ -f "$SYSCFGFLW" ] ; then
  #   sed -i "s/.*Option.*XkbLayout.*/        Option \"XkbLayout\" \"$KB_SYS_WRITE_LAYOUT\"/" $SYSCFGFLW
  #   sed -i "s/.*Option.*XkbVariant.*/        Option \"XkbVariant\" \"$KB_SYS_WRITE_VARIANT\"/" $SYSCFGFLW
  #   sed -i "s/.*Option.*XkbModel.*/        Option \"XkbModel\" \"$KB_SYS_WRITE_MODEL\"/" $SYSCFGFLW
  # fi
  SYSCFGFL4="/etc/default/keyboard"
  if [ -f "$SYSCFGFL4" ] ; then
    echo "Writing to $SYSCFGFL4 ..."
    sed -i "s/^XKBLAYOUT=.*/XKBLAYOUT=\"$KB_SYS_WRITE_LAYOUT\"/" $SYSCFGFL4
    sed -i "s/^XKBVARIANT=.*/XKBVARIANT=\"$KB_SYS_WRITE_VARIANT\"/" $SYSCFGFL4
    sed -i "s/^XKBOPTIONS=.*/XKBOPTIONS=\"$KB_SYS_WRITE_OPTIONS\"/" $SYSCFGFL4
    sed -i "s/^XKBMODEL=.*/XKBMODEL=\"$KB_SYS_WRITE_MODEL\"/" $SYSCFGFL4
  fi
  SYSCFGFL5="/etc/q4os/q4base.conf"
  if [ -z "$(/opt/trinity/bin/kreadconfig --file "$SYSCFGFL5" --group "OnInstall" --key "kxkblayout")" ] || [ "$FORCE_WRITE_Q4BASE" = "1" ] ; then
    echo "Writing to $SYSCFGFL5 ..."
    /opt/trinity/bin/kwriteconfig --file "$SYSCFGFL5" --group "OnInstall" --key "kxkblayout" "$KB_READ_LAYOUT"
    /opt/trinity/bin/kwriteconfig --file "$SYSCFGFL5" --group "OnInstall" --key "kxkbvariant" "$KB_READ_VARIANT"
    /opt/trinity/bin/kwriteconfig --file "$SYSCFGFL5" --group "OnInstall" --key "kxkboptions" "$KB_READ_OPTIONS"
    /opt/trinity/bin/kwriteconfig --file "$SYSCFGFL5" --group "OnInstall" --key "kxkbmodel" "$KB_READ_MODEL"
    chmod a+r "$SYSCFGFL5"
  fi

elif [ "$1" = "--write-tdelive" ] ; then
  echo "Writing user keyboard configuration for live media  [$1] .."
  FLAG_TDE_KXKBW="1"
  echo "Writing to kxkbrc ..."
  /opt/trinity/bin/kwriteconfig --file "kxkbrc" --group "Layout" --key "LayoutList" "$KB_TDELIVE_LAYOUT"
  /opt/trinity/bin/kwriteconfig --file "kxkbrc" --group "Layout" --key "Model" "$KB_SYS_WRITE_MODEL"
  # /opt/trinity/bin/kwriteconfig --file "kxkbrc" --group "Layout" --key "Use" "true"

elif [ "$1" = "--write-tdeconfig" ] ; then
  echo "Writing trinity keyboard configuration [$1] .."
  KXKB_CFGFL_1="$HOME/.trinity/share/config/kxkbrc"
  echo "  config file: $KXKB_CFGFL_1"
  if [ -n "$KB_TDE_LAYOUT" ] ; then
    FLAG_TDE_KXKBW="1"
    echo "Writing to $KXKB_CFGFL_1 ..."
    /opt/trinity/bin/kwriteconfig --file "$KXKB_CFGFL_1" --group "Layout" --key "LayoutList" "$KB_TDE_LAYOUT"
    /opt/trinity/bin/kwriteconfig --file "$KXKB_CFGFL_1" --group "Layout" --key "Use" "true"
    if [ -n "$KB_SYS_WRITE_MODEL" ] ; then
      /opt/trinity/bin/kwriteconfig --file "$KXKB_CFGFL_1" --group "Layout" --key "Model" "$KB_SYS_WRITE_MODEL"
    fi
    chmod a+r "$KXKB_CFGFL_1"
  fi

elif [ "$1" = "--write-plasmaconfig" ] ; then
  echo "Writing plasma keyboard configuration [$1] .."
  KXKB_CFGFL_2="$(dash /usr/share/apps/q4os_system/bin/print_xdgcfghome_plasma.sh)/kxkbrc"
  echo "Writing to $KXKB_CFGFL_2 ..."
  /opt/trinity/bin/kwriteconfig --file "$KXKB_CFGFL_2" --group "Layout" --key "LayoutList" "$KB_PLASMA_LAYOUT"
  /opt/trinity/bin/kwriteconfig --file "$KXKB_CFGFL_2" --group "Layout" --key "VariantList" "$KB_PLASMA_VARIANT"
  /opt/trinity/bin/kwriteconfig --file "$KXKB_CFGFL_2" --group "Layout" --key "Use" "true"
  if [ -n "$KB_SYS_WRITE_MODEL" ] ; then
    /opt/trinity/bin/kwriteconfig --file "$KXKB_CFGFL_2" --group "Layout" --key "Model" "$KB_SYS_WRITE_MODEL"
  fi
  chmod a+r "$KXKB_CFGFL_2"
  echo "Running setxkbmap: layout-$KB_PLASMA_LAYOUT, variant-$KB_PLASMA_VARIANT, model-$KB_SYS_WRITE_MODEL ..."
  setxkbmap -layout "$KB_PLASMA_LAYOUT" -variant "$KB_PLASMA_VARIANT" -model "$KB_SYS_WRITE_MODEL"

else
  echo "No write action issued."

fi

if [ "$FLAG_TDE_KXKBW" = "1" ] ; then
  if dcopfind kxkb ; then
    echo "Restarting dcop kxkb .."
    # dcop kxkb kxkb setLayout $1
    dcopquit kxkb
    sleep 0.1
    dcopstart kxkb
  fi
fi
