import utils
import factory
import factory.fuzzy
from models import User as UserModel
from aeon import db


class UserFactory(factory.alchemy.SQLAlchemyModelFactory):
    class Meta:
        model = UserModel
        sqlalchemy_session = db.session

    id = factory.Sequence(lambda n: n + 1)
    email = factory.fuzzy.FuzzyText(length=20, suffix="@example.com")
    icloud = None
    password_hash = b""
    date_joined = utils.now()
    date_last_activity = utils.now()
