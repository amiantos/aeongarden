up:
	docker-compose up

down:
	docker-compose down

test:
ifdef t
	docker-compose run --user=root --rm api pytest -k $(t)
else
	docker-compose run --user=root --rm api pytest
endif

test-debug:
ifdef t
	docker-compose run --user=root --rm api pytest --pdb -k $(t)
else
	docker-compose run --user=root --rm api pytest --pdb
endif

test-coverage:
	docker-compose run --user=root --rm api pytest --cov=aeon --cov=rest

test-coverage-lines:
	docker-compose run --user=root --rm api pytest --cov-report term-missing --cov=aeon --cov=rest

shell:
	docker-compose run --rm api bash -c "flask shell"