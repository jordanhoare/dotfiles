for f in ~/.zsh/conf.d/*.zsh; do source "$f"; done

if [[ -n "$WSL_DISTRO_NAME" ]]; then
  source ~/.zsh/platform/wsl.zsh
elif [[ "$OSTYPE" == darwin* ]]; then
  source ~/.zsh/platform/macos.zsh
else
  source ~/.zsh/platform/linux.zsh
fi
