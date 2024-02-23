export PATH="$HOME/.local/bin:$PATH"
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

export NVM_DIR=~/.nvm
source $(brew --prefix nvm)/nvm.sh
export PATH=~/.nvm/current/bin:$PATH


