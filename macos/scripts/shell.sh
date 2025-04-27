#!/bin/bash

# Catch exit signal (`CTRL` + `C`) to terminate the whole script.
trap "exit" INT

# Terminate script on error.
set -e

# Constant variable of the scripts' working directory to use for relative paths.
SHELL_SCRIPT_DIRECTORY=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# Import functions and flags.
source "$SHELL_SCRIPT_DIRECTORY/../../helpers/logs.sh"

# Declare `Fish` constants.
FISH_PATH="/opt/homebrew/bin/fish"
SHELLS_PATH="/etc/shells"

# Add `Fish` shell path to `/etc/shells` if it's not already present.
if ! grep -q "^${FISH_PATH}$" "${SHELLS_PATH}"; then
  log_info "Adding '${FISH_PATH}' to '"${SHELLS_PATH}"'..."
  echo "${FISH_PATH}" | sudo tee -a "${SHELLS_PATH}"
else
  log_warning "'${FISH_PATH}' already exists in '"${SHELLS_PATH}"'."
fi

# Get the current user's default shell.
CURRENT_SHELL=$(dscl . -read "/Users/$(whoami)" UserShell | sed 's/UserShell: //')

# Check if the current shell is already `Fish` and change it if not.
if [ "${CURRENT_SHELL}" != "${FISH_PATH}" ]; then
  log_info "Changing default shell to '${FISH_PATH}'..."
  chsh -s "${FISH_PATH}"
else
  log_warning "Default shell is already set to '${FISH_PATH}'."
fi
