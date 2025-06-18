#! /usr/bin/env bash
set -e

if [ "$1" == "" ] ; then
    SCRIPT_NAME=$(basename "$0")
    echo "Usage: $SCRIPT_NAME FILENAME.yaml"
    exit 1
fi

SLICE_KUBECTL_CONTEXT=bastion-man-man-ydb-dev
JUMP_HOST_NAMESPACE=ydb-dev
CLUSTER_GRPC_ENDPOINT=grpcs://storage-grpc.ydb-slice-1.svc.cluster.local:2135
CLUSTER_DATABASE=/ydb-slice-1
NPC_PROFILE=newbius

YDB_TOKEN=$(npc --profile $NPC_PROFILE iam get-access-token)
kubectl config use-context $SLICE_KUBECTL_CONTEXT

# Call ydb admin config fetch
kubectl -n $JUMP_HOST_NAMESPACE exec -it ydb-jump-host-0 -- env YDB_TOKEN=$YDB_TOKEN ydb -e $CLUSTER_GRPC_ENDPOINT -d $CLUSTER_DATABASE admin config fetch > $1
