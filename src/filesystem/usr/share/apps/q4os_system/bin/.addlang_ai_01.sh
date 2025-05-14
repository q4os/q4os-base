#!/bin/sh

#script to run after q4os classic install
#- read $LANG env variable and try to download and install proper tde language pack

. gettext.sh
export TEXTDOMAIN="q4os-base"

dcop_close ()
{
  local DCOPREF="$1"
  dcop $DCOPREF setProgress 100
  dcop $DCOPREF setLabel "$2"
  sleep 0.6
  dcop $DCOPREF close
}

DQIC="dash /usr/share/apps/q4os_system/bin/dowqi18.sh"
WKDIR="$( $DQIC --print-tmpdir | grep "^Temporary working dir: " | awk -F': ' '{ print $2 }' )"
cd $WKDIR

if [ -z "$LANG" ] ; then
  echo "\$LANG not set, exiting ..."
  exit 0
fi

TMPFL01="xtmpflxx1.tmp" #working file
( $DQIC --print-tdecode $LANG 2>&1 ) > $TMPFL01
TDEC="$( cat $TMPFL01 | grep "^TDE_Code: " | awk -F': ' '{ print $2 }' )"
LANC="$( cat $TMPFL01 | grep "^Language: " | awk -F': ' '{ print $2 }' )"
rm $TMPFL01

if [ -z "$TDEC" ] ; then
  echo "language pack for \"$LANG\" not available, exiting ..."
  exit 0
fi

/opt/trinity/bin/kdialog --icon "message" --title "$(eval_gettext "Language")" --caption "setup" --yesno "<p>$(eval_gettext "Default language: <b>\${LANC}</b>")</p><p>$(eval_gettext "System is ready to download and install \${LANC} language pack, you need an active Internet link.")</p><p>$(eval_gettext "Would you like to install the language right now ?")</p>"
if [ "$?" != "0" ] ; then
  echo "canceled, exiting ..."
  exit 30
fi

DCOPREF=$( /opt/trinity/bin/kdialog --icon "message" --title "$(eval_gettext "Language")" --caption "setup" --progressbar "$(eval_gettext "Downloading language pack, please wait ...")" )
( dcop $DCOPREF setProgress 1 ; sleep 0.6 ; dcop $DCOPREF setProgress 10 ) &

if [ -n "$( echo "$LANG" | grep -i '.UTF-8' | grep 'zh_\|ja_\|ko_\|th_\|ar_\|he_' )" ] ; then
  APTOP="1"
fi

if [ -n "$APTOP" ] ; then
  $DQIC --aptupdate "$TDEC"
else
  $DQIC --get "$TDEC"
fi
if [ "$?" != "0" ] ; then
  echo "unable to download, exiting ..."
  dcop_close "$DCOPREF" "Failed."
  /opt/trinity/bin/kdialog --icon "message" --caption "$(eval_gettext "Language pack")" --sorry "<p>$(eval_gettext "Unable to download, check Internet connection please. You can easily install language pack later, using a desktop icon.")</p>"
  exit 40
fi
dcop $DCOPREF setProgress 85
dcop $DCOPREF setLabel "Installing language pack, please wait ..."

if [ -n "$APTOP" ] ; then
  $DQIC --install2 "$TDEC" "$LANG"
else
  $DQIC --install
fi
if [ "$?" != "0" ] ; then
  echo "installation has not completed, exiting ..."
  dcop_close "$DCOPREF" "Failed."
  /opt/trinity/bin/kdialog --icon "message" --caption "$(eval_gettext "Language pack")" --sorry "<p>$(eval_gettext "Installation has not completed, package system is busy. You can easily install language pack later, using a desktop icon.")</p>"
  exit 50
fi
dcop_close "$DCOPREF" "Completed."

echo "language installation finished."

#a message if called from desktop instead of from the first login script
if [ -z "$SYSTEM_INSTALL" ] ; then
  /opt/trinity/bin/kdialog --icon "message" --title "$(eval_gettext "Language")" --caption "setup" --msgbox "<p>$(eval_gettext "Language <b>\${LANC}</b> has been added to system.")</p><p>$(eval_gettext "Please login again to take changes effect.")</p>"
  rm -f "$( xdg-user-dir DESKTOP )/instlq4langpack.desktop"
  rm -f "$HOME/.addlang_ai_01.sh"
fi
