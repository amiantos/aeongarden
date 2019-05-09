from sqlalchemy import LargeBinary, Boolean, Column, DateTime, Integer, String
from sqlalchemy.sql import func

from aeon import db


class User(db.Model):
    id = Column(Integer, primary_key=True)
    uuid = Column(String(36), index=True, nullable=False, unique=True)
    icloud = Column(String(120), index=True, nullable=True, unique=True)
    email = Column(String(120), index=True, nullable=True, unique=True)
    password_hash = Column(LargeBinary(), nullable=True)
    date_added = Column(DateTime(True), default=func.now())

    def __repr__(self):
        return "<User {}>".format(self.id)


class APIToken(db.Model):
    token = Column(String(36), primary_key=True)
    active = Column(Boolean(), default=True)
    date_created = Column(DateTime(True), nullable=False, default=func.now())
    meta = Column(String())
