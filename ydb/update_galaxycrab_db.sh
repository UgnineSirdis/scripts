#! /usr/bin/env bash
set -e

cd ~/manifests/kubernetes/clusters/ik8s-ydb-dev/ydb-dev/databases

kubectl config use-context bastion-man-man-ydb-dev

helmfile apply -l name=galaxycrab

kubectl get pods -n ydb-dev | grep -o -E 'galaxycrab-\d+' | xargs kubectl delete pod -n ydb-dev
