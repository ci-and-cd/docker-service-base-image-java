#!/usr/bin/env bash

set -e

docker version
docker-compose version

WORK_DIR=$(pwd)

cd ${OS_DIST:-centos}
./build.sh
