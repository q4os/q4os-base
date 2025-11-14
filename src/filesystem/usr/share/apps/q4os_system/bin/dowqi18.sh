#!/bin/sh

# --------------------
# --- variables ------
# --------------------
. gettext.sh
export TEXTDOMAIN="q4os-base"

SYSARCH="$( dpkg --print-architecture )"
QAPTDISTR_A="$( dash /usr/share/apps/q4os_system/bin/print_qaptdistr.sh )"

if [ "$QAPTDISTR_A" = "jammy" ] || [ "$QAPTDISTR_A" = "noble" ] || [ "$QAPTDISTR_A" = "resolute" ] ; then
  WDIR1="http://www.q4os.org/quarktde/"
  # WDIR1="http://www.quarkos.org/quarktde/"
  WDIR2="dists/$QAPTDISTR_A/main/binary-$SYSARCH/"
elif [ "$QAPTDISTR_A" = "raspbian12" ] ; then
  WDIR1="http://www.q4os.org/qtderepo/"
  WDIR2="dists/raspbian-bookworm/main/binary-armhf/"
else
  WDIR1="http://www.q4os.org/qtderepo/"
  WDIR2="dists/$QAPTDISTR_A/main/binary-$SYSARCH/"
  #WDIR1="www.q4os.org/.lang/"
  #WDIR2=""
fi

TMPDIR01="/tmp/q4ilocinst.58FgtP1.q4os.$USER.tmp"
LOCALES_FL="/usr/share/apps/q4os_system/share/debtde.cod" #maps debian locales into their tde codes and human readable names
PACKAGES_FL="Packages.ok" #downloaded from tde repository
# TMP_CODES_FL="codes.tmp" # maps tde codes into human readable names, file is generated from packages file, the same format as $LOCALES_FL

# --------------------
# --- functions ------
# --------------------
print_help ()
{
  echo
  echo "available parameters:"
  echo " --print-tmpdir"
#  echo " --print-locale arg1"
  echo " --print-tdecode arg1"
  echo " --select-lang [arg1]"
  echo " --list"
  echo " --get [arg1]" #[--nogui]
  echo " --install"
  echo " --aptupdate"
  echo " --install2 [arg1] [arg2]"
  echo
  echo "need parameter, exiting ..."
  echo
  return 0
}

# # get locale from tdecode arg
# get_locale ()
# {
#   if [ -z "$1" ] ; then
#     echo "" # no tde_code parameter
#     return 1
#   fi
#   local LOCC1="$( cat $LOCALES_FL | grep ";$1$" | awk -F';' '{ print $2 }' )"
#   if [ -z "$LOCC1" ] ; then
#     echo "" # emtpy locale
#     return 2
#   fi
#   echo "$LOCC1"
#   return 0
# }

# prints locale from tdecode arg
# print_locale ()
# {
#   if [ "$( echo $1 | awk '{ print length ($0) }' )" -le "1" ] ; then
#     echo "tde_code parameter too short, exiting ..."
#     return 1
#   fi
#   echo "Locale: $( cat $LOCALES_FL | grep ";$1$" | awk -F';' '{ print $2 }' )"
#   echo "Language: $( cat $LOCALES_FL | grep ";$1$" | awk -F';' '{ print $1 }' )"
#   echo "TDE_Code: $1"
#   return 0
# }

