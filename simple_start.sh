#!/usr/bin/env bash
set -e

printf "Starting nginx .. "
nginx -p `pwd` -c static_server/nginx.conf
printf "Done\n"

function stop_nginx {
    printf "Stopping nginx .. "
    kill "$(cat /tmp/nginx.pid)"
    printf "Done\n"
} && trap stop_nginx EXIT

while :
do git fetch \
    && [[ $(git diff master origin/master) ]] \
    && git pull \
    && jekyll build
sleep 1
done
