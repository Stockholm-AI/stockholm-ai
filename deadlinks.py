from operator import itemgetter
from itertools import chain

import os

import yaml
import requests

yaml.load_all

directory = "_companies"

flat = chain.from_iterable

def link_status_company(filename):
    (name, _) = filename.rsplit(".", 1);
    print("==== {name} ====".format(name=name))
    docs = filter(None, yaml.load_all(open(os.path.join(directory, filename))))
    positions = flat(map(itemgetter("positions"), filter(lambda doc: "positions" in doc, docs)))

    def link_status_position(position):
        title = position["title"]
        url = position["url"]

        print("{title} [ {url} ]".format(title=title, url=url))
        try:
            response = requests.get(url, timeout=10)

            status_code_description = requests.status_codes._codes.get(response.status_code, '-')

            print("{} {} {}".format(response.status_code, status_code_description, response.history))
        except Exception as e:
            print(e)

        print()

    list(map(link_status_position, positions))

list(map(link_status_company, sorted(os.listdir(directory))))
