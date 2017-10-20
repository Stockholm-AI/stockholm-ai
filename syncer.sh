#!/usr/bin/env bash
set -e

SOURCE=source
: ${STOCKHOLM_AI_BRANCH:=master}

rm -rf ${SOURCE}
git clone \
    --branch ${STOCKHOLM_AI_BRANCH} \
    --single-branch \
    https://github.com/Stockholm-AI/stockholm-ai \
    ${SOURCE}

cd ${SOURCE}

jekyll build
while :
do 
    git fetch \
        && [[ $(git diff ${STOCKHOLM_AI_BRANCH} origin/${STOCKHOLM_AI_BRANCH}) ]] \
        && git pull \
        && jekyll build
    sleep 1
done
