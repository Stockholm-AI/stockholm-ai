#!/usr/bin/env bash
set -e

git clone https://github.com/Stockholm-AI/stockholm-ai source
cd source

jekyll build
while :
do 
    git fetch \
        && [[ $(git diff master origin/master) ]] \
        && git pull \
        && jekyll build
    sleep 1
done
