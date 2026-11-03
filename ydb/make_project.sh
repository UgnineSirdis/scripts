#! /usr/bin/env bash
set -e

INPUT_DIR=${DIR:-ydb}
REPO_DIR=$HOME/$INPUT_DIR

cd $REPO_DIR
PROJECT=$INPUT_DIR
PROJECT_DIR=$HOME/projects/$PROJECT
mkdir -p $PROJECT_DIR
./ya ide vscode-clangd -P $PROJECT_DIR -W $PROJECT --use-arcadia-root --setup-tidy ydb
