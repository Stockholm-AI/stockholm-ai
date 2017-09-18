#!/usr/bin/env bash
set -ex

docker --version

REMOTE=https://github.com/Stockholm-AI/stockholm-ai
BRANCH=master
VOLUME_NAME=stockholm-ai-volume-$BRANCH

SYNCER_NAME=stockholm-ai-syncer-$BRANCH
SYNCER_IMAGE=indiehosters/git:latest

SERVER_NAME=stockholm-ai-server-$BRANCH
SERVER_IMAGE=jekyll/jekyll:3.4

function cleanup {
    docker rm -f $SYNCER_NAME || true
    docker rm -f $SERVER_NAME || true
    docker volume rm $VOLUME_NAME || true
} && trap cleanup EXIT

docker volume create --name $VOLUME_NAME

(docker run --detach --volume $VOLUME_NAME:/volume --name $SYNCER_NAME $SYNCER_IMAGE /bin/sh -c "git clone $REMOTE /volume && while true; do git pull && sleep 1; done" || kill 0)&

docker run --publish 80:4000 --interactive --tty --volume $VOLUME_NAME:/volume --name $SERVER_NAME $SERVER_IMAGE /bin/sh -c "jekyll serve --destination /tmp/site --source /volume"
