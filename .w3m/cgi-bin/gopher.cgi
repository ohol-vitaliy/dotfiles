#!/usr/bin/env sh
# gopher://bitreich.org/1/lawn
# gopher://hngopher.com/
# gopher://bay.parazy.de:666

proxycheck() { curl --connect-timeout 1 -s -I "$1" | head -n1 | grep 200 > /dev/null && echo $? ;}

if [ "$(proxycheck "https://gopher.floodgap.com/gopher/")" = 0 ]; then
  echo "W3m-control: GOTO https://gopher.floodgap.com/gopher/gw?$QUERY_STRING"
else
  echo "W3m-control: GOTO https://gopherproxy.meulie.net/$QUERY_STRING"
fi
