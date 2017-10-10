#!/usr/bin/env bash
set -e

# requirements:
# - git
# - nginx
# - gem
# - jekyll # (from gem)


echo "Starting nginx .. "
nginx -p `pwd` -c static_server/nginx.conf
echo "nginx started"

function stop_nginx {
    echo "Stopping nginx .. "
    kill "$(cat /tmp/nginx.pid)"
    echo "nginx Stopped"
} && trap stop_nginx EXIT

echo "Start initial build"
jekyll build

echo "Starting tracking master"
while :
do 
    git fetch \
        && [[ $(git diff master origin/master) ]] \
        && git pull \
        && jekyll build
    sleep 1
done
