#! /usr/bin/env bash
set -e

IMAGE_NAME=$1

if [ -z "$IMAGE_NAME" ]; then
    echo "Usage: $0 <image_name>"
    exit 1
fi

BASE_IMAGE=artifactory.nebius.dev/common-cr/ydb/base:20250416-151221
YDB_REPO_PATH=~/ydb

BUILD_DIR=~/local-ydb-build

rm -rf ${BUILD_DIR}
mkdir -p ${BUILD_DIR}

cd ${YDB_REPO_PATH}

./ya make --build relwithdebinfo ydb/apps/ydbd ydb/apps/ydb ydb/public/tools/local_ydb

# rename link to real file,
# because docker does not understand symliks
YDBD_BINARY_BUILD_PATH=$(readlink ydb/apps/ydbd/ydbd)
YDB_BINARY_BUILD_PATH=$(readlink ydb/apps/ydb/ydb)
LOCAL_YDB_BINARY_BUILD_PATH=$(readlink ydb/public/tools/local_ydb/local_ydb)

ln ${YDBD_BINARY_BUILD_PATH} ${BUILD_DIR}/
ln ${YDB_BINARY_BUILD_PATH} ${BUILD_DIR}/
ln ${LOCAL_YDB_BINARY_BUILD_PATH} ${BUILD_DIR}/
mkdir ${BUILD_DIR}/src
cp -r ${YDB_REPO_PATH}/.github ${BUILD_DIR}/src/

cd ${BUILD_DIR}

# build image without symbols
docker build -f ~/manifests/docker/local-ydb/local-ydb.dockerfile --build-arg BASE_IMAGE=${BASE_IMAGE} -t ${IMAGE_NAME} .

# build the same image with symbols
docker build -f ~/manifests/docker/local-ydb/local-ydb.dockerfile --build-arg BASE_IMAGE=${BASE_IMAGE} --build-arg DEBUG_SYMBOLS=1 -t ${IMAGE_NAME}-full .

rm -r ${BUILD_DIR}
