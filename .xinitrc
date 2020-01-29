#!/usr/bin/env bash

export _JAVA_AWT_WM_NONREPARENTING=1
export AWT_TOOLKIT=MToolkit
dbus-update-activation-environment --systemd DBUS_SESSION_BUS_ADDRESS DISPLAY XAUTHORITY &

# pulseaudio -D &
# dunst &
# compton &
# picom &
# pcmanfm --daemon-mode &
# sxhkd &
# nm-applet &
# volumeicon &

xset dpms 60 0 0
feh --bg-scale ~/.config/wall.* &
# hsetroot -solid "#fcfdfe" &
setxkbmap -option caps:escape # -option grp:alt_shift_toggle us,ua

st &
# firefox-esr &
# cams.py &

# betterlockscreen -u ~/.config/wall.*
# betterlockscreen -w
# xautolock -time 10 -locker "betterlockscreen -l dimblur" -corners 0--- &
# xautolock -time 10 -locker "setxkbmap us; i3lock-fancy" -notify 60 -notifier "notify-send -u critical -t 10000 -- 'LOCKING screen in 60 seconds'"

xinput set-prop "Touchpad0" "Evdev Wheel Emulation" 1
xinput set-prop "Touchpad0" "Evdev Wheel Emulation Button" 2
xinput set-prop "Touchpad0" "Evdev Wheel Emulation Timeout" 200
xinput set-prop "Touchpad0" "Evdev Wheel Emulation Axes" 6 7 4 5
xinput set-prop "Touchpad0" "Synaptics Finger" 5 10 0

# xinput set-int-prop "Touchpad0" "Synaptics Off" 8 1
# xinput set-int-prop "Touchpad0" "Synaptics Tap Action" 8 1 2 0 0 0 0 0
xinput set-prop --type=int --format=8 "Touchpad0" "Synaptics Tap Action" 1 1 1 2 1 3
xinput set-prop --type=int --format=8 "Touchpad0" "Synaptics Two-Finger Scrolling" 1 1

while true; do
	batt=$(/usr/bin/_battery)
	ram=$(/usr/bin/_ram)
	cpu=$(/usr/bin/_cpu)
	wifi=$(/usr/bin/_wlan name)
	bright=$(/usr/bin/_bright)
	volume=$(/usr/bin/_volume)

	topbar="| ${wifi:=NC} | $cpu | $ram | $(printf '%(%F %R)T') |"
	bottombar=" $volume | $bright |;| $batt |"

	xsetroot -name "$topbar;$bottombar"
	sleep 5s
done &

exec dwm
