#! /usr/bin/env bash
set -e

IMAGE_NAME=$1

if [ -z "$IMAGE_NAME" ]; then
    echo "Usage: $0 <image_name>"
    exit 1
fi

IMAGE_URL=artifactory.nebius.dev/common-cr/ydb/ydb-jump-host:${IMAGE_NAME}

# ~/docker_builds/ydb-jump-host.dockerfile

rm -rf ~/ydb-jump-host-build
mkdir -p ~/ydb-jump-host-build/docker/ydb-jump-host

cd ~/ydb

./ya make --build relwithdebinfo ydb/apps/ydbd ydb/apps/ydb ydb/apps/dstool

# rename link to real file,
# because docker does not understand symliks
YDBD_BINARY_BUILD_PATH=$(readlink ydb/apps/ydbd/ydbd)
YDB_BINARY_BUILD_PATH=$(readlink ydb/apps/ydb/ydb)
DSTOOL_BINARY_BUILD_PATH=$(readlink ydb/apps/dstool/ydb-dstool)

ln ${YDBD_BINARY_BUILD_PATH} ~/ydb-jump-host-build/
ln ${YDB_BINARY_BUILD_PATH} ~/ydb-jump-host-build/
ln ${DSTOOL_BINARY_BUILD_PATH} ~/ydb-jump-host-build/
cp ~/docker_builds/get-iam-token.sh ~/ydb-jump-host-build/docker/ydb-jump-host/

cd ~/ydb-jump-host-build

# build base image
docker build -f ~/docker_builds/ydb-jump-host.dockerfile -t ${IMAGE_URL} .

# push resulting image
docker push ${IMAGE_URL}

echo "Full image url:"
echo ${IMAGE_URL}

rm -r ~/ydb-jump-host-build
