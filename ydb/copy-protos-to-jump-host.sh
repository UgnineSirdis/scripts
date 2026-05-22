#! /usr/bin/env bash
set -e

# $1 namespace
# $2 pod name
NAMESPACE=${1:-ydb-dev}
POD=${2:-ydb-jump-host-0}

copy_folder() {
    local path="$1"
    if [ -z "$path" ]; then
        echo "Usage: copy_folder <path>"
        return 1
    fi

    cd ~/ydb

    local parent_dir
    parent_dir="$(dirname "$path")/"

    kubectl -n "$NAMESPACE" exec -it "$POD" -- mkdir -p "/tmp/ydb_api_files/${parent_dir}"
    kubectl cp "${path}/" "$NAMESPACE/$POD:/tmp/ydb_api_files/${parent_dir}"
}

copy_folder ydb/public/api
copy_folder ydb/core/protos
copy_folder ydb/core/config/protos
copy_folder ydb/core/nbs/cloud/blockstore/tools/testing/loadtest/lib/protos
copy_folder ydb/core/fq/libs/config/protos
copy_folder ydb/core/nbs/cloud/blockstore/config/protos
copy_folder ydb/core/protos/nbs
copy_folder ydb/core/protos/schemeshard
copy_folder ydb/core/scheme/protos
copy_folder ydb/core/tx/columnshard/common/protos
copy_folder ydb/core/tx/columnshard/engines/protos
copy_folder ydb/core/tx/columnshard/engines/scheme/defaults/protos
copy_folder ydb/library/actors/protos
copy_folder ydb/library/formats/arrow/protos
copy_folder ydb/library/login/protos
copy_folder ydb/library/mkql_proto/protos
copy_folder ydb/library/services
copy_folder ydb/library/ydb_issue/proto
copy_folder ydb/library/yql/dq/actors/protos
copy_folder ydb/library/yql/dq/proto
copy_folder ydb/public/api/protos
copy_folder ydb/public/api/protos/annotations
copy_folder yql/essentials/core/file_storage/proto
copy_folder yql/essentials/public/issue/protos
copy_folder yql/essentials/providers/common/proto
copy_folder yql/essentials/public/issue/protos
copy_folder yql/essentials/public/types
