#!/bin/bash

readonly REGION="$1"

if [[ -z $REGION ]]; then
    echo "Usage: $0 <region>" >&2
    exit 1
fi

token() {
      local PROFILE="$1"
      local BID="$2"
      local SID="$3"
      NEBIUS_IAM_TOKEN="$(npc --profile ${PROFILE} --impersonate-service-account-id ${BID} iam get-access-token)" \
      npc --profile ${PROFILE} iam get-access-token --impersonate-service-account-id ${SID}
}

testing_token() {
      local SID="$1"
      echo "Please use federation federation-e0tsystem-nebius-azure" >&2
      token newbius serviceaccount-e0tydb ${SID}
}

prod_token() {
      local BID="$1"
      local SID="$2"
      echo "Please use federation federation-e00system-nebius-azure" >&2
      token newbius-prod ${BID} ${SID}
}

case "$REGION" in
    testing)
      testing_token serviceaccount-e0tydb-kubernetes-operator;;
    dev)
      testing_token serviceaccount-e0tv2pwt7nw675626d;;
    man)
      prod_token serviceaccount-e00ydb serviceaccount-e00ydb-kubernetes-operator;;
    pa10)
      prod_token serviceaccount-e01ydb serviceaccount-e01ydb-kubernetes-operator;;
    kef)
      prod_token serviceaccount-e02ydb serviceaccount-e02ydb-kubernetes-operator;;
    kcs)
      prod_token serviceaccount-u00ydb serviceaccount-u00ydb-kubernetes-operator;;
    *)
      echo "Unknown region: $REGION" >&2
      exit 1;;
esac
