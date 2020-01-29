#!/usr/bin/env sh

export _JAVA_AWT_WM_NONREPARENTING=1
export AWT_TOOLKIT=MToolkit
dbus-update-activation-environment --systemd DBUS_SESSION_BUS_ADDRESS DISPLAY XAUTHORITY &

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

TMP_HOME="/tmp/$USER"
mkdir -p "$TMP_HOME"

FILES="
.viminfo
.bash_history
.openocd_history
.python_history
.sqlite_history
.lesshst
.wget-hsts
"

for file in $FILES; do
	# if ! [ -f "$HOME/$file" ]; then
	# 	continue
	# fi

	rm -f "$HOME/$file"
	touch "$TMP_HOME/$file"
	ln -sfn "$TMP_HOME/$file" "$HOME/$file"
done

# Remove stale X11 auth files (they are recreated automatically)
rm -f "$HOME"/.serverauth*

# Create cache symlink
rm -rf "$HOME/.cache"
mkdir -p "$TMP_HOME/.cache"
ln -sfn "$TMP_HOME/.cache" "$HOME/.cache"

if [ -r "$HOME/.config/custom.sh" ]; then
	. "$HOME/.config/custom.sh"

	if command -v __xinit_custom_init >/dev/null 2>&1; then
		__xinit_custom_init
	fi
fi

exec dwm
