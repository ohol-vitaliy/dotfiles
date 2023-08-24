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
	batt=$(
		acpi -abt | sort | awk -F "(,|:)" ' 
		/^Adapter.*on-line/ { printf "CHRG " }
		/^Batt/ { 
			label = " " $1 ":"; 
			gsub(/tery /, "", label)
			command = "dbar -nonl -w 11 -l \"" label "\"";
			print $3 | command;
		}
		/^Therm/ { 
			therm = substr($3, 0, 5);
			gsub(/\s+/, "", therm);
			printf " (" therm "°C) ";
		}'
	)
	ram=$(
		awk '
		/MemTotal/ { total = $2/1024/1024 }
		/MemAvailable/ { avail = $2/1024/1024 }
		END { printf "RAM %.2f GB/%.2f GB", total-avail, avail }
		' /proc/meminfo
	)
	wifi=$(nmcli c show --active | awk '/wifi/ {print $1}')
	bright=$(brightnessctl -m | awk -F, '{ print $4 }' | dbar -nonl -w 10 -l "Bright:")
	volume=$(
		pulsemixer --get-mute --get-volume | awk '
		BEGIN { printf "Vol: " }  
		NR == 1 && $0 == "1"  { printf "Mute"; exit; } 
		NR == 2 { 
			command = "dbar -nonl -w 11" 
			vol = ($1 + $2)/2;
			printf vol | command
		}'
	)
	topbar="| ${wifi:=NC} | $ram | $(date +"%F %R") |"
	bottombar=" $volume | $bright |;| $batt |"

	xsetroot -name "$topbar;$bottombar"
	sleep 0.2s
done &

exec dwm
