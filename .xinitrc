#!/bin/sh

dbus-update-activation-environment --systemd DBUS_SESSION_BUS_ADDRESS DISPLAY XAUTHORITY &

pulseaudio -D &
dunst &
compton &
pcmanfm --daemon-mode &
# sxhkd &
# nm-applet &
# volumeicon &

feh --bg-scale ~/.config/wall.* &
setxkbmap -option caps:escape 
#-option grp:alt_shift_toggle us,ua

st &

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
   batt=$(acpi | awk -F ', ' '{ print $2 }' | xargs -I {} sh -c "echo {} | dbar -nonl -w 10")
   wifi=$(nmcli c show --active | grep wifi | awk '{print $1}')
   bright=$(brightnessctl -m | awk -F, '{ print $4 }' | dbar -nonl -w 10)
   mute=$(pulsemixer --get-mute)
   volume=$(pulsemixer --get-volume)

   if [ $mute -eq 1 ]; then
	   volume="M"
   fi

   topbar="| ${wifi:=NC} | $(date +"%F %R") |"
   bottombar=" Vol: $volume | Bright:$bright |;| Bat: $ac$batt ($thermal°C) |"

   xsetroot -name "$topbar;$bottombar"
   sleep 0.1s
done &

exec dwm
