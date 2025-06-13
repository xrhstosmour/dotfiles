#!/bin/bash

# Catch exit signal (`CTRL` + `C`) to terminate the whole script.
trap "exit" INT

# Terminate script on error.
set -e

# Constant variable of the scripts' working directory to use for relative paths.
HOMEBREW_SCRIPT_DIRECTORY=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# Import functions and flags.
source "$HOMEBREW_SCRIPT_DIRECTORY/../../helpers/logs.sh"

# Declare `Homebrew` constants.
HOMEBREW_INSTALL_URL="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
HOMEBREW_BIN_PATH="/opt/homebrew/bin/brew"
ZPROFILE_PATH="$HOME/.zprofile"

# Install and configure `Homebrew`.
if ! command -v brew &>/dev/null; then
  log_info "Installing 'Homebrew'..."
  /bin/bash -c "$(curl -fsSL ${HOMEBREW_INSTALL_URL})"

  # Check if the environment variables are set.
  HOMEBREW_ENVIRONMENT_COMMAND="eval \"\$(${HOMEBREW_BIN_PATH} shellenv)\""
  if ! grep -qF -- "$HOMEBREW_ENVIRONMENT_COMMAND" "$ZPROFILE_PATH"; then
    log_info "Adding 'Homebrew' environment to ${ZPROFILE_PATH}..."
    echo >>"$ZPROFILE_PATH"
    echo "$HOMEBREW_ENVIRONMENT_COMMAND" >>"$ZPROFILE_PATH"
    eval "$($HOMEBREW_BIN_PATH shellenv)"
  fi
else
  log_warning "'Homebrew' is already installed."
fi

log_divider
