#! /usr/bin/env bash
set -e

cd $HOME
git clone git@github.com:UgnineSirdis/ydb.git
cd $HOME/ydb
git branch -m main origin-main
git remote add -m main -t main upstream git@github.com:ydb-platform/ydb.git
git fetch upstream main
git checkout -b main upstream/main
