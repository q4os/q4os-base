#!/bin/sh

. gettext.sh
export TEXTDOMAIN="q4os-base"

parse_desktop_files () {
#  echo "PID: $$"
#  ps -A | grep $$
#  echo "----------------------------"

  # remove Categories line from copied .desktop files, otherwise not shown in menu
  while [ "$( dcop $1 konqueror-mainwindow#1 shown )" = "true" ] ; do #note: must be 'shown' command as first instance of konqueror stays cached alive on close !
#    echo "--------------Sleep-------------"
    sleep 6
#    echo "--------------Sleep done-------------"
#    find . -type f -follow -iname "*.desktop" -exec sh -c 'echo Processing: "{}" ; sed -i "s/.*Categories=.*/#Categories=None/g" "{}"' \;
    find . -type f -follow -iname "*.desktop" -exec sh -c 'sed -i "s/.*Categories=.*/#Categories=None/g" "{}"' \;
  done

  tdebuildsycoca

} # 2>&1 > /tmp/kmnedit.log

kdialog --dontagain "q4osrc:ShowKMenuEditNote" --title "Menu Editor" --caption "" --icon "messagebox_info" --msgbox "<p>$(eval_gettext "You are going to edit Start Menu.")</p><p>$(eval_gettext "Start menu structure consists of two logical parts mixed, the <b>system global and user part</b>. You can edit, delete and add custom menu entries for the user part only, global menu entries are not visible in the MenuEditor.")</p><p>$(eval_gettext "You will be able to create new custom submenus/folders structure and fill it with desired menu entries. You can create new shortcuts using right mouse click, or drag&drop icons from start menu or desktop into the MenuEditor window.")</p><p>$(eval_gettext "Newly created items will appear in the start menu <b>after closing</b> the MenuEditor window.")<p></p>$(eval_gettext "Click \"Ok\" button to show the MenuEditor window.")</p>"

cd $HOME/.q4data/Programs
KONQ_DCOP_ID="$( dcopstart konqueror --caption "Menu Editor" --profile "filemanagement" $HOME/.q4data/Programs )"
# echo "KONQ_DCOP_ID: $KONQ_DCOP_ID"

# remove Categories line from copied .desktop files
# reasearch: necessary to create new detached process, cause of some strange trinity feature, which kills this parent process in a few seconds
parse_desktop_files $KONQ_DCOP_ID &
# exit
