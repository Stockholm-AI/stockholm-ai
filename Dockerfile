FROM ubuntu:16.04

WORKDIR /workspace

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get --assume-yes install \
        build-essential \
        git \
        libffi-dev \
        nginx \
        ruby \
        ruby-dev \
        supervisor \
        && \
    rm -rf /var/lib/apt/lists/*

RUN gem install jekyll --version '3.7.2'

COPY supervisord.conf /etc/supervisor.conf
COPY server /workspace/server
COPY syncer.sh /workspace/syncer.sh

CMD [ "/usr/bin/env", "supervisord", "-c", "/etc/supervisor.conf" ]
