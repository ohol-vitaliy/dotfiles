#!/usr/bin/env sh
# gemini://gempaper.strangled.net/mirrorlist/
# gemini://simplynews.metalune.xyz
# gemini://geminispace.info/search?tmux

proxycheck() { [ "$(curl --connect-timeout 1 -so /dev/null -w '%{http_code}' -I "$1")" = 200 ] ;}

# remove gemini:// header
QUERY_STRING=${QUERY_STRING#*//}

if proxycheck "https://portal.mozz.us/about"; then
  echo "W3m-control: GOTO https://portal.mozz.us/gemini/$QUERY_STRING"
elif proxycheck "https://proxy.vulpes.one"; then
  echo "W3m-control: GOTO https://proxy.vulpes.one/gemini/$QUERY_STRING"
else
  echo "W3m-control: GOTO https://gemproxy.koyu.space/$QUERY_STRING"
fi
