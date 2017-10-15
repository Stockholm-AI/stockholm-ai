#!/usr/bin/env bash
set -e


# sudo yum update -y
# sudo yum install docker tmux -y
# sudo service docker start
# sudo usermod -a -G docker ec2-user
# docker run --interactive --tty --publish 80:8080 --volume `pwd`:/stockholm-ai ubuntu:16.04 bash
# apt-get update && apt-get install build-essential git nginx ruby ruby-dev && gem install jekyll

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
