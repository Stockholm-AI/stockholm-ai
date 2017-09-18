#!/usr/bin/env bash
set -ex

docker --version

REMOTE=https://github.com/Stockholm-AI/stockholm-ai
BRANCH=master

SOURCE_VOLUME=stockholm-ai-source-$BRANCH

SYNCER_NAME=stockholm-ai-syncer-$BRANCH
SYNCER_IMAGE=indiehosters/git:latest

SERVER_NAME=stockholm-ai-server-$BRANCH
SERVER_IMAGE=jekyll/jekyll:latest

function cleanup {
    docker rm -f $SYNCER_NAME || true
    docker rm -f $SERVER_NAME || true
    docker volume rm $SOURCE_VOLUME || true
} && cleanup && trap cleanup EXIT

docker volume create --name $SOURCE_VOLUME

docker run \
    --detach \
    --volume $SOURCE_VOLUME:/source \
    --name $SYNCER_NAME $SYNCER_IMAGE \
    /bin/sh -c "git clone $REMOTE /source && cd /source && git checkout $BRANCH && while true; do git pull && sleep 1; done"

docker run \
    --publish 80:4000 \
    --interactive \
    --tty \
    --volume $SOURCE_VOLUME:/source \
    --name $SERVER_NAME $SERVER_IMAGE \
    /bin/sh -c "jekyll serve --source /source --destination /srv/jekyll"
