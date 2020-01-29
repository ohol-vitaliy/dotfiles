#!/usr/bin/env ash

export _JAVA_AWT_WM_NONREPARENTING=1
export AWT_TOOLKIT=MToolkit
dbus-update-activation-environment --systemd DBUS_SESSION_BUS_ADDRESS DISPLAY XAUTHORITY &

# compton &
# picom &
# pcmanfm --daemon-mode &
# firefox-esr &
# cams.py &

xset dpms 60 0 0
xset +dpms
# feh --bg-scale ~/.config/wall.* &
setxkbmap -option caps:escape # -option grp:alt_shift_toggle us,ua

st -e 'tmux' &

xinput set-prop "Touchpad0" "Evdev Wheel Emulation" 1
xinput set-prop "Touchpad0" "Evdev Wheel Emulation Button" 2
xinput set-prop "Touchpad0" "Evdev Wheel Emulation Timeout" 200
xinput set-prop "Touchpad0" "Evdev Wheel Emulation Axes" 6 7 4 5
xinput set-prop "Touchpad0" "Synaptics Finger" 5 10 0
# xinput set-int-prop "Touchpad0" "Synaptics Off" 8 1
# xinput set-int-prop "Touchpad0" "Synaptics Tap Action" 8 1 2 0 0 0 0 0
xinput set-prop --type=int --format=8 "Touchpad0" "Synaptics Tap Action" 1 1 1 2 1 3
xinput set-prop --type=int --format=8 "Touchpad0" "Synaptics Two-Finger Scrolling" 1 1

exec dwm
