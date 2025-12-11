### NVM

ZSH_THEME_NVM_PROMPT_PREFIX="%B⬡%b "
ZSH_THEME_NVM_PROMPT_SUFFIX=""

### Git [±master ▾●]

ZSH_THEME_GIT_PROMPT_PREFIX="[%{$fg_bold[blue]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}]"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg_bold[green]%}✓%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_AHEAD="%{$fg[cyan]%}▴%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_BEHIND="%{$fg[magenta]%}▾%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_STAGED="%{$fg_bold[green]%}●%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_UNSTAGED="%{$fg_bold[yellow]%}●%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg_bold[red]%}●%{$reset_color%}"

# Performance optimizations for WSL/Windows mounts
GIT_STATUS_CACHE=""
GIT_STATUS_CACHE_DIR=""
GIT_STATUS_CACHE_TIME=0
GIT_STATUS_CACHE_TTL_NATIVE=5   # 5 seconds for native filesystem
GIT_STATUS_CACHE_TTL_WINDOWS=30 # 30 seconds for Windows mounts (/mnt/*)

# Fast commands that don't need git status updates
FAST_COMMANDS=("clear" "c" "ls" "ll" "pwd" "echo" "export" "alias" "history" "exit" "reload")

function is_fast_command() {
  local cmd="$1"
  cmd=$(echo "$cmd" | xargs | cut -d' ' -f1)
  for fast_cmd in "${FAST_COMMANDS[@]}"; do
    if [[ "$cmd" == "$fast_cmd" ]]; then
      return 0
    fi
  done
  return 1
}

function is_windows_mount() {
  # Check if current directory is on a Windows mount (/mnt/*)
  # Git operations on Windows mounts are extremely slow due to 9P protocol
  [[ "$PWD" == /mnt/* ]]
}

bureau_git_branch () {
  ref=$(command git symbolic-ref HEAD 2> /dev/null) || \
  ref=$(command git rev-parse --short HEAD 2> /dev/null) || return
  echo "${ref#refs/heads/}"
}

# Optimized git status - uses caching and skips expensive operations on Windows mounts
bureau_git_status () {
  # Skip git status for fast commands
  local last_cmd=$(fc -ln -1 2>/dev/null | xargs)
  if is_fast_command "$last_cmd"; then
    echo "$GIT_STATUS_CACHE"
    return 0
  fi

  # Check cache
  local current_dir="$PWD"
  local current_time=$(date +%s 2>/dev/null || echo 0)
  local cache_ttl=$GIT_STATUS_CACHE_TTL_NATIVE
  
  if is_windows_mount; then
    cache_ttl=$GIT_STATUS_CACHE_TTL_WINDOWS
  fi

  # Use cached status if directory hasn't changed and cache is fresh
  if [[ "$current_dir" == "$GIT_STATUS_CACHE_DIR" ]] && \
     [[ -n "$GIT_STATUS_CACHE_DIR" ]] && \
     [[ $((current_time - GIT_STATUS_CACHE_TIME)) -lt $cache_ttl ]]; then
    echo "$GIT_STATUS_CACHE"
    return 0
  fi

  # Fast check if we're in a git repository
  if ! command git rev-parse --git-dir > /dev/null 2>&1; then
    GIT_STATUS_CACHE=""
    GIT_STATUS_CACHE_DIR="$current_dir"
    GIT_STATUS_CACHE_TIME=$current_time
    echo ""
    return 0
  fi

  # On Windows mounts, use minimal git status (just branch, no detailed status)
  if is_windows_mount; then
    # Skip expensive status checks on Windows mounts - just return clean indicator
    GIT_STATUS_CACHE=""
    GIT_STATUS_CACHE_DIR="$current_dir"
    GIT_STATUS_CACHE_TIME=$current_time
    echo ""
    return 0
  fi

  # For native filesystem, do full status check (but cached)
  _INDEX=$(command git status --porcelain -b 2> /dev/null)
  _STATUS=""
  if $(echo "$_INDEX" | grep '^[AMRD]. ' &> /dev/null); then
    _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_STAGED"
  fi
  if $(echo "$_INDEX" | grep '^.[MTD] ' &> /dev/null); then
    _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_UNSTAGED"
  fi
  if $(echo "$_INDEX" | command grep -E '^\?\? ' &> /dev/null); then
    _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_UNTRACKED"
  fi
  if $(echo "$_INDEX" | grep '^UU ' &> /dev/null); then
    _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_UNMERGED"
  fi
  if $(command git rev-parse --verify refs/stash >/dev/null 2>&1); then
    _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_STASHED"
  fi
  if $(echo "$_INDEX" | grep '^## .*ahead' &> /dev/null); then
    _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_AHEAD"
  fi
  if $(echo "$_INDEX" | grep '^## .*behind' &> /dev/null); then
    _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_BEHIND"
  fi
  if $(echo "$_INDEX" | grep '^## .*diverged' &> /dev/null); then
    _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_DIVERGED"
  fi

  # Cache the result
  GIT_STATUS_CACHE="$_STATUS"
  GIT_STATUS_CACHE_DIR="$current_dir"
  GIT_STATUS_CACHE_TIME=$current_time

  echo $_STATUS
}

bureau_git_prompt () {
  local _branch=$(bureau_git_branch)
  local _status=$(bureau_git_status)
  local _result=""
  if [[ "${_branch}x" != "x" ]]; then
    _result="$ZSH_THEME_GIT_PROMPT_PREFIX$_branch"
    if [[ "${_status}x" != "x" ]]; then
      _result="$_result $_status"
    fi
    _result="$_result$ZSH_THEME_GIT_PROMPT_SUFFIX"
  fi
  echo $_result
}


_PATH="%{$fg[magenta]%}%~%{$reset_color%}"

if [[ $EUID -eq 0 ]]; then
  _USERNAME="%{$fg_bold[red]%}%n"
  _LIBERTY="%{$fg[red]%}#"
else
  _USERNAME="%{$fg_bold[white]%}%n"
  _LIBERTY="%{$fg[blue]%}>"
fi
_USERNAME="$_USERNAME%{$reset_color%}@%m"
_LIBERTY="$_LIBERTY%{$reset_color%}"


get_space () {
  local STR=$1$2
  local zero='%([BSUbfksu]|([FB]|){*})'
  local LENGTH=${#${(S%%)STR//$~zero/}} 
  local SPACES=""
  (( LENGTH = ${COLUMNS} - $LENGTH - 1))
  
  for i in {0..$LENGTH}
    do
      SPACES="$SPACES "
    done

  echo $SPACES
}

_1LEFT="$_PATH"
_1RIGHT="%{$fg[magenta]%}% [%*] %{$reset_color%}"

bureau_precmd () {
  _1SPACES=`get_space $_1LEFT $_1RIGHT`
  print 
  print -rP "$_1LEFT$_1SPACES$_1RIGHT"
}

setopt prompt_subst
PROMPT=' %{$fg_bold[green]%}☯%{$reset_color%}  '
RPROMPT='$(nvm_prompt_info) $(bureau_git_prompt)'

autoload -U add-zsh-hook
add-zsh-hook precmd bureau_precmd

