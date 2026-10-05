#!/bin/sh

#----------------------------------------------------------------------------------------------
# Settings + Init
#----------------------------------------------------------------------------------------------
. gettext.sh
export TEXTDOMAIN="q4os-base"
unset LC_ALL

APQ="$1" #installer name
APF="$2" #title name
APD="$3" #description name
APPICON="$4"
WKDIR="$5" #working directory
SSUFF="$6"
DWNL_SITE="$7" #download site
RESREVED1="$8" #reserved for future use, not used now
EXECI="$9" #execute isntaller after download

if [ -z "$APQ" ] ; then
  echo "Parameters: APQ [ APF APD APPICON WKDIR SSUFF DWNL_SITE RESREVED1 EXECI ]"
  echo "Bad parameters, exiting ..."
  exit 100
fi
if [ -z "$APF" ] ; then
  APF=$APQ
fi
if [ -z "$APD" ] ; then
  APD=$APF
fi
if [ -z "$APPICON" ] ; then
  APPICON=""
fi
if [ -z "$WKDIR" ] ; then
  WKDIR="/tmp/.dwnlinstl"
fi
if [ -z "$EXECI" ] ; then
  EXECI="0"
fi

#disable kdialog gui
if [ "$( id -u )" = "0" ] ; then
  HIDE_KDLG="1"
fi
# if [ -n "$SYSTEM_INSTALL" ] ; then
#   HIDE_KDLG="1"
# fi

if [ ! -d "$WKDIR" ] ; then
  mkdir -p $WKDIR
  chmod a+rwX "$WKDIR"
fi
if [ ! -d "$WKDIR" ] ; then
  echo "Cannot create working directory, exiting ..."
  exit 100
fi
cd $WKDIR

MARK_INST="/tmp/.markdwnlinst-$$"
touch "$MARK_INST"
chmod a+rw "$MARK_INST"

#----------------------------------------------------------------------------------------------
# The Trinity session shows a progress window, kdialog --progressbar driven over dcop; PRGREF
# is the reference kdialog prints. The other sessions get a notification and PRGREF stays
# empty - then nothing is called.
# Function progress_call
#$1 ... alive | total | value | close
#$2 ... the number for total and value
#----------------------------------------------------------------------------------------------
PRGREF=""
progress_call ()
{
  if [ -z "$PRGREF" ] ; then
    return 1
  fi
  case "$1" in
    alive) dcop $PRGREF 1>/dev/null 2>&1 ;;
    total) dcop $PRGREF setTotalSteps "$2" 2>/dev/null ;;
    value) dcop $PRGREF setProgress "$2" 2>/dev/null ;;
    close) dcop $PRGREF close 2>/dev/null ;;
  esac
}

#----------------------------------------------------------------------------------------------
# Function watch_progress
#$1 ... file being downloaded
#----------------------------------------------------------------------------------------------
watch_progress ()
{
if [ "$HIDE_KDLG" = "1" ] || [ -z "$PRGREF" ] || [ -z "$1" ] ; then
 return 0
fi

while [ ! -f "$1" ] ; do
# wait for file creation
 sleep 0.3

# check if the progress window exists
if ! progress_call alive ; then
# the window does not exist (anymore)
 return 0
fi
done

while [ true ] ; do
sleep 0.1

# check if the progress window exists
if ! progress_call alive ; then
# the window does not exist (anymore)
 return 0
fi

# set progress to progressbar
progress_call value $(stat -c%s $1)
done
}

#----------------------------------------------------------------------------------------------
# Function download_error
#$1 ... echo message
#$2 ... exit code
#----------------------------------------------------------------------------------------------
download_error ()
{
  echo "$1"
  if [ "$HIDE_KDLG" != "1" ] ; then
    kdialog --passivepopup "<p>$(eval_gettext "<b>Warning</b>")</p><p>$(eval_gettext "Unable to download \${APD}, check Internet connection, please.")</p>" 15 &
  fi
  ( sleep 0.5 ; progress_call close ) &
  rm -f "$MARK_INST"
  exit "$2"
}

#----------------------------------------------------------------------------------------------
# Download installer
#----------------------------------------------------------------------------------------------
if [ "$HIDE_KDLG" != "1" ] ; then
  if [ "$QDSK_SESSION" = "trinity" ] ; then
    PRGREF=$(kdialog --geometry "300x130+75+75" --title "$APF" --caption "$(eval_gettext "download")" --icon "$APPICON" --progressbar "$APD $(eval_gettext "downloading ...")")
  else
    kdialog --passivepopup "<p>$APF $(eval_gettext "downloading ...")</p>" 10 &
  fi
fi

#DWNL_TYPE .. [ dt_sourceforge | dt_q4os | dt_other ]
if [ -z "$DWNL_SITE" ] ; then
  DWNL_TYPE="dt_q4os"
elif echo "$DWNL_SITE" | grep -q "sf.net/" ; then
  DWNL_TYPE="dt_sourceforge"
elif echo "$DWNL_SITE" | grep -q "sourceforge.net/" ; then
  DWNL_TYPE="dt_sourceforge"
else
  DWNL_TYPE="dt_other"
fi
# echo "Dwnl type: $DWNL_TYPE"

