#!/bin/sh

# $1 .. display manager binary, full path, for ex: '/opt/trinity/bin/tdm'
# $2 .. value for the debconf database, for ex: 'tdm-trinity'

if [ "$( id -u )" != "0" ] ; then
 echo "only root can run, exiting ..."
 exit 100
fi

if [ -z "$2" ] ; then
 echo "need arguments, exiting ..."
 exit 110
fi

DEFAULT_DISPLAY_MANAGER_FILE="/etc/X11/default-display-manager"

echo "$1" | tee $DEFAULT_DISPLAY_MANAGER_FILE
dash /usr/share/apps/q4os_system/bin/debconf_conf.sh "--set" "shared" "default-x-display-manager" "$2"

#setting systemd service
#inspired by the postinst script of the sddm package
DEFAULT_SERVICE="/etc/systemd/system/display-manager.service"

# set default-display-manager systemd service link
echo "setting default-display-manager systemd service link ..."
if [ -d /etc/systemd/system/ ]; then
    if [ -e "$DEFAULT_DISPLAY_MANAGER_FILE" ]; then
        SERVICE=/lib/systemd/system/$(basename $(cat "$DEFAULT_DISPLAY_MANAGER_FILE")).service
        echo "$SERVICE"
        if [ -h "$DEFAULT_SERVICE" ] && [ $(readlink "$DEFAULT_SERVICE") = /dev/null ]; then
            echo "display manager service is masked" >&2
        elif [ -e "$SERVICE" ]; then
            echo "created link, ok" >&2
            ln -sf "$SERVICE" "$DEFAULT_SERVICE"
        else
            echo "failed: $SERVICE is the selected default display manager but does not exist" >&2
        fi
    fi
fi
