#! /usr/bin/env bash
set -e

IMAGE_NAME=$1

if [ -z "$IMAGE_NAME" ]; then
    echo "Usage: $0 <image_name>"
    exit 1
fi

IMAGE_URL=artifactory.nebius.dev/common-cr/ydb/ydb:${IMAGE_NAME}

cd ~/ydb

rm -f ydb/apps/ydbd/ydbd
rm -f ydb/apps/ydbd/ydbd_link

./ya make --build relwithdebinfo ydb/apps/ydbd

# rename link to real file,
# because docker does not understand symliks
YDBD_BINARY_BUILD_PATH=$(readlink ydb/apps/ydbd/ydbd)

# rename existing link
mv ydb/apps/ydbd/ydbd ydb/apps/ydbd/ydbd_link

# make hard link to real binary to ydb/apps/ydbd
ln ${YDBD_BINARY_BUILD_PATH} ydb/apps/ydbd/ydbd

# build base image
docker build -f ~/dev-build.Dockerfile -t ${IMAGE_URL} .

# build breakpad image
docker build --build-arg BASE_IMAGE=${IMAGE_URL} -f ~/ydb-server-breakpad.dockerfile -t ${IMAGE_URL}-breakpad .

# push resulting image
docker push ${IMAGE_URL}-breakpad

echo "Full image url with breakpad:"
echo ${IMAGE_URL}-breakpad

# revert links
rm ydb/apps/ydbd/ydbd
mv ydb/apps/ydbd/ydbd_link ydb/apps/ydbd/ydbd
