SHELL := /bin/bash
PACKAGE_DIR := package

update-lambda: deployment.zip
	bin/update-lambda

$(PACKAGE_DIR):
	mkdir -p $@

deployment.zip: | $(PACKAGE_DIR)
	PIP_REQUIRE_VIRTUALENV=false pip install \
	  --platform manylinux2014_x86_64 \
	  --target=$(PACKAGE_DIR) \
	  --implementation cp \
	  --python-version 3.12 \
	  --only-binary=:all: \
	  .

	rm -rf $(PACKAGE_DIR)/scipy*
	(cd $(PACKAGE_DIR) && zip -r ../$@ .)
	zip $@ lambda_function.py

poetry.lock: pyproject.toml
	poetry lock --no-update

requirements-dev.txt: poetry.lock
	poetry export --format requirements.txt --with=dev > $@

.PHONY: tests
tests: test-lint test-unit test-integration

.PHONY: test-lint
test-lint:
	poetry run flake8 wells/ tests/

.PHONY: test-unit
test-unit:
	poetry run pytest -v --cov=wells -m "not integration"

.PHONY: test-integration
test-integration:
	poetry run pytest -v --cov=wells -m "integration"

clean:
	rm -rf deployment.zip package/
