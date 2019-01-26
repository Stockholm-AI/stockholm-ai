#!/usr/bin/env python
from collections import Counter
import socket
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

def bot(ua):
    self_identifying_bot = "bot" in ua or "spider" in ua or "crawler" in ua
    known_browser = ua.startswith("Mozilla") or ua.startswith("Opera")

    return self_identifying_bot or not known_browser

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

    def update(self, message):
        if not bot(message["http_user_agent"]):
            _, path, _ = message["request"].split(" ", 2)
            if countable(path):
                if path not in self.paths:
                    self.paths[path] = DatePath()
                path_data = self.paths[path]

                path_data.n_hits += 1
                path_data.ips.add(message["remote_addr"])
                path_data.uas.add(message["http_user_agent"])
                path_data.referers.update([message["http_referer"], ])

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
    return slack.post(
        "{date}:\n{summary}".format(
            date=date.date,
            summary="\n".join(map(str, date.summary())),
        )
    )

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
    
    main(
        app_hook=app_hook,
    )
