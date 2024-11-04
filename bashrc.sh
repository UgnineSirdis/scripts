#! /usr/bin/env bash

_BLACK='\[\033[0;30m\]'
_DARK_GREY='\[\033[1;30m\]'
_RED='\[\033[0;31m\]'
_LIGHT_RED='\[\033[1;31m\]'
_GREED='\[\033[0;32m\]'
_LIGHT_GREEN='\[\033[1;32m\]'
_ORANGE='\[\033[0;33m\]'
_YELLOW='\[\033[1;33m\]'
_BLUE='\[\033[0;34m\]'
_LIGHT_BLUE='\[\033[01;34m\]'
_PURPLE='\[\033[0;35m\]'
_LIGHT_PURPLE='\[\033[1;35m\]'
_CIAN='\[\033[0;36m\]'
_LIGHT_CIAN='\[\033[1;36m\]'
_LIGHT_GREY='\[\033[0;37m\]'
_WHITE='\[\033[01;37m\]'
_USUAL='\[\033[00m\]'

SERVER_NAME=""
if test -f "$HOME/.servername" ; then
    SERVER_NAME=$(cat "$HOME/.servername")
    SERVER_NAME="$_WHITE$SERVER_NAME$_USUAL:"
fi

export PS1="$SERVER_NAME$_LIGHT_BLUE\w$_USUAL\$ "

export TMPDIR="$HOME/tmp"

ulimit -c unlimited

alias ll='ls -alF --color=auto'
alias ..='cd ..'

alias cdr='cd $($SCRIPTS_DIR/repository_root.py)'

alias ya='$($SCRIPTS_DIR/repository_root.py)/ya'

# build
alias yab='$($SCRIPTS_DIR/repository_root.py)/ya make --build relwithdebinfo'

# build and test
alias yat='$($SCRIPTS_DIR/repository_root.py)/ya make -t -A --build relwithdebinfo'

# tmux
alias ta='tmux attach -t'
alias tls='tmux ls'

# Fix SSH auth socket location so agent forwarding works with tmux
if test "$SSH_AUTH_SOCK" ; then
    if [ "$SSH_AUTH_SOCK" != "$HOME/.ssh/ssh_auth_sock" ] ; then
        echo "Linking SSH_AUTH_SOCK ($SSH_AUTH_SOCK) as ~/.ssh/ssh_auth_sock"
        ln -sf $SSH_AUTH_SOCK $HOME/.ssh/ssh_auth_sock
        export PREV_SSH_AUTH_SOCK=$SSH_AUTH_SOCK
        export SSH_AUTH_SOCK=$HOME/.ssh/ssh_auth_sock
    fi
else
    echo "SSH_AUTH_SOCK variable is empty"
fi
