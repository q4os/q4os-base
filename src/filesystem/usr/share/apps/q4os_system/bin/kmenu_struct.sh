#!/bin/sh

XDGCFG_HOME1="$( dash /usr/share/apps/q4os_system/bin/print_xdgcfghome_tde.sh )"
if [ -f "$XDGCFG_HOME1/menus/tde-applications.menu" ] ; then
  CURRENT_MENUTYPE1="q4os"
else
  CURRENT_MENUTYPE1="tde"
fi

if [ "$1" = "--q4os" ] ; then
  ACTON="1"
  if [ "$CURRENT_MENUTYPE1" = "q4os" ] ; then
    echo "Looks like the Q4OS menu structure is already set. No action taken."
    exit 10
  else
    # rm -f $HOME/.local/share/applications/q4os-user-controlpanel.desktop
    cd $XDGCFG_HOME1/menus/
    ln -s /usr/share/apps/q4os_system/share/tde-applications1.menu tde-applications.menu
  fi
fi

if [ "$1" = "--tde" ] ; then
  ACTON="1"
  if [ "$CURRENT_MENUTYPE1" = "tde" ] ; then
    echo "Looks like the TDE menu structure is already set. No action taken."
    exit 10
  else
    # mkdir -p $HOME/.local/share/applications/
    # cp /usr/share/applications/q4os-controlpanel.desktop $HOME/.local/share/applications/q4os-user-controlpanel.desktop
    # sed -i 's@^Categories=.*@Categories=Settings;@' $HOME/.local/share/applications/q4os-user-controlpanel.desktop
    rm -f $XDGCFG_HOME1/menus/tde-applications.menu
  fi
fi

if [ -z "$ACTON" ] ; then
  echo " Menu structure switcher"
  echo "  Usage1: kmenu_str.sh --tde <--q4os>"
  echo "  Usage2: kmenu_str.sh --help"
  exit 20
fi

if [ "$2" != "--no-agui" ] ; then
  tdebuildsycoca
  dcop kicker kicker restart
fi
