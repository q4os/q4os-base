#!/bin/sh

#based on $LANG, set country and language for TDE

echo "Starting to configure language for Trinity desktop"
echo "LANG: $LANG"
echo "[Debug:] HOME: $HOME"
echo "[Debug:] TDEHOME: $TDEHOME"
echo "[Debug:] XDG_CONFIG_HOME: $XDG_CONFIG_HOME"
# export QAPTDISTR1="$( dash /usr/share/apps/q4os_system/bin/print_qaptdistr.sh )"
# echo "[Debug:] QAPTDISTR1: $QAPTDISTR1 .. set"
export TDEHOM_PLASMA="$(dash /usr/share/apps/q4os_system/bin/printvar_tdehome_plasma.sh)"
export TDEHOM_TRINTY="$HOME/.trinity"
echo "[Debug:] TDEHOM_PLASMA: $TDEHOM_PLASMA .. set"
echo "[Debug:] TDEHOM_TRINTY: $TDEHOM_TRINTY .. set"
# if [ "$( id -u )" = "0" ] ; then
#   export ASROOT="1"
#   echo "Running as root"
# fi

HSTR2="$(dash /usr/share/apps/q4os_system/bin/dowqi18.sh "--print-tdecode" "$LANG" 2>&1)"
LANC="$( echo "$HSTR2" | grep "^Language: " | awk -F': ' '{ print $2 }' )"
# TZDT="$( echo "$HSTR2" | grep "^Timezone_Code: " | awk -F': ' '{ print $2 }' )"
KGLC="$( echo "$HSTR2" | grep "^Kdeglobals_Language_Code: " | awk -F': ' '{ print $2 }' )"
KGCC="$( echo "$HSTR2" | grep "^Kdeglobals_Country_Code: " | awk -F': ' '{ print $2 }' )"
echo "Language: $LANC"
echo "Kdeglobals_Language_Code: $KGLC"
echo "Kdeglobals_Country_Code: $KGCC"

if [ -n "$KGLC" ] ; then
  /opt/trinity/bin/kwriteconfig --file "$TDEHOM_TRINTY/share/config/kdeglobals" --group "Locale" --key "Language" "$KGLC"
  /opt/trinity/bin/kwriteconfig --file "$TDEHOM_PLASMA/share/config/kdeglobals" --group "Locale" --key "Language" "$KGLC"
else
  /opt/trinity/bin/kwriteconfig --file "$TDEHOM_TRINTY/share/config/kdeglobals" --group "Locale" --key "Language" "en_US"
  /opt/trinity/bin/kwriteconfig --file "$TDEHOM_PLASMA/share/config/kdeglobals" --group "Locale" --key "Language" "en_US"
fi
if [ -n "$KGCC" ] ; then
  /opt/trinity/bin/kwriteconfig --file "$TDEHOM_TRINTY/share/config/kdeglobals" --group "Locale" --key "Country" "$KGCC"
  /opt/trinity/bin/kwriteconfig --file "$TDEHOM_PLASMA/share/config/kdeglobals" --group "Locale" --key "Country" "$KGCC"
else
  /opt/trinity/bin/kwriteconfig --file "$TDEHOM_TRINTY/share/config/kdeglobals" --group "Locale" --key "Country" "us"
  /opt/trinity/bin/kwriteconfig --file "$TDEHOM_PLASMA/share/config/kdeglobals" --group "Locale" --key "Country" "us"
fi

/opt/trinity/bin/kwriteconfig --file "$HOME/.local/share/q4os/.langckeyc.stp" --group "install" --key "timestamp" "$( date +%Y-%m-%d-%H-%M-%S )"
