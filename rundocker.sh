#!/bin/sh

RELEASE=${RELEASE:-"focal"}
IMAGE=${IMAGE:-"${USER}-ubuntu-${RELEASE}"}

export LANG=C

usage()
{
	echo "usage: $0 [-o] [-i image-name]"
	echo "       -o    overwrite existing image"
	echo "       -i    image name (default: ${USER}-ubuntu-focal)"
	echo "       -r    Ubuntu release name (default: focal)"
	exit 1
}

while getopts "oi:r:" opt; do
  case "$opt" in
    o) OVERWRITE=true ;;
    i) IMAGE=${OPTARG} ;;
    r) RELEASE=${OPTARG} ;;
    h|*) usage ;;
  esac
done


# Mount points to be added to the container
[ -d "/data" ] && PARAMS="${PARAMS} -v /data:/data"

# PATHs to be added to the container
[ -d "/data/bin" ] && PARAMS="${PARAMS} -e PATH=$PATH:/data/bin"

# Devices to be added to the container
[ -c "/dev/fuse" ] && PARAMS="${PARAMS} --cap-add SYS_ADMIN --device /dev/fuse"

if [ "${OVERWRITE}" = "true" ] || [ "$(docker image ls -q ${IMAGE})" = "" ] ; then
	echo "Building image '${IMAGE}' ..."
	$(dirname $0)/build.sh -i ${IMAGE} -r ${RELEASE} -o
fi
docker run ${PARAMS} --env="DISPLAY" --env="QT_X11_NO_MITSHM=1" --network host --user ${USER}:${USER} -t -i ${IMAGE}
