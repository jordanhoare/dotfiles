#!/bin/bash
set -eu

# Python environment setup steps...
echo "Python setup script"

########################
# Python
########################

# if [[ -n ${PYENV_VERSIONS+x} ]]; then
#   # If the PYENV_VERSIONS environment variable is set, parse the
#   # space-separated list into an array and store it in $py_versions.
#   # For instance, "2.7 3.6 3.8.5" becomes ("2.7" "3.6" "3.8.5")
#   IFS=" " read -rA py_versions <<<"${PYENV_VERSIONS}"
# else
#   # else... default to the following versions
#   py_versions=("3.8" "3.9" "3.10" "3.11")
# fi

# log_info "Installing the following Python versions (in parallel) w/ pyenv: $py_versions"
# (
#   for py_version in "${py_versions[@]}"; do
#     (
#       tau-install "$py_version"
#       tau-global "$py_version"
#     ) &
#   done
#   wait
# )