# How to Init a Properly Versioned Dockerised Python Project
Sure we can just start coding, but quickly you may run into git issues committing wrong items, or tool versions changing.

It's true that Docker is overkill for this project, especially at the beginning: Python `pyproject.toml` can handle versioning Python and its packages. But I am using it to learn about Docker.

Docker pays off when several different programs need to be orchestrated together (and all of their versioning needs to be in one place). So it's still ok to use here.

## Different Setups for the same App
There is several different setups to interact with the app in:
1. Local Dev Environment
2. Dev Container
3. Testing Container
4. Production Container

Step 1 allows us to run the develop the project without an IDE that needs to go inside a container.

Testing container = dev container, but runs pytest instead of app with devtools.

### Why Have a Local Environment at All
We could just use VSCode's container abilities + devcontainer.json to create the dev container and start an IDE server inside there, so everyone uses exactly the same dev container setup and runs on Linux.

But there's 2 pros and 1 con to creating a local dev environment alongside a dev container:
#### Pros
1. Devs can work on an app with any IDE, not just IDEs that can support working inside devcontainers
2. If the app is not working, you can diagnose whether the problem is in the app code itself, or specifically in the Docker setup
3. There's still value in a devcontainer, e.g. for adding a database container in docker compose. You'll just interact with its API and never see its code.
#### Cons
1. You must maintain the local dev environment to practically mirror the dev container, which can be difficult across Windows and Linux - making this a source of inconsistencies
   - For a project like this, a single `requirements.txt` synchronizes both (easily).
   - `uv sync requirements.txt` will ensure your pyvenv perfectly matches the `requirements.txt` lockfile, even uninstalling additional packages.


## Init Steps for a Git-versioned Dockerised Python Program
1. Create the base folder structure. So an `app/main.py`, `tests/`, `samples/log.txt` (empty folders/files don't get committed)
2. Create a python venv (for local dev environment) `python -m venv .venv`
3. `pip install uv && uv init` will create `pyproject.toml` and `.python-version`. `uv` will take the main Python packages for our app, listed in `pyproject.toml`, and turn it into a `requirements.txt`, which pins down the version of Python, all the Python packages and all package dependencies. `uv` can also handle generating, modifying `pyproject.toml`, `.venv`, and running Python. It's all in one solution
4. Run `docker init` - this is a smart way to generate the init Docker boilerplate
5. Verify `docker compose build && docker compose run --rm app python app.main samples/test.log`
6. Download the official GitHub Python .gitignore template `curl -o .gitignore https://raw.githubusercontent.com/github/gitignore/main/Python.gitignore`
7. Setup gitleaks: https://github.com/gitleaks/gitleaks
8. `git init` and `git add . && git commit -m "Initial Scaffold"`
9. Create a Makefile, to create helper commands that string together multiple long commands

### Useful Commands to Check Setup is Correct
```bash
# 1. Confirm secrets and venv are NOT staged or tracked
git status --short          # should show no .env, no .venv/, no __pycache__
git ls-files | grep -E '\.env$|\.venv/'   # should print nothing

# 2. Confirm the ignore files are actually catching things
git check-ignore .env .venv/ __pycache__/   # each path should be echoed back

# 3. Confirm pre-commit is installed as a Git hook
pre-commit install          # if not already done
pre-commit run --all-files  # runs gitleaks across the tree; fix or whitelist findings

# 4. Verify the container actually runs your current app
docker compose build
docker compose run --rm app python -m app.main samples/test.log
```

## What does each init file do?
There's a lot of initial files and it looks like spaghetti, but break it down by technology, and it makes sense:
- Git: `.git`, `.gitignore`
- Pre-commit Git Hook: `.pre-commit-config.yaml`
- Local Python Env: `.venv`, `.env`
- Local/Dev/Production Python Envs: `pyproject.toml`, `uv.lock`
- Docker:
  - `Dockerfile` - How to build the app image
  - `compose.yaml` - How to orchestrate all the containers/services together
  - `.dockerignore` - Files not to be copied into your container
- Make: `Makefile` - String sequence of commands commonly used together (often, but not always, for building)