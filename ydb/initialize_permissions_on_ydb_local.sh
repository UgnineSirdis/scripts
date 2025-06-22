#! /usr/bin/env bash
set -xe

export IAM_REGION_ID=e0t  # e0t - testing, e00 - prod
export DBNAME=local
export DBPATH=/local
export database_id=ydb-e0texample-1
export container_id=project-e0tydb-dev

~/ydb/ydb/apps/ydb/ydb -e grpc://localhost:17690 -d ${DBPATH} scheme permissions grant  ${DBPATH} ydb.databases.create-${database_id}@as -p ydb.generic.use
~/ydb/ydb/apps/ydb/ydb -e grpc://localhost:17690 -d ${DBPATH} scheme permissions grant  ${DBPATH} ydb.tables.select-${database_id}@as -p ydb.generic.read
~/ydb/ydb/apps/ydb/ydb -e grpc://localhost:17690 -d ${DBPATH} scheme permissions grant  ${DBPATH} ydb.tables.select-${database_id}@as -p ydb.granular.write_attributes
~/ydb/ydb/apps/ydb/ydb -e grpc://localhost:17690 -d ${DBPATH} scheme permissions grant  ${DBPATH} ydb.databases.connect-${database_id}@as -p ydb.database.connect
~/ydb/ydb/apps/ydb/ydb -e grpc://localhost:17690 -d ${DBPATH} scheme permissions grant  ${DBPATH} ydb.streams.write-${database_id}@as -p ydb.generic.write
~/ydb/ydb/apps/ydb/ydb -e grpc://localhost:17690 -d ${DBPATH} scheme permissions grant  ${DBPATH} ydb.streams.write-${database_id}@as -p ydb.granular.describe_schema
~/ydb/ydb/apps/ydb/ydb -e grpc://localhost:17690 -d ${DBPATH} scheme permissions grant  ${DBPATH} ydb.schemas.getMetadata-${database_id}@as -p ydb.generic.list

~/ydb/ydb/apps/ydb/ydb -e grpc://localhost:17690 -d ${DBPATH} scheme describe --permissions ${DBPATH}

~/ydb/ydb/apps/ydbd/ydbd -s grpc://localhost:17690 db schema user-attribute set ${DBPATH} folder_id=${container_id}
~/ydb/ydb/apps/ydbd/ydbd -s grpc://localhost:17690 db schema user-attribute set ${DBPATH} database_id=${database_id}

~/ydb/ydb/apps/ydbd/ydbd -s grpc://localhost:17690 db schema user-attribute get ${DBPATH}
