#!/usr/bin/env sh
echo "W3m-control: BACK"
FILE="$HOME/.w3m/RestoreTab.txt"
LAST_TAB=$(tail -n 1 "$FILE")                   # Open the last closed tab
sed -i '$d' "$FILE"
echo "W3m-control: TAB_GOTO $LAST_TAB"
echo "W3m-control: DELETE_PREVBUF"
