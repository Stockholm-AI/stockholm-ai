#!/usr/bin/env bash
set -ex

# # Install docker and tmux
# sudo yum update -y
# sudo yum install docker tmux -y
# sudo service docker start
# sudo usermod -a -G docker ec2-user

docker build -t stockholm-ai .
docker run \
    --interactive \
    --tty \
    --publish 80:8080 \
    stockholm-ai
