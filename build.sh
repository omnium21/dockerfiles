#!/bin/sh

set -e

trap cleanup_exit INT TERM EXIT

cleanup_exit()
{
  rm -f *.list *.key
}

export LANG=C

image=${USER}-ubuntu
docker build --rm --pull --tag=$image .
echo $image > .docker-tag
