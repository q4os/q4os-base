#!/bin/sh

if [ -z "$QAPTDISTR" ] ; then
  QAPTDISTR="bookworm" #fallback

  DDISTRIBUTOR="$( /usr/bin/lsb_release -i -s )"
  DCODENAME="$( /usr/bin/lsb_release -c -s )"

  if [ "$DDISTRIBUTOR" = "Debian" ] && [ "$DCODENAME" = "bullseye" ] ; then
    QAPTDISTR="bullseye"
  elif [ "$DDISTRIBUTOR" = "Debian" ] && [ "$DCODENAME" = "bookworm" ] ; then
    QAPTDISTR="bookworm"
  elif [ "$DDISTRIBUTOR" = "Debian" ] && [ "$DCODENAME" = "trixie" ] ; then
    QAPTDISTR="trixie"
  elif [ "$DDISTRIBUTOR" = "Raspbian" ] && [ "$DCODENAME" = "bookworm" ] ; then
    QAPTDISTR="raspbian12"
  elif [ "$DDISTRIBUTOR" = "Ubuntu" ] && [ "$DCODENAME" = "jammy" ] ; then
    QAPTDISTR="jammy"
  elif [ "$DDISTRIBUTOR" = "Ubuntu" ] && [ "$DCODENAME" = "noble" ] ; then
    QAPTDISTR="noble"
  fi
fi

if [ "$OPT_CODENAME" = "1" ] ; then
  if [ $QAPTDISTR = "bullseye" ] ; then
    QCODENAME1="gemini"
  elif [ $QAPTDISTR = "bookworm" ] ; then
    QCODENAME1="aquarius"
  elif [ $QAPTDISTR = "trixie" ] ; then
    QCODENAME1="andromeda"
  elif [ $QAPTDISTR = "raspbian12" ] ; then
    QCODENAME1="aquarius"
  elif [ $QAPTDISTR = "jammy" ] ; then
    QCODENAME1="jammy"
  elif [ $QAPTDISTR = "noble" ] ; then
    QCODENAME1="noble"
  else
    QCODENAME1="unknown"
  fi
  OUTPUT1="$QCODENAME1"
else
  OUTPUT1="$QAPTDISTR"
fi

if [ "$OPT_UPPER_ALL" = "1" ] ; then
  OUTPUT1="$( echo $OUTPUT1 | awk '{ print toupper($0) }' )"
elif [ "$OPT_UPPER_FIRST" = "1" ] ; then
  OUTPUT1="$( echo $OUTPUT1 | awk '{ print substr(toupper($0),1,1) substr($0,2) }' )"
fi

echo "$OUTPUT1"
