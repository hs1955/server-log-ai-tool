.PHONY: requirements run test shell build clean help # State that these are commands, not files

requirements:  ## Recompile locks, sync venv, rebuild container
	pip-compile requirements.in
	pip-compile requirements-dev.in
	pip-sync requirements.txt requirements-dev.txt
	docker compose build

run:  ## Run the analyzer: make run ARGS="samples/test.log"
	docker compose run --rm app python -m app.main $(ARGS)

test:  ## Run the test suite in the container
	docker compose run --rm app pytest -xvs

shell:  ## Drop into a shell in the container
	docker compose run --rm app bash

build:  ## Rebuild the container without touching deps
	docker compose build

clean:  ## Remove build artifacts and caches
	find . -type d -name __pycache__ -exec rm -rf {} +
	rm -rf .pytest_cache .ruff_cache

help:  ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  %-15s %s\n", $$1, $$2}'