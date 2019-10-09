import unittest

from aeon import app, db

from sqlalchemy import create_engine
from sqlalchemy_utils import database_exists, drop_database, create_database

app.config.from_object("config.Test")

engine = create_engine(app.config.get("SQLALCHEMY_DATABASE_URI"))
app.logger.info("Creating test database... {}".format(engine.url))
if database_exists(engine.url):
    drop_database(engine.url)
create_database(engine.url)
db.create_all()
db.session.commit()


class BaseTestCase(unittest.TestCase):
    def tearDown(self):
        db.session.remove()
        self.clear_data(db.session)

    @staticmethod
    def clear_data(session):
        meta = db.metadata
        skip = []
        for table in reversed(meta.sorted_tables):
            if table.name not in skip:
                session.execute(table.delete())
        session.commit()