if [ "$DWNL_TYPE" = "dt_q4os" ] ; then
  DWNL_SITE="q4os.org"
  if [ "$QAPTDISTR" = "bullseye" ] ; then
    DWNL_Q4PAGE="downloads_app4.html"
  elif [ "$QAPTDISTR" = "bookworm" ] ; then
    DWNL_Q4PAGE="downloads_app5.html"
  elif [ "$QAPTDISTR" = "trixie" ] ; then
    DWNL_Q4PAGE="downloads_app6.html"
  elif [ "$QAPTDISTR" = "forky" ] ; then
    DWNL_Q4PAGE="downloads_app7.html"
  elif [ "$QAPTDISTR" = "jammy" ] ; then
    DWNL_Q4PAGE="downloads_apu_22.04.html"
  elif [ "$QAPTDISTR" = "noble" ] ; then
    DWNL_Q4PAGE="downloads_apu_24.04.html"
  elif [ "$QAPTDISTR" = "resolute" ] ; then
    DWNL_Q4PAGE="downloads_apu_26.04.html"
  elif [ "$QAPTDISTR" = "raspbian12" ] ; then
    DWNL_Q4PAGE="downloads_app5.html"
  else
    DWNL_Q4PAGE="downloads_app5.html" #fallback
  fi
  if [ -z "$SSUFF" ] ; then
    GRPSAMPL1='.deb">\|.qsi">\|.esh">'
  else
    GRPSAMPL1=".$SSUFF\">"
  fi
  SETUP_FLINK=$( LANG="C" wget -q -T30 -O- "$DWNL_SITE/$DWNL_Q4PAGE" | grep "setup_${APQ}_" | grep "$GRPSAMPL1" | head -n1 | tr -d ' ' )
  SETUP_FLINK=$( echo "$SETUP_FLINK" | awk -F'(<ahref="|">)' '{ for (i=1; i<=NF; i++) print $i }' | grep setup_${APQ}_  | head -n1 )
  SETUP_FLINK="$DWNL_SITE/$SETUP_FLINK"
elif [ "$DWNL_TYPE" = "dt_sourceforge" ] ; then
  if [ -z "$SSUFF" ] ; then
    GRPSAMPL1='.deb/download\|.qsi/download\|.esh/download'
  else
    GRPSAMPL1=".$SSUFF/download"
  fi
  SETUP_FLINK=$( LANG="C" wget -q -T30 -O- "$DWNL_SITE" | grep "setup_${APQ}_" | grep "$GRPSAMPL1" | head -n1 | tr -d ' ' )
  SETUP_FLINK=$( echo "$SETUP_FLINK" | awk -F'(<ahref="|">)' '{ for (i=1; i<=NF; i++) print $i }' | grep setup_${APQ}_  | head -n1 )
  SETUP_FLINK=$( echo "$SETUP_FLINK" | awk -F'/download' '{ print $1 }' )
else
  if [ -z "$SSUFF" ] ; then
    GRPSAMPL1='.deb">\|.qsi">\|.esh">'
  else
    GRPSAMPL1=".$SSUFF\">"
  fi
  SETUP_FLINK=$( LANG="C" wget -q -T30 -O- "$DWNL_SITE" | grep "setup_${APQ}_" | grep "$GRPSAMPL1" | head -n1 | tr -d ' ' )
  SETUP_FLINK=$( echo "$SETUP_FLINK" | awk -F'(<ahref="|">)' '{ for (i=1; i<=NF; i++) print $i }' | grep setup_${APQ}_  | head -n1 )
fi

SETUP_FNAME=$( echo "$SETUP_FLINK" | awk -F'/' '{ print $NF }' )
if [ -n "$SETUP_FNAME" ] ; then
  SETUP_FSIZE=$( LANG="C" wget -T30 --spider "$SETUP_FLINK" 2>&1 | grep "^Length: " | awk '{ print $2 }' )
fi
# echo "File link: $SETUP_FLINK"
echo "File name: $SETUP_FNAME"
echo "File size: $SETUP_FSIZE"

# todo: better checking: $SETUP_FSIZE > 1000 bytes"
if [ -z "$SETUP_FNAME" ] || [ -z "$SETUP_FSIZE" ] ; then
 download_error "[E:] File inaccessible .. FAILED !" "10"
fi

progress_call total $SETUP_FSIZE
( watch_progress "$SETUP_FNAME" 2>&1 ) > /dev/null &

if [ "$(stat -c%s $SETUP_FNAME 2>&1)" != "$SETUP_FSIZE" ] ; then
 rm -f $SETUP_FNAME
 wget -q -T30 --no-directories "$SETUP_FLINK"
 chmod a+rw $SETUP_FNAME
else
 # echo "$SETUP_FNAME already downloaded, continue ..."
 sleep 0.5
fi
# echo "File size check: $(stat -c%s $SETUP_FNAME)"
if [ "$(stat -c%s $SETUP_FNAME)" != "$SETUP_FSIZE" ] ; then
 rm -f $SETUP_FNAME
 download_error "[E:] File inaccessible .. FAILED !" "20"
fi

progress_call value $SETUP_FSIZE
( sleep 0.5 ; progress_call close ) &

if [ "$EXECI" != "0" ] ; then
 appsetup2.exu "$SETUP_FNAME"
fi
rm -f "$MARK_INST"
