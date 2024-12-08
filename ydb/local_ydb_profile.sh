#! /usr/bin/env bash
set -e

mkdir -p $HOME/ydb/config
cp $HOME/scripts/ydb/local_ydb_profile.yaml $HOME/ydb/config/config.yaml
