#!/bin/bash
set -eu

if ! command -v $HOME/.cargo/bin/cargo &> /dev/null; then
    curl https://sh.rustup.rs -sSf | sh -s -- --no-modify-path -y
fi

