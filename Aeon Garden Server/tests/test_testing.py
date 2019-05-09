from tests.model_factories import UserFactory
from repo import Repo

from .test_api import BaseTestCase


class TestTesting(BaseTestCase):
    def setUp(self):
        self.repo = Repo(autocommit=True)
        self.user = UserFactory(email="info@numutracker.com")
        self.repo.save(self.user)

    def test_testing(self):
        user = self.repo.get_user_by_email("info@numutracker.com")

        assert user.email == "info@numutracker.com"
