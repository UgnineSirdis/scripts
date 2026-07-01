#! /usr/bin/env bash
set -e

IMAGE_NAME=$1

if [ -z "$IMAGE_NAME" ]; then
    echo "Usage: $0 <image_name>"
    exit 1
fi

IMAGE_URL=artifactory.nebius.dev/common-cr/ydb/ydb:${IMAGE_NAME}
YDB_REPO_PATH=~/ydb

BUILD_DIR=~/ydb-docker-build

rm -rf ${BUILD_DIR}
mkdir -p ${BUILD_DIR}

cd ${YDB_REPO_PATH}

./ya make --build relwithdebinfo ydb/apps/ydbd
echo "ydbd is built"

# rename link to real file,
# because docker does not understand symliks
YDBD_BINARY_BUILD_PATH=$(readlink ydb/apps/ydbd/ydbd)

mkdir -p ${BUILD_DIR}/ydb/apps/ydbd
ln ${YDBD_BINARY_BUILD_PATH} ${BUILD_DIR}/ydb/apps/ydbd/

cd ${BUILD_DIR}

echo "Build base image"
docker build -f ~/manifests/docker/ydbd/dev-build.Dockerfile -t ${IMAGE_URL} .

echo "Build breakpad image"
docker build --build-arg BASE_IMAGE=${IMAGE_URL} -f ~/manifests/docker/ydbd/ydb-server-breakpad.dockerfile -t ${IMAGE_URL}-breakpad .

echo "Push resulting image"
# push resulting image
docker push ${IMAGE_URL}-breakpad

echo "Full image url with breakpad:"
echo ${IMAGE_URL}-breakpad

rm -r ${BUILD_DIR}
