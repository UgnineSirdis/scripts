#! /usr/bin/env bash
set -xe

export ENDPOINT=${1:-grpc://localhost:38810}

export IAM_REGION_ID=e0t  # e0t - testing, e00 - prod
export DBPATH=/local
export database_id=ydb-e0texample-1
export container_id=project-e0tydb-dev

alias ydb=~/ydb/ydb/apps/ydb/ydb
alias ydbd=~/ydb/ydb/apps/ydbd/ydbd

ydb -e ${ENDPOINT} -d ${DBPATH} scheme permissions grant  ${DBPATH} ydb.databases.create-${database_id}@as -p ydb.generic.use
ydb -e ${ENDPOINT} -d ${DBPATH} scheme permissions grant  ${DBPATH} ydb.tables.select-${database_id}@as -p ydb.generic.read
ydb -e ${ENDPOINT} -d ${DBPATH} scheme permissions grant  ${DBPATH} ydb.tables.select-${database_id}@as -p ydb.granular.write_attributes
ydb -e ${ENDPOINT} -d ${DBPATH} scheme permissions grant  ${DBPATH} ydb.databases.connect-${database_id}@as -p ydb.database.connect
ydb -e ${ENDPOINT} -d ${DBPATH} scheme permissions grant  ${DBPATH} ydb.streams.write-${database_id}@as -p ydb.generic.write
ydb -e ${ENDPOINT} -d ${DBPATH} scheme permissions grant  ${DBPATH} ydb.streams.write-${database_id}@as -p ydb.granular.describe_schema
ydb -e ${ENDPOINT} -d ${DBPATH} scheme permissions grant  ${DBPATH} ydb.schemas.getMetadata-${database_id}@as -p ydb.generic.list

ydb -e ${ENDPOINT} -d ${DBPATH} scheme describe --permissions ${DBPATH}

ydbd -s ${ENDPOINT} db schema user-attribute set ${DBPATH} folder_id=${container_id}
ydbd -s ${ENDPOINT} db schema user-attribute set ${DBPATH} database_id=${database_id}

ydbd -s ${ENDPOINT} db schema user-attribute get ${DBPATH}
