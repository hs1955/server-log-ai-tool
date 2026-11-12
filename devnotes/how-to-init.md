# How to Init the Project
## Different Setups for the same App
There is several different setups to interact with the app in:
1. Local Dev Environment
2. Dev Container
3. Testing Container
4. Production Container

Step 1 allows us to run the develop the project without an IDE that needs to go inside a container.
But environments 1 and 2 need to be almost the same, though dev on Windows for a Linux app will be limited.
Testing container = dev container, but runs pytest instead of app with devtools.

## Init Steps for a Git-versioned Dockerised Python Program
1. Create the base folder structure. So an `app/main.py`, `tests/`, `data/` (empty folder don't get committed)
2. Create a python venv (for local dev environment) `python -m venv .venv`
3. Create the `requirements.txt` for python: `pip freeze > requirements.txt`
4. Run `docker init` - this is a smart way to generate the init Docker boilerplate
5. Verify `docker compose build && docker compose run --rm app python app.main samples/test.log`
6. Download the official GitHub Python .gitignore template `curl -o .gitignore https://raw.githubusercontent.com/github/gitignore/main/Python.gitignore`
7. `git init` and `git add . && git commit -m "Initial Scaffold"`