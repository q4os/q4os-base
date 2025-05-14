how to create 'printersandfax_q4os_startmenu' and 'folder_doc_q4os_startmenu' icons:
take them from crystalsvg and place them into hicolor - '/opt/trinity/share/icons/hicolor/'
see the script:

#---- copy/create icons {
  find /opt/trinity/share/icons/crystalsvg -type f -iname "folder_txt.png" | while read -r FILE_IN ; do
    FILE_OUT="$( echo "$FILE_IN" | sed 's:/crystalsvg/:/hicolor/:' )"
    mkdir -p "$( dirname "$FILE_OUT" )"
    cp "$FILE_IN" "$( dirname "$FILE_OUT" )"/folder_doc_q4os_startmenu.png
  done
  find /opt/trinity/share/icons/crystalsvg -type f -iname "printer.png" | while read -r FILE_IN ; do
    FILE_OUT="$( echo "$FILE_IN" | sed 's:/crystalsvg/:/hicolor/:' )"
    mkdir -p "$( dirname "$FILE_OUT" )"
    cp "$FILE_IN" "$( dirname "$FILE_OUT" )"/printersandfax_q4os_startmenu.png
  done
#---- }
