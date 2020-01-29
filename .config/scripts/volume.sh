#!/bin/sh
if [ "$1" = "inc" ]; then
	amixer set Master "$2"%+ > /dev/null 2>&1; notify-send ":VOLUME:" "$($0)"
elif [ "$1" = "dec" ]; then
	amixer set Master "$2"%- > /dev/null 2>&1; notify-send ":VOLUME:" "$($0)"
elif [ "$1" = "toggle" ]; then
	amixer set Master toggle > /dev/null 2>&1; notify-send ":VOLUME:" "$($0)"
else
	mute=$(amixer get Master | grep -Eo "\[(on|off)\]")
	volumes=$(amixer get Master | grep -Eo "[0-9]{1,3}%")
	if [ "$mute" = "[on]" ]; then
		mute="+"
	else
		mute="\-\-"
	fi
	echo "$mute $volumes"
	exit 0
fi
