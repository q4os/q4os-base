#----------------------------------------------------------------------------------------------
# normalize_repo_line :
# remove whitespaces from beginning and end of line,
# convert multi whitespaces into single,
# emtpy line if commented - beginning with "#",
# empty line if begins other than "deb "
# simplify '[ '->'[' and ' ]'->']' and ', '-> ','
#----------------------------------------------------------------------------------------------
normalize_repo_line () {
  local INPUT_LINE="$@"
  local NORMALIZED_LINE="$( echo "$( echo "$INPUT_LINE" | sed 's/^ *//g' | sed 's/ *$//g' | tr -s ' ' | grep -v "^$" | grep -v "^#" | grep -i "^deb " )" )"
  NORMALIZED_LINE="$( echo "$NORMALIZED_LINE" | sed 's/\[ /\[/g' | sed 's/ \]/\]/g' | sed 's/, /,/g' )"
  echo "$NORMALIZED_LINE"
  if [ -z "$NORMALIZED_LINE" ] ; then
    return 1
  fi
  return 0
}

#----------------------------------------------------------------------------------------------
# print_current_repositories_with_normalized_lines
#----------------------------------------------------------------------------------------------
print_current_repositories_with_normalized_lines () {
  local REPO_FL

  # make temporary repo list1
  # todo: mktemp the filename
  rm -f /tmp/1_tmprrrxdsfs.tmp
  cat /etc/apt/sources.list > /tmp/1_tmprrrxdsfs.tmp
  echo >> /tmp/1_tmprrrxdsfs.tmp # add newline to end of file to ensure to be ended with newline
  # parse *.list only, do not include hidden (.*.list) files
  for REPO_FL in /etc/apt/sources.list.d/*.list ; do
    cat $REPO_FL >> /tmp/1_tmprrrxdsfs.tmp
    echo >> /tmp/1_tmprrrxdsfs.tmp # add newline to end of file to ensure to be ended with newline
  done
  sed -i '/^$/d' /tmp/1_tmprrrxdsfs.tmp # remove blank lines
  sed -i '/^#/d' /tmp/1_tmprrrxdsfs.tmp # remove commented lines
  #todo?: sort: sort -o /tmp/1_tmprrrxdsfs.tmp /tmp/1_tmprrrxdsfs.tmp

  while read REPOLINE ; do
    local NORMALIZED_REPO_LINE="$( normalize_repo_line "$REPOLINE" )"
    if [ -n "$NORMALIZED_REPO_LINE" ] ; then
      echo "$NORMALIZED_REPO_LINE"
    fi
  done < /tmp/1_tmprrrxdsfs.tmp

  rm /tmp/1_tmprrrxdsfs.tmp
}

#----------------------------------------------------------------------------------------------
# check if repo represented by input line exists in system
#----------------------------------------------------------------------------------------------
check_if_line_is_in_repo () {
  local NORMALIZED_INPUT_LINE="$( normalize_repo_line "$@" )" #research - possible bug here: try input string ie "x   x" and check normalize_repo_line parameters, if wrong, substitute "$@" with "$( echo "$@" )"

  if [ -z "$NORMALIZED_INPUT_LINE" ] ; then
    return 1
  fi

  #fix: replace '][' characters with '\]\[' for correct grep comparing, see below
  NORMALIZED_INPUT_LINE="$( echo "$NORMALIZED_INPUT_LINE" | sed 's/\[/\\[/g' )"
  NORMALIZED_INPUT_LINE="$( echo "$NORMALIZED_INPUT_LINE" | sed 's/\]/\\]/g' )"

  # compare normalized repositories to input line
  grep "$NORMALIZED_INPUT_LINE" /tmp/normalized_repo.tmp > /dev/null
  if [ "$?" != "0" ] ; then
    return 1
  fi

  return 0
}
