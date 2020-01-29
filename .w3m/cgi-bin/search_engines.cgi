#!/usr/bin/env sh
# search engine alias
PREFIX=$(echo "$QUERY_STRING" | cut -d ':' -f1)

# user input keywords
INPUT=$(echo "$QUERY_STRING" | cut -d ':' -f2- | sed 's/,/%20/g')

# check if w3m version has native gopher support
GOPHER_PROTOCOL_ENABLE=$(w3m -version | grep -c "gopher")

case $PREFIX in
  ib|yt)
    echo "W3m-control: GOTO https://codemadness.org/idiotbox/?q=$INPUT&o=relevance"
    ;;
  man)
    echo "W3m-control: GOTO https://mankier.com/1/$INPUT"
    ;;
  1x)
    echo "W3m-control: GOTO https://1337x.to/search/$INPUT/1/"
    ;;
  dd)
    echo "W3m-control: GOTO https://lite.duckduckgo.com/lite/?q=$INPUT&kf=-1&kz=-1&kq=-1&kv=-1&k1=-1&kp=-2&kaf=1&kd=-1&kf=-1&kz=-1&kq=-1&kv=-1"
    ;;
  gg)
    echo "W3m-control: GOTO https://www.google.com/search?q=$INPUT"
    ;;
  gs)
    echo "W3m-control: GOTO https://portal.mozz.us/gemini/geminispace.info/search%3F$INPUT"
    ;;
  rd) # goto a subreddit by name
    echo "W3m-control: GOTO https://www.reddit.com/r/$INPUT/.mobile"
    ;;
  wi)
    echo "W3m-control: GOTO https://en.wikipedia.org/w/index.php?search=$INPUT&title=Special%3ASearch&profile=default&fulltext=1&ns0=1"
    ;;
  v2) # veronica-2 search gopherspace (use web proxy if no native support)
    if [ "$GOPHER_PROTOCOL_ENABLE" = 0 ] ; then
      echo "W3m-control: GOTO https://gopher.floodgap.com/gopher/gw?ss=gopher%3A%2F%2Fgopher.floodgap.com%2F7%2Fv2%2Fvs&sq=$INPUT"
    else
      echo "W3m-control: GOTO gopher://gopher.floodgap.com/7/v2/vs?$INPUT"
    fi
    ;;
esac

# delete temp buffer
echo "W3m-control: DELETE_PREVBUF"
