#! /usr/bin/env bash

set -e

if [ "$1" == "" ] ; then
    echo "Usage: replace_dynconfig.sh FILENAME.yaml"
    exit 1
fi

SLICE_KUBECTL_CONTEXT=bastion-man-man-ydb-dev
JUMP_HOST_NAMESPACE=ydb-dev

YDB_TOKEN=$(npc --profile newbius iam get-access-token)
kubectl config use-context $SLICE_KUBECTL_CONTEXT

# Copy config to jumphost node
kubectl -n $JUMP_HOST_NAMESPACE cp $1 ydb-jump-host-0:/tmp/dynconfig.yaml

# Call ydb admin config replace
kubectl -n $JUMP_HOST_NAMESPACE exec -it ydb-jump-host-0 -- env YDB_TOKEN=$YDB_TOKEN ydb -e grpcs://man0-0505.ydb-dev.ik8s.nebiuscloud.net:2135 -d /ydb-slice-1 admin config replace -f /tmp/dynconfig.yaml
