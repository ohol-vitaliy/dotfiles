#!/bin/bash

# If not running interactively, don't do anything
#[ -z "$PS1" ] && return


#if command -v tmux >/dev/null 2>&1; then
	#[ -z "$TMUX" ] && { tmux attach-session -t default || tmux new-session -s default; }
#fi
clear


#if command -v startx >/dev/null 2>&1; then
#if [ ! $DISPLAY && $XDG_VTNR -eq 1 ]; then
	#startx
#fi
#fi


bind 'set completion-ignore-case on'
bind 'set show-all-if-ambiguous on'
bind 'TAB:menu-complete'

#complete -cf sudo
complete -cf man
#complete -W "tmux vim xi xm xr xd bash term alias i3 bar panel rofi nanorc profile sudoers fstab group grub hosts pulseaudio passwd" conf

set -o vi

shopt -s cmdhist
shopt -s histverify
shopt -s histappend
shopt -s checkwinsize
shopt -s autocd
shopt -s cdspell
shopt -s cmdhist
shopt -s dirspell direxpand
shopt -s extglob
shopt -s dotglob
shopt -s globstar
shopt -s no_empty_cmd_completion
shopt -s nocaseglob


shopt -s checkjobs
shopt -s extquote
shopt -s hostcomplete
shopt -s interactive_comments
shopt -s lastpipe
shopt -s nocasematch
shopt -s shift_verbose
#shopt -s nullglob
#shopt -s expand_aliases
#shopt -s lithist
#shopt -s mailwarn


export SHELL=/bin/bash
export TERMINAL=xfce4-terminal
export EDITOR=vim
export READER=zathura
export BROWSER="falkon --no-sandbox"
export HISTFILE=~/.c-history
export SAVEHIST=200000000
export HISTSIZE=20000000000
export HISTCONTROL=ignoreboth:erasedups
export HISTIGNORE="df*:free*:&:ls:[bf]g:history:exit"
export WLAN_INTERFACE=wlan0
export LESS='-R -g -w'
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

if command -v xrandr >/dev/null 2>&1; then
	export MONITOR_ONE=$(xrandr -q | grep connected | awk 'NR==1{print $1}')
	export MONITOR_TWO=$(xrandr -q | grep connected | awk 'NR==2{print $1}')
else
	echo "XRANDR not installed..."
fi


if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias dir='dir —color=auto'
    alias vdir='vdir —color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi
set complete_aliases
#export TZ="Europe/Warsaw"
#export LANG="en_GB.UTF-8"
#export LANGUAGE="en_GB.UTF-8"
#export LC_ADDRESS="en_GB.UTF-8"
#export LC_COLLATE="en_GB.UTF-8"
#export LC_CTYPE="en_GB.UTF-8"
#export LC_IDENTIFICATION="en_GB.UTF-8"
#export LC_MEASUREMENT="en_GB.UTF-8"
#export LC_MESSAGES="en_GB.UTF-8"
#export LC_MONETARY="en_GB.UTF-8"
#export LC_NAME="en_GB.UTF-8"
#export LC_NUMERIC="en_GB.UTF-8"
#export LC_PAPER="en_GB.UTF-8"
#export LC_TELEPHONE="en_GB.UTF-8"
#export LC_TIME="en_GB.UTF-8"
#export LC_ALL="en_GB.UTF-8"


git config --global user.email "ohol.vitaliy@gmail.com"
git config --global user.name "MisterVitaliy"

if command -v neofetch >/dev/null 2>&1; then
	neofetch
else
	echo 'NEOFETCH not installed...'
fi

if command -v screenfetch >/dev/null 2>&1; then
	screenfetch
else
	echo 'SCREENFETCH not installed...'
fi


#export WORKON_HOME=$HOME/.py_workspace
#export SCRIPT_FOLDER=' '
#export DISTRO=$(cat /etc/os-release | grep ID | head -n 1 | cut -d= -f2)
#export DISTRO=${DISTRO:-debian}
#export JAVA_HOME=/usr/lib/jvm/java-10-openjdk-amd64
#export PATH=$PATH:$JAVA_HOME/bin

if ! shopt -oq posix; then
	if [ -f /usr/share/bash-completion/bash_completion ]; then
		source /usr/share/bash-completion/bash_completion
	elif [ -f /etc/bash_completion ]; then
		source /etc/bash_completion
	elif [ -f /usr/local/etc/bash_completion ]; then
		source /usr/local/etc/bash_completion
	fi
fi
if [ -d /etc/bash_completion.d/ ]; then
	for file in /etc/bash_completion.d/* ; do
		source "$file"
	done
fi


[ -d "$HOME/.config/scripts" ] && export PATH="$HOME/.config/scripts:$PATH"
[ ! -d ~/Documents ]           && mkdir ~/Documents   || echo "Documents already exist"
[ ! -d ~/Downloads ]           && mkdir ~/Downloads   || echo "Downloads already exist"
[ ! -d ~/Music ]               && mkdir ~/Music       || echo "Music already exist"
[ ! -d ~/Pictures ]            && mkdir ~/Pictures    || echo "Pictures already exist"
[ ! -d ~/Videos ]              && mkdir ~/Videos      || echo "Videos already exist"
[ -f ~/.bash_prompt ]          && source ~/.bash_prompt
[ -f ~/.aliasrc ]              && source ~/.aliasrc
[ -f ~/.fzf.bash ]             && source ~/.fzf.bash

# Add sbin directories to PATH.  This is useful on systems that have sudo
#[ -z "${PATH##*/sbin*}" ] || PATH=$PATH:/sbin:/usr/sbin

# set variable identifying the chroot you work in (used in the prompt below)
#if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    #debian_chroot=$(cat /etc/debian_chroot)
#fi
