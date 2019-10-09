import logging
from logging.handlers import RotatingFileHandler
import response

from flask import Flask, make_response, jsonify, g

from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from flask_httpauth import HTTPBasicAuth
from flask_bcrypt import Bcrypt

app = Flask(__name__)
bcrypt = Bcrypt(app)
auth = HTTPBasicAuth()

app.config.from_object("config.Config")

db = SQLAlchemy(app)

import models

migrate = Migrate(app, db)


err_handler = RotatingFileHandler("aeon-error.log", maxBytes=1000000, backupCount=5)
err_handler.setFormatter(
    logging.Formatter(
        "%(asctime)s | %(pathname)s:%(lineno)d | %(funcName)s | %(levelname)s | %(message)s"
    )
)
err_handler.setLevel(logging.ERROR)
app.logger.addHandler(err_handler)

app.logger.setLevel(logging.DEBUG)


import repo


@auth.verify_password
def verify_password(username, password):
    g.user = None
    if password == "icloud":
        user = repo.get_user_by_icloud(username)
        if user:
            g.user = user
            return True
    else:
        user = repo.get_user_by_email(username)
        if user and bcrypt.check_password_hash(user.password_hash, password):
            g.user = user
            return True

    return False


@app.errorhandler(404)
def not_found(error):
    return make_response(jsonify({"error": "Not found"}), 404)


@auth.error_handler
def unauthorized():
    return response.unauthorized()


@app.route("/")
def index():
    return "Aeon Garden API - {}".format(app.config["ENVIROMENT"])


from rest import app as api

app.register_blueprint(api, url_prefix="/1")
