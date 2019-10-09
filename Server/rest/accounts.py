from flask import g, request

import response
from .api_key import require_apikey
from aeon import repo
from aeon import app as aeon_app
from aeon import auth

from . import app


@app.route("/user", methods=["POST"])
@require_apikey
def new_user():
    email = request.json.get("email")
    password = request.json.get("password")
    icloud = request.json.get("icloud")
    if (email is None or password is None) and icloud is None:
        return response.error("Proper account credentials were not provided.")

    if icloud and repo.get_user_by_icloud(icloud):
        return response.error("Registration failed.")

    if email and repo.get_user_by_email(email):
        return response.error("Registration failed.")

    user = repo.insert_user(email, icloud, password)
    if user:
        aeon_app.logger.info("New user created: {}".format(user.id))
        return response.success("New user created: {}".format(user.id))
    else:
        aeon_app.logger.error("New user failed to save.")
        return response.error("An unknown error occurred when creating this account.")


@app.route("/user")
@auth.login_required
@require_apikey
def get_user():
    return response.success(
        {
            "user": {
                "email": g.user.email,
                "icloud": g.user.icloud,
                "filters": g.user.filters,
            }
        }
    )
