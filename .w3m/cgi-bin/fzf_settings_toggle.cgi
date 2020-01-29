#!/usr/bin/env sh

export W3M_SETTING_MODE=xsession

TGL_BRDR='toggle_border'
TGL_IMG='toggle_image'
TGL_LINK_NUM='toggle_link_number'

SELECTED=$(printf '%s\n' "$TGL_BRDR" "$TGL_IMG" "$TGL_LINK_NUM" | fzf)

[ -z "$SELECTED" ] && exit

case "$SELECTED" in
	"$TGL_BRDR") opt=display_borders act=RESHAPE ;;
	"$TGL_IMG") opt=display_image act=RELOAD ;;
	"$TGL_LINK_NUM") opt=display_link_number act=RESHAPE ;;
	*) exit ;;
esac

printf 'W3m-control: SET_OPTION %s=toggle\nW3m-control: BACK\nW3m-control: %s\n' "$opt" "$act"

