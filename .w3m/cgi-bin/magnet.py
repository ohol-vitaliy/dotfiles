#!/usr/bin/env python
# 1. vim ~/.w3m/urimethodmap
#       magnet: file:/cgi-bin/magnet.py?%s
# 2. mv magnet.py ~/.w3m/cgi-bin/magnet.py
# 3. edit ==> cmd_list = ("transmission-remote", "-a", uri)
# 4. chmod +x ~/.w3m/cgi-bin/magnet.py
import sys
import os
import subprocess

uri = os.environ.get('QUERY_STRING')
referer = os.environ.get('HTTP_REFERER')

if not uri:
    print()
    print("Error: No URI")
    sys.exit()

cmd_list = ("transmission-remote", "-a", uri)
subprocess.call(cmd_list)

if referer:
    print("HTTP/1.1 303 See Other")
    print("Location: %s" % referer)

