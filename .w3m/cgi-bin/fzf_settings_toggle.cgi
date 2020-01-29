#!/usr/bin/env sh

export W3M_SETTING_MODE=xsession

TGL_BRDR='toggle_border'
TGL_IMG='toggle_image'
TGL_LINK_NUM='toggle_link_number'

SELECTED=$(cat <<EOF | fzf
$TGL_BRDR
$TGL_IMG
$TGL_LINK_NUM
EOF
)

[ -z "$SELECTED" ] && exit

case "$SELECTED" in
	$TGL_BRDR)
		printf 'W3m-control: SET_OPTION display_borders=toggle\n'
		printf 'W3m-control: BACK\n'
		printf 'W3m-control: RESHAPE\n'
		;;
	$TGL_IMG)
		printf 'W3m-control: SET_OPTION display_image=toggle\n'
		printf 'W3m-control: BACK\n'
		printf 'W3m-control: RELOAD\n'
		;;
	$TGL_LINK_NUM)
		printf 'W3m-control: SET_OPTION display_link_number=toggle\n'
		printf 'W3m-control: BACK\n'
		printf 'W3m-control: RESHAPE\n'
		;;
esac
