#!/bin/sh

#script to run after q4os quick install or from live media
#- offer languages to setup
#- setup global locale
#- download and install tde language pack

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

if [ "$SHOW_KD1" != "no" ] ; then
  /opt/trinity/bin/kdialog --icon "message" --title "Language" --caption "setup" --yesno "<p>$(eval_gettext "Current system language: <b>English</b>")</p><p>$(eval_gettext "Do you want to keep English as default system language ?")</p>"
  if [ "$?" = "0" ] ; then
    echo "canceled, keep american english  ..."
    exit 0
  fi
fi

WKVAR01="$( $DQIC --select-lang $2 )"
if [ "$?" != "0" ] ; then
  echo "canceled language selection, falling back to american english ..."
  if [ "$LANG" = "en_US.UTF-8" ] ; then
    echo "american english already set, so not generating locale ..."
    exit 0
  fi
  unset WKVAR01
fi
DCOPREF=$( /opt/trinity/bin/kdialog --icon "message" --title "Language" --caption "setup" --progressbar "$(eval_gettext "Generating system wide locales, please wait ...")" )
echo "Selected language: $WKVAR01"
LOCC="$( echo $WKVAR01 | awk -F';' '{ print $2 }' )"
TDEC="$( echo $WKVAR01 | awk -F';' '{ print $3 }' )"
if [ -z "$LOCC" ] ; then
  LOCC="en_US.UTF-8" #fallback, if no debian locale found in debtde.cod
  TDEC=""
fi
echo "Locale selected: \"$LOCC\""
( dcop $DCOPREF setProgress 1 ; sleep 0.6 ; dcop $DCOPREF setProgress 10 ) &
sudo -n dash /usr/share/apps/q4os_system/bin/generate_locale.sh "$LOCC" "--set"
export LANG="$LOCC"
echo "export LANG=$LANG" >> $HOME/.addlangenv.sh #to set $LANG at the first login

if [ "$1" = "--only-set-locale" ] ; then
  echo "\"--only-set-locale\" wanted, locale \"$LANG\" set."
  dcop_close "$DCOPREF" "Completed."
  exit 0
fi

if [ -z "$TDEC" ] ; then
  echo "language pack for \"$LANG\" not available, falling to american english ..."
  dcop_close "$DCOPREF" "Completed."
  exit 0
fi

dcop $DCOPREF setLabel "Downloading language pack, please wait ..."
dcop $DCOPREF setProgress 20

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
