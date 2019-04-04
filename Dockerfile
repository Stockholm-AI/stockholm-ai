FROM ubuntu:18.04

WORKDIR /workspace

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get --assume-yes install \
        build-essential \
        git \
        libffi-dev \
        nginx \
        python \
        python-requests \
        python-yaml \
        ruby \
        ruby-dev \
        supervisor \
        && \
    rm -rf /var/lib/apt/lists/*

RUN gem install jekyll --version '3.8.5'

COPY supervisord.conf /etc/supervisor.conf
COPY server /workspace/server
COPY syncer.sh /workspace/syncer.sh
COPY stats.py /workspace/stats.py

CMD [ "/usr/bin/env", "supervisord", "-c", "/etc/supervisor.conf" ]
