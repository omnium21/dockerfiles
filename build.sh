#!/bin/sh

RELEASE=${RELEASE:-"focal"}
IMAGE=${IMAGE:-"${USER}-ubuntu-${RELEASE}"}

set -e

trap cleanup_exit INT TERM EXIT

cleanup_exit()
{
  rm -f *.list *.key
}

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


if [ "${OVERWRITE}" = "true" ]; then
	echo "Removing existing docker image ${IMAGE}"
	docker rmi -f ${IMAGE} || true
fi

docker build --rm --pull -f Dockerfile.${RELEASE} --tag=${IMAGE} --build-arg USER=${USER} --build-arg UID=$(id -u) --build-arg GID=$(id -g) .
echo ${IMAGE} > .docker-tag
