#!/usr/bin/env sh
# EXTERN_LINK / $W3M_CURRENT_LINK = under cursor
# EXTERN / $W3M_URL               = current page
echo "W3m-control: BACK"
url="$W3M_CURRENT_LINK"
printf "%b" "$url" > ~/.cache/_w3m_clip_url.txt
printf "%b" "$url" | xsel -b 2>/dev/null 
printf "%b" "$url" | tmux load-buffer - 
printf '%b' "$url" | wl-copy 2>/dev/null  
printf '%b' "$url" | clip 2>/dev/null 
printf '%b' "$url" > /dev/clipboard 2>/dev/null 
printf '%b' "$url" | pbcopy 2>/dev/null 
printf '%b' "$url" | termux-clipboard-set 2>/dev/null
