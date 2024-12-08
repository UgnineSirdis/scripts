#! /usr/bin/env bash
set -e

cd $HOME/ydb
PROJECT=ydb
DIR=$HOME/projects/$PROJECT
mkdir -p $DIR
./ya ide vscode-clangd -P $DIR -W $PROJECT --use-arcadia-root --setup-tidy ydb
