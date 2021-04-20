#!/bin/sh

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
	exit 1
}

while getopts "oi:" opt; do
  case "$opt" in
    o) OVERWRITE=true ;;
    i) IMAGE=${OPTARG} ;;
    h|*) usage ;;
  esac
done

IMAGE=${IMAGE:-"${USER}-ubuntu"}

if [ "${OVERWRITE}" = "true" ]; then
	echo "Removing existing docker image ${IMAGE}"
	docker rmi -f ${IMAGE} || true
fi

docker build --rm --pull --tag=${IMAGE} --build-arg USER=${USER} --build-arg UID=$(id -u) --build-arg GID=$(id -g) .
echo ${IMAGE} > .docker-tag
