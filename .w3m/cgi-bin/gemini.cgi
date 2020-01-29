#!/usr/bin/env sh
# gemini://gempaper.strangled.net/mirrorlist/
# gemini://simplynews.metalune.xyz
# gemini://geminispace.info/search?tmux

# remove gemini:// header
QUERY_STRING=$(echo "$QUERY_STRING" | cut -d '/' -f3-)

if [ "$(curl --connect-timeout 1 -s -I "https://portal.mozz.us/about" | head -n1 | grep 200 > /dev/null && echo $? )" = 0 ]; then
  echo "W3m-control: GOTO https://portal.mozz.us/gemini/$QUERY_STRING"
elif [ "$(curl --connect-timeout 1 -s -I "https://proxy.vulpes.one" | head -n1 | grep 200 > /dev/null && echo $? )" = 0 ]; then
  echo "W3m-control: GOTO https://proxy.vulpes.one/gemini/$QUERY_STRING"
else
  echo "W3m-control: GOTO https://gemproxy.koyu.space/$QUERY_STRING"
fi
