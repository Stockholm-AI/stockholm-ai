FROM ubuntu:16.04

WORKDIR /workspace

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get --assume-yes install \
        supervisor \
        build-essential \
        git \
        nginx \
        ruby \
        ruby-dev \
        && \
    rm -rf /var/lib/apt/lists/*

RUN gem install jekyll

COPY supervisord.conf /etc/supervisor.conf
COPY server /workspace/server
COPY syncer.sh /workspace/syncer.sh

CMD [ "/usr/bin/env", "supervisord", "-c", "/etc/supervisor.conf" ]
