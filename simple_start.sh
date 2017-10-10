#!/usr/bin/env sh
set -e

while :
do git fetch \
    && [[ -n "$(git diff master origin/master)" ]] \
    && git pull \
    && jekyll build
sleep 1
done
