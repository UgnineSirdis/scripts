#! /usr/bin/env bash

PATH="$HOME/bin/tmux/bin:$SCRIPTS_DIR:/usr/libexec/docker/cli-plugins:$HOME/bin:$HOME/bin/go/bin:$HOME/go/bin:$PATH"
export TMPDIR="$HOME/tmp"

# Claude proxy
export ANTHROPIC_BASE_URL=https://ai-gateway.nebius.dev/anthropic
export ANTHROPIC_API_KEY=sk-ant-api03-gateway-placeholder
export CLAUDE_CODE_GATEWAY_HINT_HEADERS=1

cd ~/ydb

if [ -z "$TMUX" ] ; then
    # Display tmux sessions
    echo "tmux sessions:"
    tmux ls
fi
