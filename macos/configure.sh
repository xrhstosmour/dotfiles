#!/bin/bash

# Catch exit signal (`CTRL` + `C`) to terminate the whole script.
trap "exit" INT

# Terminate script on error.
set -e

# Constant variable of the scripts' working directory to use for relative paths.
CONFIGURE_SCRIPT_DIRECTORY=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# Import functions and flags.
source "$CONFIGURE_SCRIPT_DIRECTORY/../helpers/logs.sh"

# Install developer tools.
sh macos/scripts/developer.sh

# Install and configure `Homebrew`.
sh macos/scripts/homebrew.sh

# Install dependencies and applications.
log_info "Installing needed dependencies and applications..."
brew bundle install --file=packages/macos/Brewfile

# Configure shell.
sh macos/scripts/shell.sh

# Configure `macOS` Preferences.
sh macos/scripts/preferences.sh
