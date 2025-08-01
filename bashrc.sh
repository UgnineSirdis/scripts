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
# debug build with exact debug flags in vscode
alias yabd='$($SCRIPTS_DIR/repository_root.py)/ya make -d -DBUILD_LANGUAGES=CPP -DCONSISTENT_DEBUG=yes -DOPENSOURCE=yes -DUSE_PREBUILT_TOOLS=no -DAPPLE_SDK_LOCAL=yes -DUSE_CLANG_CL=yes -DUSE_AIO=static -DUSE_ICONV=static -DUSE_IDN=static -DCFLAGS=-fno-omit-frame-pointer'

# build and test
alias yat='$($SCRIPTS_DIR/repository_root.py)/ya make -t -A --build relwithdebinfo'
# debug build and test with exact debug flags in vscode
alias yatd='$($SCRIPTS_DIR/repository_root.py)/ya make -d -DBUILD_LANGUAGES=CPP -DCONSISTENT_DEBUG=yes -DOPENSOURCE=yes -DUSE_PREBUILT_TOOLS=no -DAPPLE_SDK_LOCAL=yes -DUSE_CLANG_CL=yes -DUSE_AIO=static -DUSE_ICONV=static -DUSE_IDN=static -DCFLAGS=-fno-omit-frame-pointer -t -A'

# tmux
alias ta='tmux attach -t'
alias tls='tmux ls'

# local_ydb
alias build_restart_local_ydb='~/ydb/ya make --build relwithdebinfo ~/ydb/ydb/apps/ydbd ~/ydb/ydb/public/tools/local_ydb ~/ydb/ydb/apps/ydb && pgrep -u $USER ydbd | xargs --no-run-if-empty kill && MON_PORT=28040 GRPC_PORT=17690 GRPC_TLS_PORT=17691 IC_PORT=17692 GRPC_EXT_PORT=17693 PUBLIC_HTTP_PORT=28041 ~/ydb/ydb/public/tools/local_ydb/local_ydb start --ydb-binary-path ~/ydb/ydb/apps/ydbd/ydbd --fixed-ports --ydb-working-dir'
alias restart_local_ydb='pgrep -u $USER ydbd | xargs --no-run-if-empty kill && MON_PORT=28040 GRPC_PORT=17690 GRPC_TLS_PORT=17691 IC_PORT=17692 GRPC_EXT_PORT=17693 PUBLIC_HTTP_PORT=28041 ~/ydb/ydb/public/tools/local_ydb/local_ydb start --ydb-binary-path ~/ydb/ydb/apps/ydbd/ydbd --fixed-ports --ydb-working-dir'
alias deploy_local_ydb='pgrep -u $USER ydbd | xargs --no-run-if-empty kill && MON_PORT=28040 GRPC_PORT=17690 GRPC_TLS_PORT=17691 IC_PORT=17692 GRPC_EXT_PORT=17693 PUBLIC_HTTP_PORT=28041 ~/ydb/ydb/public/tools/local_ydb/local_ydb deploy --ydb-binary-path ~/ydb/ydb/apps/ydbd/ydbd --fixed-ports --ydb-working-dir'

# vscode
alias clear_vscode_proc='pgrep -f -u $USER .vscode-server | xargs --no-run-if-empty kill && pgrep -f -u $USER .ya/tools | xargs --no-run-if-empty kill'

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
