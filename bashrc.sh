#! /usr/bin/env bash

_BLUE='\[\033[01;34m\]'
_USUAL='\[\033[00m\]'
export PS1="$_BLUE\w$_USUAL\$ "

export TMPDIR="$HOME/tmp"

ulimit -c unlimited

alias ll='ls -alF --color=auto'
alias ..='cd ..'

alias scr='screen -d -R -S main1'
alias scr1='screen -d -R -S main1'
alias scr2='screen -d -R -S main2'
alias scr3='screen -d -R -S main3'
alias scr4='screen -d -R -S main4'
alias scr5='screen -d -R -S main5'
alias scr6='screen -d -R -S main6'

alias lscr='screen -list'

alias cdr='cd $($SCRIPTS_DIR/repository_root.py)'

alias ya='$($SCRIPTS_DIR/repository_root.py)/ya'

# build
alias yab='$($SCRIPTS_DIR/repository_root.py)/ya make --build relwithdebinfo'

# build and test
alias yat='$($SCRIPTS_DIR/repository_root.py)/ya make -t -A --build relwithdebinfo'

# Fix SSH auth socket location so agent forwarding works with tmux
if test "$SSH_AUTH_SOCK" ; then
    ln -sf $SSH_AUTH_SOCK ~/.ssh/ssh_auth_sock
fi

SSH_AUTH_SOCK=~/.ssh/ssh_auth_sock
