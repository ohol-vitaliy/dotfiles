#!/bin/sh

export _JAVA_AWT_WM_NONREPARENTING=1
export AWT_TOOLKIT=MToolkit
dbus-update-activation-environment --systemd DBUS_SESSION_BUS_ADDRESS DISPLAY XAUTHORITY &

pulseaudio -D &
dunst &
# compton &
picom &
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
	batt=$(/home/zeroring/.config/scripts/battery)
	ram=$(/home/zeroring/.config/scripts/ram)
	cpu=$(/home/zeroring/.config/scripts/cpu)
	wifi=$(/home/zeroring/.config/scripts/wifi)
	bright=$(/home/zeroring/.config/scripts/bright)
	volume=$(/home/zeroring/.config/scripts/volume)

	topbar="| ${wifi:=NC} | $cpu | $ram | $(date +"%F %R") |"
	bottombar=" $volume | $bright |;| $batt |"

	xsetroot -name "$topbar;$bottombar"
	sleep 0.2s
done &

exec dwm
