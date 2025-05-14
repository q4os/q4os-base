#!/bin/sh
#see http://www.fifi.org/doc/debconf-doc/tutorial.html ; https://manpages.debian.org/stretch/debconf-doc/debconf-devel.7.en.html
#this script is stub, need to be completed first !
#consider to replace confmodule with dedicated commands debconf-communicate, debconf-set-selections, ...
#this script has to have executable flag set in order to work

#set -e

if [ "$( id -u )" != "0" ] ; then
 echo "only root can run, exiting ..."
 exit 100
fi

if [ -z "$3" ] ; then
 echo "need arguments, exiting ..."
 exit 110
fi

if [ -e /usr/share/debconf/confmodule ] ; then
 . /usr/share/debconf/confmodule
else
 echo "no confmodule found, exiting ..."
 exit 200
fi

TNAME="$2/$3"

if [ "$1" = "--set" ] && [ -n "$4" ] ; then
  #writing to debconf database ...
  db_set "$TNAME" "$4"
  #db_subst "$TNAME" choices "tdm-trinity"
  #db_fset "$TNAME" seen false

  # other stuff ...
  #db_input medium $TNAME || true
  #db_go || true

  #exit
fi

echo "Name: $TNAME"

TEMPLATE=
if db_metaget "$TNAME" template ; then
  TEMPLATE="$RET"
  echo "Template: $TEMPLATE"
fi

VALUE=
if db_get "$TNAME" ; then #... 'db_metaget' could be used as well ? ... if db_metaget "$TNAME" value ; then
  VALUE="$RET"
  echo "Value: $VALUE"
fi

OWNERS=
if db_metaget "$TNAME" owners ; then
  OWNERS="$RET"
  echo "Owners: $OWNERS"
fi

# FLAGS=
# if db_metaget "$TNAME" flags ; then #... it doesn't seem to work, so how to get flags ?
#   FLAGS="$RET"
#   echo "Flags: $FLAGS"
# fi

CHOICES=
if db_metaget "$TNAME" choices ; then
  CHOICES="$RET"
  echo "Choices: $CHOICES"
fi
