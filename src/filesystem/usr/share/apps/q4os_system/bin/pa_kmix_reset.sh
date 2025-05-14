#!/bin/sh
#reset kmix master channel when pulseaudio installed
STAMP1="$HOME/.local/share/q4os/.pakmixreset.stp"
if [ ! -f "$STAMP1" ] ; then
  if [ -f "/usr/bin/pulseaudio" ] ; then
    if [ -z "$( cat $HOME/.trinity/share/config/kmixrc | grep '^MasterMixer=' | grep 'ALSA::PulseAudio:' )" ] ; then
     pkill kmix
     rm -f $HOME/.trinity/share/config/kmixrc
    fi
    mkdir -p "$HOME/.local/share/q4os/"
    touch "$STAMP1"
  fi
fi
