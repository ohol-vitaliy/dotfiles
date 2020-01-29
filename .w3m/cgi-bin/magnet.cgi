#!/usr/bin/env sh
# REQD:   1. touch ~/.w3m/urimethodmap
#         2. echo "magnet: file:/cgi-bin/magnet.cgi?%s" >> ~/.w3m/urimethodmap
#         3. chmod +x ~/.w3m/cgi-bin/magnet.cgi
#         4. sed -i 's@cgi_bin.*@cgi_bin ~/.w3m/cgi-bin:/usr/lib/w3m/cgi-bin:/usr/local/libexec/w3m/cgi-bin@g' ~/.w3m/config
#         5. sed -i 's@urimethodmap.*@urimethodmap ~/.w3m/urimethodmap, /usr/etc/w3m/urimethodmap@g' ~/.w3m/config
QUERY_STRING="$(printf "%s" "$QUERY_STRING" | sed -e "s/%\([0-9A-F][0-9A-F]\)/\\\\\x\1/g" | xargs -0 echo -e)"
transmission-remote --add "$QUERY_STRING"
printf "%s\r\n" "W3m-control: BACK"
