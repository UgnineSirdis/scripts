#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 || -z "$1" ]]; then
    echo "Usage: $0 FEATURE_NAME" >&2
    echo "Example: $0 EnableNodeBrokerDeltaProtocol" >&2
    echo >&2
    echo "Description:" >&2
    echo "  Gets the cluster list from https://ydb.nebius.dev/api/meta/meta/clusters." >&2
    echo "  Checks the effective configuration of each cluster for FEATURE_NAME." >&2
    echo >&2
    echo "Warning: FEATURE_NAME must use protobuf naming style." >&2
    echo "Option names: https://github.com/ydb-platform/ydb/blob/main/ydb/core/protos/config.proto" >&2
    exit 2
fi

feature_name=$1

YDB_TOKEN_PROD=$(npc --profile prod iam get-access-token)
YDB_TOKEN_TEST=$(npc --profile testing iam get-access-token)

CLUSTERS_URL='https://ydb.nebius.dev/api/meta/meta/clusters'
MAX_INFLIGHT=10
CURL_RETRIES=2
CURL_CONNECT_TIMEOUT=5
CURL_MAX_TIME=30

get_clusters() {
    local response

    response=$(
        curl --fail --silent --show-error \
            --connect-timeout "$CURL_CONNECT_TIMEOUT" \
            --max-time "$CURL_MAX_TIME" \
            --retry "$CURL_RETRIES" \
            --retry-delay 1 \
            --retry-all-errors \
            "$CLUSTERS_URL"
    )

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

    jq -r '
        .clusters[]
        | select(.status != "development" and .status != "dev")
        | [.name, .title, .balancer, .status]
        | @tsv
    ' <<<"$response"
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

check_cluster() {
    local cluster_balancer=$1
    local cluster_status=$2
    local cluster_token
    local cluster_url
    local settings_url
    local settings_page
    local effective_config
    local feature_value

    if [[ "$cluster_status" == 'production' ]]; then
        cluster_token=$YDB_TOKEN_PROD
    else
        cluster_token=$YDB_TOKEN_TEST
    fi

    cluster_url=${cluster_balancer%/viewer/json}
    settings_url="$cluster_url/actors/configs_dispatcher"

    if ! settings_page=$(
        curl --fail --silent \
            --connect-timeout "$CURL_CONNECT_TIMEOUT" \
            --max-time "$CURL_MAX_TIME" \
            --retry "$CURL_RETRIES" \
            --retry-delay 1 \
            --retry-all-errors \
            -H "Authorization: Bearer $cluster_token" \
            "$settings_url"
    ); then
        printf 'ERROR\n'
        return
    fi

    if ! effective_config=$(get_effective_config <<<"$settings_page"); then
        printf 'ERROR\n'
        return
    fi

    feature_value=$(grep -F -w -m 1 -- "$feature_name" <<<"$effective_config" || true)
    if [[ -z "$feature_value" ]]; then
        feature_value='NOT SET'
    else
        feature_value=$(sed 's/^[[:space:]]*//; s/[[:space:]]*$//' <<<"$feature_value")
    fi

    printf '%s\n' "$feature_value"
}

cluster_records=$(get_clusters)
results_dir=$(mktemp -d /tmp/check-feature.XXXXXX)

cleanup() {
    if [[ -n "${results_dir:-}" && "$results_dir" == /tmp/check-feature.* ]]; then
        rm -rf -- "$results_dir"
    fi
}
trap cleanup EXIT

result_index=0
while IFS=$'\t' read -r cluster_name cluster_title cluster_balancer cluster_status; do
    while [[ $(jobs -pr | wc -l | tr -d ' ') -ge $MAX_INFLIGHT ]]; do
        sleep 0.1
    done

    check_cluster "$cluster_balancer" "$cluster_status" \
        >"$results_dir/$result_index" &
    result_index=$((result_index + 1))
done <<<"$cluster_records"

wait

printf '%-40s %-60s %s\n' 'CLUSTER NAME' 'CLUSTER TITLE' 'FEATURE VALUE'
while IFS=$'\t' read -r sort_group cluster_name cluster_title feature_value; do
    print_result "$cluster_name" "$cluster_title" "$feature_value"
done < <(
    result_index=0
    while IFS=$'\t' read -r cluster_name cluster_title cluster_balancer cluster_status; do
        if [[ -s "$results_dir/$result_index" ]]; then
            feature_value=$(<"$results_dir/$result_index")
        else
            feature_value='ERROR'
        fi

        if [[ "$cluster_status" == 'production' ]]; then
            sort_group=1
        else
            sort_group=0
        fi

        printf '%s\t%s\t%s\t%s\n' \
            "$sort_group" "$cluster_name" "$cluster_title" "$feature_value"
        result_index=$((result_index + 1))
    done <<<"$cluster_records" \
        | LC_ALL=C sort -t $'\t' -k1,1n -k2,2
)
