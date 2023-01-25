#!/usr/bin/env sh
w3m_tmp=~/.cache/_w3m_ua.txt
ua=$(cat "$w3m_tmp")

echo "W3m-control: SET_OPTION user_agent=$ua"
echo "W3m-control: BACK"
echo "W3m-control: RELOAD"
echo "W3m-control: REDRAW"
