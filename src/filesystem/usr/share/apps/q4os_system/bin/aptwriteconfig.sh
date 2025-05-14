#!/bin/sh
#performs unattended upgrades configuration
#$1 .. config file
#$2 .. apt option
#$3 .. value

if [ "$( id -u )" != "0" ] ; then
  echo "only root can run this script, exiting .."
  exit 10
fi
if [ -z "$3" ] ; then
  echo "lack of arguments, exiting .."
  exit 20
fi

CONFIG_FILE1="$1"
# CONFIG_FILE1="/tmp/20auto-upgrades"
if [ ! -f "$CONFIG_FILE1" ] ; then
  echo "config file doesn't exist, creating ..."
  mkdir -p "$(dirname $CONFIG_FILE1)"
  touch $CONFIG_FILE1
fi

CONFIG_OPTION="$2"
CONFIG_VALUE="$3"

HSTR1="$( cat $CONFIG_FILE1 2> /dev/null | sed -e 's/^[[:blank:]]*//' | sed -e 's/[[:blank:]]*$//' )" #remove leading and trailing whitespaces
HSTR1="$( echo "$HSTR1" | grep -n "^$CONFIG_OPTION " | tail -n1 | awk -F':' '{ print $1 }' )" #get line number in $HSTR
if [ -n "$HSTR1" ] ; then
  echo "replacing [line #$HSTR1] $CONFIG_OPTION << $CONFIG_VALUE"
  sed -i "${HSTR1}s/.*/$CONFIG_OPTION \"$CONFIG_VALUE\";/" $CONFIG_FILE1
else
  echo "adding: $CONFIG_OPTION << $CONFIG_VALUE"
  sed -i '$a\' $CONFIG_FILE1 #add a newline, if it doesn't exist
  echo "$CONFIG_OPTION \"$CONFIG_VALUE\";" >> $CONFIG_FILE1
fi
