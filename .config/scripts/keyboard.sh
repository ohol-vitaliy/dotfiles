#!/bin/sh
! [ -z "$DISPLAY" ] && xkb=$(setxkbmap -query | grep layout | awk '{ print $2 }')
echo "$xkb"
