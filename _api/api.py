import requests
from flask import Flask

api = Flask("api")


@api.route("/mailing_list")
def mailing_list():
    return "mailing_list"


