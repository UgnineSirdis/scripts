#! /usr/bin/env bash

set -e

if [ "$1" == "" ] ; then
    echo "Usage: replace_dynconfig.sh FILENAME.yaml"
    exit 1
fi

YDB_TOKEN=$(npc --profile newbius iam get-access-token)
kubectl config use-context ik8s-beta

# Copy config to jumphost node
kubectl -n ydb-global cp $1 ydb-jump-host-0:/tmp/dynconfig.yaml

# Call ydb admin config replace
kubectl -n ydb-global exec -it ydb-jump-host-0 -- env YDB_TOKEN=$YDB_TOKEN ydb -e grpcs://man0-0505.ydb-dev.ik8s.nebiuscloud.net:2135 -d /ydb-slice-1 admin config replace -f /tmp/dynconfig.yaml
