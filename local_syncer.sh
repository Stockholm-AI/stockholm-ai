#!/usr/bin/env bash
set -e

SOURCE=source
cd source

while :
do 
    jekyll build
    sleep 1
done
