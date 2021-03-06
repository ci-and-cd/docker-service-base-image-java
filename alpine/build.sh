#!/usr/bin/env bash

set -e

docker version
docker-compose version

WORK_DIR=$(pwd)

if [[ -n "${CI_OPT_DOCKER_REGISTRY_PASS}" ]] && [[ -n "${CI_OPT_DOCKER_REGISTRY_USER}" ]]; then echo ${CI_OPT_DOCKER_REGISTRY_PASS} | docker login --password-stdin -u="${CI_OPT_DOCKER_REGISTRY_USER}" docker.io; fi

export IMAGE_PREFIX=${IMAGE_PREFIX:-cirepo/};
export IMAGE_NAME=${IMAGE_NAME:-service-base-image-java}
export IMAGE_TAG=${IMAGE_ARG_JAVA_VENDOR:-openjdk}-${IMAGE_ARG_JAVA_VERSION:-11.0.2}-${IMAGE_ARG_LOCALE:-en_US}.${IMAGE_ARG_ENCODING:-UTF-8}_${IMAGE_ARG_TZ_AREA:-Etc}.${IMAGE_ARG_TZ_ZONE:-UTC}-alpine
if [[ "${TRAVIS_BRANCH}" != "master" ]]; then export IMAGE_TAG=${IMAGE_TAG}-SNAPSHOT; fi

sed "s#%IMAGE_ARG_ENCODING%#${IMAGE_ARG_ENCODING:-UTF-8}#g" Dockerfile_template | \
  sed "s#%IMAGE_ARG_GLIBC_VERSION%#${IMAGE_ARG_GLIBC_VERSION:-2.29-r0}#g" | \
  sed "s#%IMAGE_ARG_JAVA_VENDOR%#${IMAGE_ARG_JAVA_VENDOR:-openjdk}#g" | \
  sed "s#%IMAGE_ARG_JAVA_VERSION%#${IMAGE_ARG_JAVA_VERSION:-11.0.2}#g" | \
  sed "s#%IMAGE_ARG_LOCALE%#${IMAGE_ARG_LOCALE:-en_US}#g" | \
  sed "s#%IMAGE_ARG_TZ_AREA%#${IMAGE_ARG_TZ_AREA:-Etc}#g" | \
  sed "s#%IMAGE_ARG_TZ_ZONE%#${IMAGE_ARG_TZ_ZONE:-UTC}#g" > Dockerfile

# Build image
if [[ "$(docker images -q ${IMAGE_PREFIX}${IMAGE_NAME}:${IMAGE_TAG} 2> /dev/null)" == "" ]]; then
    docker-compose build image
fi

docker-compose push
