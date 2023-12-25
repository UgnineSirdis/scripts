#! /usr/bin/env bash

export PS1='\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\[\e[32;1m\]\u\[\033[00m\]@\[\e[31;1m\]\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

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
