#! /usr/bin/env bash

PATH="$SCRIPTS_DIR:/usr/libexec/docker/cli-plugins:$HOME/bin:$HOME/bin/go/bin:$HOME/go/bin:$PATH"
export TMPDIR="$HOME/tmp"

# Claude proxy
export ANTHROPIC_BASE_URL=https://nai-gw.nebius.ts.net/anthropic
export ANTHROPIC_API_KEY=sk-ant-api03-gateway-placeholder

cd ~/ydb

if [ -z "$TMUX" ] ; then
    # Display tmux sessions
    echo "tmux sessions:"
    tmux ls
fi