# prints tdecode from locale arg
print_tdecode ()
{
  # $HSTR1 ....... language_country part of locale argument entered
  # $HSTR2 ....... language part of locale argument entered
  # $HSTR3 ....... country part of locale argument entered
  # $LOCALE_VAR .. unique id of debtde row

  local HSTR1="$( echo $1 | awk -F'.' '{ print $1 }' )" # get part of locale before '.'
  local HSTR2="$( echo $HSTR1 | awk -F'_' '{ print $1 }' )" # get part of locale before '_'
  local HSTR3="$( echo $HSTR1 | awk -F'_' '{ print $2 }' )" # get part of locale after '_'

  if [ "$( echo $HSTR1 | awk '{ print length ($0) }' )" -le "1" ] ; then
    echo "locale parameter too short, exiting ..."
    return 1
  fi
  if [ "$( echo $HSTR2 | awk '{ print length ($0) }' )" -le "1" ] ; then
    echo "bad locale parameter, exiting ..."
    return 1
  fi

  if [ "$( echo $HSTR1 | awk '{ print length ($0) }' )" -ge "5" ] ; then
    LOCALE_VAR="$( cat $LOCALES_FL | grep -v "^#" | grep ";DIFF;" | grep ";$HSTR1" |  awk -F';' '{ print $2 }' )"
  fi
  if [ -z "$LOCALE_VAR" ] ; then
    LOCALE_VAR="$( cat $LOCALES_FL | grep -v "^#" | grep -v ";DIFF;" | grep ";$HSTR2\_" |  awk -F';' '{ print $2 }' )"
  fi
  if [ -z "$LOCALE_VAR" ] ; then
    LOCALE_VAR="$( cat $LOCALES_FL | grep -v "^#" | grep -v ";DIFF;" | grep ";$HSTR2\." |  awk -F';' '{ print $2 }' )"
  fi
  if [ -z "$LOCALE_VAR" ] ; then
    LOCALE_VAR="_not_found_"
  fi

  KGLCODE="$HSTR2"
  if [ -n "$( cat $LOCALES_FL | grep -v "^#" | grep ";DIFF;" | grep ";$LOCALE_VAR;" )" ] ; then
    KGLCODE=""$HSTR2"_"$HSTR3""
  fi
  if [ "$LOCALE_VAR" = "_not_found_" ] ; then
    KGLCODE="en_US"
  fi

  echo "Locale string entered: $1"
  echo "Locale parsed: $LOCALE_VAR"
  echo "Language: $( cat $LOCALES_FL | grep -v "^#" | grep ";$LOCALE_VAR;" | awk -F';' '{ print $1 }' )"
  echo "TDE_Code: $( cat $LOCALES_FL | grep -v "^#" | grep ";$LOCALE_VAR;" | awk -F';' '{ print $8 }' )"
  echo "Kdeglobals_Language_Code: $KGLCODE"
  echo "Kdeglobals_Country_Code: $( echo "$HSTR3" | awk '{ print tolower($0) }' )"
  echo "Keyboard_Code: $( cat $LOCALES_FL | grep -v "^#" | grep ";$LOCALE_VAR;" | awk -F';' '{ print $6 }' )"
  return 0
}

download_packages_file ()
{
  if [ ! -f "$PACKAGES_FL" ] ; then
    echo "Downloading packages file ..."
    rm -f Packages.gz
    wget -q -T70 -t2 --progress=dot $WDIR1/$WDIR2/Packages.gz
    if [ "$?" != "0" ] ; then
      echo "Download failed, check Internet connection, exiting ..."
      exit 1
    fi
    rm -f Packages
    gunzip Packages.gz
    mv Packages $PACKAGES_FL
    echo "  ... done"
  else
    echo "Packages file already downloaded ; ok."
  fi
}

apt_update ()
{
  if ! dash /usr/share/apps/q4os_system/bin/tst_dwnl.sh > /dev/null ; then
    echo "Internet not available, try installation few minutes later."
    return 20
  fi
  if [ -n "$( check_apt_busy.sh )" ] ; then
    echo "Package system is busy now, try installation few minutes later."
    return 21
  fi
  if ! sudo -n /usr/lib/q4os/qapt-get --assume-yes update ; then
    echo "APT update not successful, try installation few minutes later."
    return 22
  fi
}

# compose_langs ()
# {
#   if [ "$1" = "--use-packages-file" ] ; then
#     # compose languages from "Packages" file
#     download_packages_file
#     cat $PACKAGES_FL | grep Description: | grep "internationalized (i18n) files for TDE" | awk -F'Description: ' '{ print $2 }' | awk -F' \(' '{ print $1 }' > tmpfl01.tmp
#     cat $PACKAGES_FL | grep -i tde-i18n- | grep Filename: | awk -F'tde-i18n-' '{ print $3 }' | awk -F- '{ print $1 }' > tmpfl02.tmp
#     paste -d\; tmpfl01.tmp /dev/null /dev/null tmpfl02.tmp | sort > $TMP_CODES_FL
#     rm -f tmpfl01.tmp tmpfl02.tmp
#     return
#   fi
# 
#   cp $LOCALES_FL $TMP_CODES_FL
# }

# cli dialog to select a language
# select_language_nogui ()
# {
# }

# dialog to select a language
select_language_gui ()
{
  local WRKFL1="/tmp/.tmpflx04.tmp"
  cat $LOCALES_FL | grep -v "^#" | grep -v "^$" | awk -F';' '{ print $1 ";" $2 ";" $8 }' | sort > $WRKFL1
  sed -i 's/ /_/' $WRKFL1
  local PRESELECT1="$1" ; if [ -z "$PRESELECT1" ] ; then PRESELECT1="US" ; fi
  PRESELECT1="$( cat $WRKFL1 | grep "$PRESELECT1.UTF-8;" | head -n1 )"
  if [ -z "$PRESELECT1" ] ; then
    PRESELECT1="$( cat $WRKFL1 | grep ";en_US.UTF-8;" | head -n1 )"
  fi
  if [ -n "$PRESELECT1" ] ; then
    sed -i "/$PRESELECT1/d" $WRKFL1
    sed -i "1s/^/$PRESELECT1\n/" $WRKFL1
  fi
  RDVAL="$( /opt/trinity/bin/kdialog --icon "message" --title "Language" --caption "select" --combobox "$(eval_gettext "Select your language:")" $( cat $WRKFL1 | awk -F';' '{ print $1 }' ) )"
  if [ "$?" != "0" ] ; then
    #canceled
    rm -f $WRKFL1
    return 1
  fi
  local LLANGUAG="$( cat $WRKFL1 | grep "^$RDVAL;" | awk -F';' '{ print $1 }' )"
  local LLLOCALE="$( cat $WRKFL1 | grep "^$RDVAL;" | awk -F';' '{ print $2 }' )"
  local LTDECODE="$( cat $WRKFL1 | grep "^$RDVAL;" | awk -F';' '{ print $3 }' )"
  rm -f $WRKFL1
  echo "$LLANGUAG;$LLLOCALE;$LTDECODE"
  return 0
}

# --------------------
# --- script start ---
# --------------------
if [ -z "$1" ] ; then
  print_help
fi

mkdir -p $TMPDIR01
cd $TMPDIR01

if [ "$1" = "--print-tmpdir" ] ; then
  echo "Temporary working dir: $TMPDIR01"
  exit 0
fi

if [ "$1" = "--list" ] ; then
  echo
  echo "Downloaded packages:"
  ls --format=single-column *.deb 2> /dev/null
  echo
  exit 0
fi

if [ "$1" = "--install" ] ; then
  if [ -n "$( check_apt_busy.sh )" ] ; then
    echo
    echo "Package system is busy now, try installation few minutes later."
    echo
    exit 10
  fi
  echo
  echo "Installing packages .."
  for CCFL in *.deb
  do
    echo "Processing $CCFL"
    PCKNMWK1="$( echo "$CCFL" | awk -F'_' '{ print $1 }' )"
    if [ -n "$( dpkg --get-selections | grep -iP '\tinstall$' | awk -F' ' '{ print $1 }' | awk -F":" '{ print $1 }' | grep "^${PCKNMWK1}$" )" ] ; then
      echo "Package $PCKNMWK1 already installed, skipping"
    else
      sudo -n /usr/lib/q4os/qdpkg -i $CCFL
    fi
  done
  echo " .. done."
  echo
  exit 0
fi

if [ "$1" = "--install2" ] ; then
  if [ -z "$2" ] ; then
    echo
    echo "No TDE code specified."
    echo
    exit 11
  fi
  PCK_TOINST="tde-i18n-$2-trinity"
  if [ -n "$( echo "$3" | grep -i '.UTF-8' | grep 'zh_\|ja_\|ko_\|th_\|ar_\|he_' )" ] ; then
    PCK_TOINST="$PCK_TOINST fonts-noto-cjk"
  fi
  if [ -n "$( echo "$3" | grep -i '.UTF-8' | grep 'ja_' )" ] ; then
    PCK_TOINST="$PCK_TOINST fcitx5-mozc"
  fi
  if [ -n "$( echo "$3" | grep -i '.UTF-8' | grep 'zh_' )" ] ; then
    PCK_TOINST="$PCK_TOINST fcitx5-chewing"
  fi
  echo "Packages to install: $PCK_TOINST"
  if [ -n "$( check_apt_busy.sh )" ] ; then
    echo
    echo "Package system is busy now, try installation few minutes later."
    echo
    exit 10
  fi
  echo "Installing packages .."
  sudo -n /usr/lib/q4os/qapt-get --assume-yes install $PCK_TOINST
  echo " .. done."
  echo
  exit 0
fi

if [ ! -f "$LOCALES_FL" ] ; then
  echo "Locales file missing, exit ..."
  exit 1
fi

if [ "$1" = "--select-lang" ] ; then
  RETV="$( select_language_gui "$2" )"
  if [ "$?" != "0" ] ; then
    exit 1  #canceled
  fi
  echo "$RETV"
  exit 0
fi

# prints locale from tdecode arg
# if [ "$1" = "--print-locale" ] ; then
#   print_locale "$2"
#   exit "$?"
# fi

# prints tdecode from locale arg
if [ "$1" = "--print-tdecode" ] ; then
  print_tdecode "$2"
  exit "$?"
fi

if [ "$1" = "--aptupdate" ] ; then
  apt_update
  exit "$?"
fi

if [ "$1" = "--get" ] ; then
  TDECODE="$2"
#   if [ "$2" = "--nogui" ] ; then
#     WRKFL2="/tmp/.tmpflx05.tmp"
#     sort $LOCALES_FL | grep -v "^#" | grep -v "^$" | awk -F';' '{ print $1 " [" $8 "]" }' > $WRKFL2
#     cat -n $WRKFL2
#     echo
#     read -p "Enter a number to download a language pack .. " RDVAL
#     if [ -z "$RDVAL" ] ; then
#       echo "no input, exiting ..."
#       exit 1
#     fi
#     TDECODE="$( sed -n "$RDVAL p" $WRKFL2 | awk -F'[' '{ print $2 }' | awk -F']' '{ print $1 }' )"
#     rm -f $WRKFL2
#     if [ -z "$TDECODE" ] ; then
#       echo "no tde code, exiting ..."
#       exit 1
#     fi
#   fi
  if [ -z "$2" ] ; then
    TDECODE="$( echo "$( select_language_gui )" | awk -F';' '{ print $3 }' )"
    if [ -z "$TDECODE" ] ; then
      echo "no tde language file found, exiting ..."
      exit 1
    fi
  fi
fi

if [ -z "$TDECODE" ] ; then
  echo "bad arguments, exiting ..."
  exit 1
fi

if [ -z "$( cat $LOCALES_FL | grep ";$TDECODE$" | awk -F';' '{ print $8 }' )" ] ; then
  echo "language \"$TDECODE\" not mapped, exiting ..."
  exit 1
fi

echo "TDE_Code: $TDECODE ; Language: "$( cat $LOCALES_FL | grep ";$TDECODE$" | awk -F';' '{ print $1 }' )" ; ok."
download_packages_file

FLDL="$( cat $PACKAGES_FL | grep Filename: | grep "/tde-i18n-$TDECODE-trinity_" | awk '{ print $2 }' )"
if [ -z "$FLDL" ] ; then
  echo "unknown language \"$TDECODE\" .. exiting ..."
  exit 1
fi

echo "Downloading language pack ..."
rm -f tde-i18n-$TDECODE-trinity_* #remove previously/partially downloaded file/s
wget -q -T70 -t2 $WDIR1/$FLDL
if [ "$?" != "0" ] ; then
  echo "Download error, check Internet connection, exiting ..."
  exit 1
fi
echo "  ... done."
