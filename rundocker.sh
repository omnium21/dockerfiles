#!/bin/sh

IMAGE=${1:-"${USER}-ubuntu"}

# Mount points to be added to the container
[ -d "/arm"  ] && PARAMS="${PARAMS} -v /arm:/arm"
[ -d "/data" ] && PARAMS="${PARAMS} -v /data:/data"

# PATHs to be added to the container
[ -d "/data/bin" ] && PARAMS="${PARAMS} -e PATH=$PATH:/data/bin"

# Devices to be added to the container
[ -c "/dev/fuse" ] && PARAMS="${PARAMS} --cap-add SYS_ADMIN --device /dev/fuse"

if [ "$(docker image ls -q ${IMAGE})" = "" ] ; then
	echo "Image '${IMAGE}' missing, building it..."
	$(dirname $0)/build.sh ${IMAGE}
fi
docker run ${PARAMS} --user ${USER}:${USER} --hostname docker-ubuntu -t -i ${IMAGE}
