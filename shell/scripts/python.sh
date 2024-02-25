#!/bin/bash
set -eu

# Install pyenv
if ! command -v $HOME/.pyenv/bin/pyenv &> /dev/null; then
    git clone https://github.com/pyenv/pyenv.git $HOME/.pyenv

    py_versions=("3.8" "3.10.10")
    for py_version in "${py_versions[@]}"; do
        $HOME/.pyenv/bin/pyenv install "$py_version"
    done
fi

# Set the global Python version to the newest one.
$HOME/.pyenv/bin/pyenv global "${py_versions[-1]}"

# Install poetry
if ! command -v $HOME/.poetry/bin/poetry &> /dev/null; then
    curl -sSL https://install.python-poetry.org | POETRY_HOME=$HOME/.poetry python3 -
fi
