#!/bin/sh
#
# Sync brightness of secondary display with main display
# Author: Chris Rawnsley
# https://github.com/nriley/brightness/issues/1
#
# @todo add an adjustment factor for secondary display
#
# Requires: brightness, https://github.com/nriley/brightness
#
brightness=/usr/local/bin/brightness
d0=`brightness -l | sed -nE 's/^display 0: brightness ([0-9.]+)$/\1/p'`
brightness -d 1 d0
