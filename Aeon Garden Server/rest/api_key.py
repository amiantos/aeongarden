from flask import g
import response
from functools import wraps
from flask import request
from models import User, APIToken


def require_apikey(view_function):
    @wraps(view_function)
    def decorated_function(*args, **kwargs):
        api_key = request.args.get("api_key")
        # Development API Key gives access to test@test.com user account only.
        if api_key and api_key == "0efaacb4-14dd-40d4-a6bd-379f8783c853":
            g.user = User.query.filter_by(email="test@test.com").first()
            return view_function(*args, **kwargs)
        elif api_key and _validate_key(api_key):
            return view_function(*args, **kwargs)
        else:
            return response.invalid_apikey()

    return decorated_function


def _validate_key(api_key):
    return APIToken.query.filter(
        APIToken.token == api_key, APIToken.active.is_(True)
    ).first()
