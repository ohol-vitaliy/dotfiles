#!/bin/sh

# pulseaudio -D &
# dunst &
compton &
# sxhkd &
# nm-applet &
# volumeicon &

feh --bg-scale ~/.config/wall.* &

# betterlockscreen -u ~/.config/wall.*
# betterlockscreen -w
# xautolock -time 10 -locker "betterlockscreen -l dimblur" -corners 0--- &

# SYSSESSIONDIR=/etc/X11/Xsession.d
# SESSIONFILES=$(run-parts --list $SYSSESSIONDIR)
# if [ -n "$SESSIONFILES" ]; then
#   set +e
#   for SESSIONFILE in $SESSIONFILES; do
#     . $SESSIONFILE
#   done
#   set -e
# fi

xinput set-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation" 1
xinput set-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation Button" 2
xinput set-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation Timeout" 200
xinput set-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation Axes" 6 7 4 5

# xinput set-int-prop "SynPS/2 Synaptics TouchPad" "Synaptics Off" 8 1
#xinput set-int-prop "SynPS/2 Synaptics TouchPad" "Synaptics Tap Action" 8 1 2 0 0 0 0 0
xinput set-prop --type=int --format=8 "SynPS/2 Synaptics TouchPad" "Synaptics Tap Action" 1 1 1 2 1 3
xinput set-prop --type=int --format=8 "SynPS/2 Synaptics TouchPad" "Synaptics Two-Finger Scrolling" 1 1


while true; do
   # xsetroot -name " | $(keyboard) | $(bright) | $(volume) | $(ram) | $(battery) | $( date +"%F %R" ) | "
   if acpi -a | grep -q on-line; then
	   ac="+"
   else
	   ac=""
   fi

   thermal=$(acpi -t | awk -F ' ' '{print $4 }')
   batt=$(acpi | awk -F ', ' '{ print $2 }' | paste -d ' ' - -)
   xsetroot -name "| $ac $batt ($thermal°C) | $(date +"%F %R")"
   sleep 20s
done &

exec dwm
