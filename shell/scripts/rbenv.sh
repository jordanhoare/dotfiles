#!/bin/bash
set -e


# Update and install dependencies
sudo apt-get update
sudo apt-get install -y git curl libssl-dev libreadline-dev zlib1g-dev autoconf bison \
build-essential libyaml-dev libreadline-dev libncurses5-dev libffi-dev libgdbm-dev

# Remove any existing rbenv installation
rm -rf ~/.rbenv

# Install rbenv
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc

# Apply rbenv settings to the current shell session
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

# Install ruby-build as an rbenv plugin
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build

# Install Ruby 3.1.4 and set it as the global default
rbenv install 3.1.4
rbenv global 3.1.4

# Rehash to ensure all shims are up to date
rbenv rehash

echo "Ruby 3.1.4 installation is complete."

