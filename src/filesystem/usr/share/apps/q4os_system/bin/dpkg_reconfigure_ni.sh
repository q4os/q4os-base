#!/bin/sh
#this script performs dpkg-reconfigure non interactively
#see https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=825107
#see /var/cache/debconf/config.dat
#consider to rewrite this script to use debconf confmodule, see 'debconf_conf.sh' script

if [ "$( id -u )" != "0" ] ; then
 echo "only root can run, exiting ..."
 exit 100
fi

if [ -z "$3" ] ; then
 echo "need arguments, exiting ..."
 exit 110
fi

# #todo: think about: ? forbid reconfigure if dpkg in progress ?
# if [ check-apt-busy ] ; then
#  echo "dpkg database locked, exiting ..."
#  exit 120
# fi

echo "setting [$1/$2] > $3"

CFGDF="/tmp/overridedb.dat"
rm -f $CFGDF

#config file:
cat > "$CFGDF" <<EOF
Name: $1/$2
Template: $1/$2
Value: $3
Owners: $1
EOF

if [ -n "$4" ] ; then
cat >> "$CFGDF" <<EOF
Variables:
 $1 = $4
EOF
fi

#configure:
DEBCONF_DB_OVERRIDE="File{$CFGDF readonly:true}" dpkg-reconfigure -fnoninteractive $1

#also update the debconf cache:
debconf-copydb override_db config --config=Name:override_db --config=Driver:File --config=Filename:"$CFGDF"

rm -f $CFGDF

#addition: setting default locale
if [ "$1/$2" = "locales/default_environment_locale" ] ; then
  update-locale LANG="$3" #update /etc/default/locale
fi

exit
