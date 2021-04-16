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
	echo "usage: $0 [-o]"
	echo "       -o    overwrite existing image"
	exit 1
}

while getopts ":o" o; do
  case "$o" in
    o) OVERWRITE=true ;;
    h|*) usage ;;
  esac
done

image=${USER}-ubuntu

if [ "${OVERWRITE}" = "true" ]; then
	echo "Removing existing docker image ${image}"
	docker rmi -f ${image} || true
fi

docker build --rm --pull --tag=$image --build-arg USER=${USER} --build-arg UID=$(id -u) --build-arg GID=$(id -g) .
echo $image > .docker-tag
