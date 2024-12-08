#! /usr/bin/env bash
set -e

cd $HOME
git clone git@github.com:UgnineSirdis/ydb.git
git branch -m main origin-main
git fetch upstream main
git checkout upstream/main
git branch -m upstream/main main
