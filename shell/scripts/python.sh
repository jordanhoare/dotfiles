#!/bin/bash
set -eu

PYENV_DIR="$HOME/.pyenv"
POETRY_DIR="$HOME/.poetry"

# Install pyenv
if [ ! -d "$PYENV_DIR" ]; then
    git clone https://github.com/pyenv/pyenv.git "$PYENV_DIR"

    py_versions=("3.8")
    for py_version in "${py_versions[@]}"; do
        "$PYENV_DIR"/bin/pyenv install "$py_version"
    done
fi

# Set the global Python version to the newest one.
"$PYENV_DIR"/bin/pyenv global "${py_versions[-1]}"

# Install poetry
if [ ! -d "$POETRY_DIR" ]; then
    curl -sSL https://install.python-poetry.org | POETRY_HOME="$POETRY_DIR" python3 -
fi