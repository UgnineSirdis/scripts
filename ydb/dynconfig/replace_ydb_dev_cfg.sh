#! /usr/bin/env bash
set -e

if [ "$1" == "" ] ; then
    SCRIPT_NAME=$(basename "$0")
    echo "Usage: $SCRIPT_NAME FILENAME.yaml"
    exit 1
fi

SLICE_KUBECTL_CONTEXT=bastion-man-man-ydb-dev
JUMP_HOST_NAMESPACE=ydb-dev
CLUSTER_GRPC_ENDPOINT=grpcs://dev-storage-grpc.ydb-dev.svc.cluster.local:2135
CLUSTER_DATABASE=/dev
NPC_PROFILE=newbius

YDB_TOKEN=$(npc --profile $NPC_PROFILE iam get-access-token)
kubectl config use-context $SLICE_KUBECTL_CONTEXT

# Copy config to jumphost node
kubectl -n $JUMP_HOST_NAMESPACE cp $1 ydb-jump-host-0:/tmp/dynconfig.yaml

# Call ydb admin config replace
kubectl -n $JUMP_HOST_NAMESPACE exec -it ydb-jump-host-0 -- env YDB_TOKEN=$YDB_TOKEN ydb -e $CLUSTER_GRPC_ENDPOINT -d $CLUSTER_DATABASE admin config replace -f /tmp/dynconfig.yaml
