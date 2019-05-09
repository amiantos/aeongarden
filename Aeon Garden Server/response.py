import time

from flask import jsonify


def success(result=None):
    return jsonify(success=True, result=result), 200


def error(message=None):
    return jsonify(success=False, result={"message": message}), 400


def unauthorized():
    return (
        jsonify(
            success=False,
            result={"message": "You are not authorized to access this endpoint."},
            server_clock=int(time.time()),
        ),
        401,
    )


def invalid_apikey():
    return (
        jsonify(
            success=False,
            result={"message": "You API key is not valid or has expired."},
            server_clock=int(time.time()),
        ),
        401,
    )
