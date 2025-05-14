#!/bin/sh
#source this script from starttde

#needed for gtk3 applications to save settings properly
dbus-update-activation-environment --systemd XDG_CONFIG_HOME
#fixme, or report a debian bug:
#'dbus-update-activation-environment' doesn't re-set variables,
#if they were set before ; how to do re-set env. variable ?
