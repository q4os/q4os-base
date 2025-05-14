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
  elif [ "$DDISTRIBUTOR" = "Ubuntu" ] && [ "$DCODENAME" = "focal" ] ; then
    QAPTDISTR="focal"
  elif [ "$DDISTRIBUTOR" = "Ubuntu" ] && [ "$DCODENAME" = "jammy" ] ; then
    QAPTDISTR="jammy"
  elif [ "$DDISTRIBUTOR" = "Ubuntu" ] && [ "$DCODENAME" = "noble" ] ; then
    QAPTDISTR="noble"
  fi

fi

echo "$QAPTDISTR"
