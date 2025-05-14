#!/bin/sh

TMPDR01=$( mktemp -d --tmpdir=/tmp --suffix=-tstdwnld )

if [ -z "$1" ] ; then
  FNAME=.tstinet
else
  FNAME=$1
fi

if [ -z "$2" ] ; then
  WTIMEOUT="30"
else
  WTIMEOUT="$2"
fi

wget -q -T$WTIMEOUT -t2 -P$TMPDR01 http://www.q4os.org/touch/$FNAME
EXITSTATUS="$?"

if [ "$EXITSTATUS" = "0" ] ; then
  echo "ok"
else
  echo "failed"
fi

rm -rf $TMPDR01

exit $EXITSTATUS
