import json
from datetime import datetime
from uuid import uuid4
from aeon import app as aeon_app

import pytz
import requests


def grab_json(uri):
    try:
        response = requests.get(uri)
    except requests.ConnectionError:
        return None
    return json.loads(response.text)


def now():
    return datetime.now(pytz.utc)


def uuid():
    return str(uuid4())
