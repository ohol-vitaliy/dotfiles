#!/usr/bin/env sh
echo "W3m-control: SET_OPTION default_url=0"
echo "W3m-control: GOTO $(cat ~/.cache/_w3m_clip_url.txt)"
echo "W3m-control: DELETE_PREVBUF"
echo "W3m-control: SET_OPTION default_url=1"
