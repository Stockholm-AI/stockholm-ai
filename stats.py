#!/usr/bin/env python
from collections import Counter
from itertools import starmap
import socket

import random

import yaml
import requests

#  log_format machine_readable '{'
#                              'remote_addr: $remote_addr, '
#                              'time: !!timestamp "$time_iso8601", '
#                              'request: "$request", '
#                              'status: $status, '
#                              'http_referer: "$http_referer", '
#                              'http_user_agent: "$http_user_agent", '
#                              '}';

class Slack(object):
    def __init__(self, app_hook):
        self.app_hook = app_hook
    def post(self, text):
        response = requests.post(
            "https://hooks.slack.com/services/{app_hook}".format(app_hook=self.app_hook),
            json={"text": text},
        )

def bot(user_agent, path, referer):
    self_identifying_bot = "bot" in user_agent \
            or "spider" in user_agent \
            or "crawler" in user_agent
    fuzzer = "?author=" in path \
            or "+and+" in path \
            or "+and+" in referer
    known_browser = user_agent.startswith("Mozilla") \
            or user_agent.startswith("Opera")

    return self_identifying_bot or fuzzer or not known_browser

def countable(path):
    return "." not in path

class DatePath(object):
    def __init__(self):
        self.n_hits = 0
        self.ips = set()
        self.uas = set()
        self.referers = Counter()

class Date(object):
    def __init__(self, date):
        self.date = date
        self.paths = {}
        self.noice = str(random.getrandbits(64))

    def update(self, message):
        user_agent = message["http_user_agent"] 
        referer = message["http_referer"]
        remote_address = message["remote_addr"]
        _, path, _ = message["request"].split(" ", 2)

        clean_path = path.split("?", 1)[0]
        clean_referer = referer.split("?", 1)[0]

        if not bot(user_agent, path, referer):
            if countable(path):
                if clean_path not in self.paths:
                    self.paths[clean_path] = DatePath()
                path_data = self.paths[clean_path]

                path_data.n_hits += 1
                path_data.ips.add(hash(self.noice + remote_address))
                path_data.uas.add(hash(self.noice + user_agent))
                path_data.referers.update([clean_referer, ])

    def summary(self):
        return map(
            lambda (path, path_data): {
                "path": path,
                "n_hits": path_data.n_hits,
                "n_unique_ips": len(path_data.ips),
                "n_unique_uas": len(path_data.uas),
                "referers": path_data.referers,
            },
            sorted(
                self.paths.items(),
                key=lambda (_, path_data): path_data.n_hits,
                reverse=True,
            )
        )


def post_summary(slack, date):
    def render_path(path):
        return "  {path} (hits: ~{n_unique_ips} unique, {n_hits} total)\n  Hits coming from:\n{referers}".format(
            path=path.get("path", "{{missing path}}"),
            n_unique_ips=path.get("n_unique_ips", "{{missing n_unique_ips}}"),
            n_hits=path.get("n_hits", "{{missing n_hits}}"),
            referers="".join(list(starmap(
                "    - {0}: {1}\n".format,
                path
                    .get("referers", Counter())
                    .most_common()
            ))),
        )

    message = "{date}:\n==========\n{summary}".format(
        date=date.date,
        summary="".join(map(render_path, date.summary())),
    )

    return slack.post(message)

class Statistics(object):
    def __init__(self, slack):
        self.slack = slack
        self.dates = {}
        self.last_date = None

    def process(self, message):
        date = message["time"].date()

        if date not in self.dates:
            self.dates[date] = Date(date)

        date_data = self.dates[date]
        date_data.update(message)

        if self.last_date is not None and self.last_date != date:
            post_summary(self.slack, self.dates[self.last_date])
            del self.dates[self.last_date]

        self.last_date = date

def next_message(sock):
     data, _ = sock.recvfrom(4096)
     _, raw_message = data[5:].split(": ", 1)
     message = yaml.load(raw_message)

     return message

def main(app_hook):
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.bind(("127.0.0.1", 5140))

    statistics = Statistics(Slack(app_hook))

    while True:
        message = None
        try:
            message = next_message(sock)
            statistics.process(message)
        except:
            print("Error with message={}:\n    {}".format(message, sys.exc_info()[0]))


if __name__ == "__main__":
    import os
    app_hook = os.environ['SLACK_APP_HOOK']

    random.seed()
    
    main(
        app_hook=app_hook,
    )
