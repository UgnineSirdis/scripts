#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 || -z "$1" ]]; then
    echo "Usage: $0 FEATURE_NAME" >&2
    echo "Example: $0 EnableNodeBrokerDeltaProtocol" >&2
    exit 2
fi

feature_name=$1

YDB_TOKEN_PROD=$(npc --profile prod iam get-access-token)
YDB_TOKEN_TEST=$(npc --profile testing iam get-access-token)

CLUSTERS_URL='https://ydb.nebius.dev/api/meta/meta/clusters'

get_clusters() {
    local response

    response=$(curl --fail --silent --show-error "$CLUSTERS_URL")

    if ! jq -e '
        .clusters
        | type == "array"
          and length > 0
          and all(.[].name; type == "string" and length > 0)
          and all(.[].title; type == "string" and length > 0)
          and all(.[].balancer; type == "string" and length > 0)
          and all(.[].status; type == "string" and length > 0)
    ' >/dev/null <<<"$response"; then
        echo "Unexpected response from $CLUSTERS_URL" >&2
        return 1
    fi

    jq -r '.clusters[] | [.name, .title, .balancer, .status] | @tsv' <<<"$response"
}

get_effective_config() {
    awk '
        index($0, "div id=\047effective-config\047") {
            in_effective_config = 1
            found_start = 1
            next
        }
        index($0, "div id=\047effective-startup-config\047") {
            found_end = 1
            exit
        }
        in_effective_config {
            print
        }
        END {
            if (!found_start || !found_end) {
                exit 1
            }
        }
    '
}

print_result() {
    local cluster_name=$1
    local cluster_title=${2:0:60}
    local feature_value=$3

    printf '%-40s %-60s ' "$cluster_name" "$cluster_title"

    if [[ -t 1 ]]; then
        case "$feature_value" in
            'ERROR')
                printf '\033[1;91m%s\033[0m\n' "$feature_value"
                ;;
            'NOT SET')
                printf '%s\n' "$feature_value"
                ;;
            *)
                printf '\033[1;32m%s\033[0m\n' "$feature_value"
                ;;
        esac
    else
        printf '%s\n' "$feature_value"
    fi
}

cluster_records=$(get_clusters)

printf '%-40s %-60s %s\n' 'CLUSTER NAME' 'CLUSTER TITLE' 'FEATURE VALUE'
while IFS=$'\t' read -r cluster_name cluster_title cluster_balancer cluster_status; do
    if [[ "$cluster_status" == 'production' ]]; then
        cluster_token=$YDB_TOKEN_PROD
    else
        cluster_token=$YDB_TOKEN_TEST
    fi

    cluster_url=${cluster_balancer%/viewer/json}
    settings_url="$cluster_url/actors/configs_dispatcher"

    if ! settings_page=$(
        curl --fail --silent \
            -H "Authorization: Bearer $cluster_token" \
            "$settings_url"
    ); then
        print_result "$cluster_name" "$cluster_title" 'ERROR'
        continue
    fi

    if ! effective_config=$(get_effective_config <<<"$settings_page"); then
        print_result "$cluster_name" "$cluster_title" 'ERROR'
        continue
    fi

    feature_value=$(grep -F -m 1 -- "$feature_name" <<<"$effective_config" || true)
    if [[ -z "$feature_value" ]]; then
        feature_value='NOT SET'
    else
        feature_value=$(sed 's/^[[:space:]]*//; s/[[:space:]]*$//' <<<"$feature_value")
    fi

    print_result "$cluster_name" "$cluster_title" "$feature_value"
done <<<"$cluster_records"
