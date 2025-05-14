#!/bin/sh

# tde bugfix - kcm fonts deletes gtkrc files, remove bugfix if repaired by upstream
cp $HOME/.trinity/share/config/gtkrc $HOME/.trinity/share/config/gtkrc.prekcmfonts
cp $HOME/.trinity/share/config/gtkrc-2.0 $HOME/.trinity/share/config/gtkrc-2.0.prekcmfonts
