#!/bin/sh
echo "Checking repositories ..."
if [ "$QAPDISTR_SCR" = "focal" ] ; then

  #move quarkos repositories from sourceforge to the domain dedicated
  echo "Fixing repositories ..."
  sed -i 's@ http://sourceforge.net/projects/ubuntu-quark/files/repos/@ http://q4os.org/@' /etc/apt/sources.list
  for REPO_FL in /etc/apt/sources.list.d/*.list ; do
    sed -i 's@ http://sourceforge.net/projects/ubuntu-quark/files/repos/@ http://q4os.org/@' $REPO_FL
  done

  rm -f /etc/apt/preferences.d/pin80-quark
fi
