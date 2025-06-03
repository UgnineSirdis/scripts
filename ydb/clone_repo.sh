#! /usr/bin/env bash
set -e

DIR=$1
if [ -z "$DIR" ] ; then
    DIR=ydb
fi

cd $HOME
git clone git@github.com:UgnineSirdis/ydb.git $DIR
cd $HOME/$DIR
git branch -m main origin-main
git remote add -m main upstream git@github.com:ydb-platform/ydb.git
git fetch upstream main
git checkout -b main upstream/main
