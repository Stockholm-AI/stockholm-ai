#!/usr/bin/env bash
set -ex

docker --version

REMOTE=https://github.com/Stockholm-AI/stockholm-ai
BRANCH=master

SOURCE_VOLUME=stockholm-ai-source-$BRANCH
DESTINATION_VOLUME=stockholm-ai-destination-$BRANCH

SYNCER_NAME=stockholm-ai-syncer-$BRANCH
SYNCER_IMAGE=indiehosters/git:latest

SERVER_NAME=stockholm-ai-server-$BRANCH
SERVER_IMAGE=jekyll/jekyll:builder


function cleanup {
    docker rm -f $SYNCER_NAME || true
    docker rm -f $SERVER_NAME || true
    docker volume rm $SOURCE_VOLUME || true
} && cleanup && trap cleanup EXIT

docker volume create --name $SOURCE_VOLUME


docker run \
    --detach \
    --restart unless-stopped \
    --volume $SOURCE_VOLUME:/source \
    --name $SYNCER_NAME $SYNCER_IMAGE \
    /bin/sh -c "git clone $REMOTE /source && cd /source && git checkout $BRANCH && while true; do git pull && sleep 1; done"

docker run \
    --detach \
    --restart unless-stopped \
    --publish 80:4000 \
    --volume $SOURCE_VOLUME:/source \
    --name $SERVER_NAME \
    --user root \
    $SERVER_IMAGE \
    /bin/sh -c "[[ -f /source/_config.yml ]] && jekyll serve --source /source --config /source/_config.yml --destination /destination"


sleep infinity
