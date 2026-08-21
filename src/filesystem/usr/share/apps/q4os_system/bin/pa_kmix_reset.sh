#!/bin/sh
#reset kmix master channel when a pulseaudio compatible sound server is installed
STAMP1="$HOME/.local/share/q4os/.pakmixreset.stp"
if [ ! -f "$STAMP1" ] ; then
  if [ -f "/usr/bin/pulseaudio" ] || [ -f "/usr/bin/pipewire-pulse" ] ; then
    if [ -z "$( cat $HOME/.trinity/share/config/kmixrc | grep '^MasterMixer=' | grep -E 'ALSA::(PulseAudio|PipeWire):' )" ] ; then
     pkill kmix
     rm -f $HOME/.trinity/share/config/kmixrc
    fi
    mkdir -p "$HOME/.local/share/q4os/"
    touch "$STAMP1"
  fi
fi
