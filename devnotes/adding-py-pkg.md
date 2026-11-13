# Adding a Python Package
`pip freeze > requirements.txt` is one way of versioning packages.
But `pip freeze` doesn't care about dependency packages, only if it added a package.
We can separate packages we intended to install, and all packages that actually need to be installed:

## Separate Dependency Packages from All Installed Packages
1. `pip install pip-tools`
2. Create `requirements.in` file, and add packages you intend to install with their versions (much like `requirements.txt`)
3. Generate the actual requirements.txt: `pip-compile requirements.in`
4. Make sure your venv exactly match the compiled lock file: `pip-sync requirements.txt`

We don't need to change the `Dockerfile`, since it uses `requirements.txt`, and `pip-tools` manages `requirements.txt`.

## Later Upgrading Dependancies
1. `pip-compile --upgrade requirements.in`
2. `pip-compile --upgrade-package huggingface-hub requirements.in`
3. `pip-compile --rebuild requirements.in`