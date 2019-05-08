from flask import Blueprint

app = Blueprint("apiv3", __name__)

from . import accounts

