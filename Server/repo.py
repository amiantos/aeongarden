from aeon import bcrypt, db
from sqlalchemy import or_
from models import User
from sqlalchemy.orm import joinedload
from sqlalchemy import and_


class Repo:
    def __init__(self, cache=None, autocommit=False):
        self._cache = cache
        self._autocommit = autocommit
        self._session = db.session
        self.did_commit = False

    def save(self, *argv):
        for obj in argv:
            db.session.add(obj)

        if self._autocommit:
            self.commit()

    def delete(self, *argv):
        for obj in argv:
            db.session.delete(obj)

        if self._autocommit:
            self.commit()

    def commit(self):
        self.did_commit = True
        db.session.commit()

    # --------------------------------------
    # User
    # --------------------------------------

    def insert_user(self, email=None, icloud=None, password=None):
        hashed_password = None
        if password:
            hashed_password = bcrypt.generate_password_hash(password)

        new_user = User(password_hash=hashed_password, icloud=icloud, email=email)
        db.session.add(new_user)
        db.session.commit()

        return new_user

    def get_user_by_email(self, email):
        users = User.query.filter_by(email=email)
        for user in users:
            return user
        return None

    def get_user_by_icloud(self, icloud):
        users = User.query.filter_by(icloud=icloud)
        for user in users:
            return user
        return None
