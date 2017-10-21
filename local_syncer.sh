#!/usr/bin/env bash
set -e

SOURCE=source
cd source

while :
do 
    jekyll build
    kill -s HUP $(cat /tmp/nginx.pid)
    sleep 1
done
