#!/bin/sh

IMAGE=${1:-"${USER}-ubuntu"}

# Mount points to be added to the container
[ -d "/arm"  ] && PARAMS="${PARAMS} -v /arm:/arm"
[ -d "/data" ] && PARAMS="${PARAMS} -v /data:/data"

# Devices to be added to the container
[ -c "/dev/fuse" ] && PARAMS="${PARAMS} --cap-add SYS_ADMIN --device /dev/fuse"

docker run ${PARAMS} --user ${USER}:${USER} --hostname docker-ubuntu -t -i ${IMAGE}
