#!/bin/bash
set -eu


################################################################################
# Import helper logging functions
################################################################################
DOTFILES_DIR="${0:a:h}"
SHELL_FUNCTIONS_DIR="$DOTFILES_DIR/shell/functions"
echo "[⋯] Importing helper logging functions from: $SHELL_FUNCTIONS_DIR"

source "$SHELL_FUNCTIONS_DIR/ansi.zsh"
source "$SHELL_FUNCTIONS_DIR/logging.zsh"
source "$SHELL_FUNCTIONS_DIR/misc.zsh"
source "$SHELL_FUNCTIONS_DIR/reboot.zsh"
source "$SHELL_FUNCTIONS_DIR/string.zsh"
source "$SHELL_FUNCTIONS_DIR/tau.zsh"

########################
# Python
########################

if [[ -n ${PYENV_VERSIONS+x} ]]; then
  # If the PYENV_VERSIONS environment variable is set, parse the
  # space-separated list into an array and store it in $py_versions.
  # For instance, "2.7 3.6 3.8.5" becomes ("2.7" "3.6" "3.8.5")
  IFS=" " read -rA py_versions <<<"${PYENV_VERSIONS}"
else
  # else... default to the following versions
  py_versions=("3.8" "3.9" "3.10" "3.11")
fi

log_info "Installing the following Python versions (in parallel) w/ pyenv: $py_versions"
(
  for py_version in "${py_versions[@]}"; do
    (
      tau-install "$py_version"
      tau-global "$py_version"
    ) &
  done
  wait
)

################################################################################
# If exists, run the extra local bootstrap script
################################################################################
if [[ -r ./scripts/extra.zsh ]]; then
  log_info "Running extra local bootstrap script..."
  source ./scripts/extra.zsh
fi


###############################################################################
# Reboot
###############################################################################
log_warning "❗❗ It is recommended to reboot your machine after running this script. ❗❗"
reboot
