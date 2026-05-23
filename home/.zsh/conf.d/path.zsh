export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH"

export GOPATH="$HOME/go"
export GOROOT="/usr/local/go"
export GOBIN="$GOPATH/bin"
export PATH="$PATH:$GOPATH:$GOROOT/bin"

export PATH="$HOME/.aftman/bin:$HOME/.cargo/bin:$PATH"

[ -d "$HOME/.poetry/bin" ] && export PATH="$PATH:$HOME/.poetry/bin"
[ -d "$HOME/.cargo/bin" ]  && export PATH="$PATH:$HOME/.cargo/bin"
