#! /usr/bin/env bash

PATH="$SCRIPTS_DIR:/usr/libexec/docker/cli-plugins:$HOME/bin:$HOME/bin/go/bin:$HOME/go/bin:$PATH"
export TMPDIR="$HOME/tmp"

cd ~/ydb

if [ -z "$TMUX" ] ; then
    # Display tmux sessions
    echo "tmux sessions:"
    tmux ls
fi
