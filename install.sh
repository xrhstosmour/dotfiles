#!/bin/bash

# Catch exit signal (`CTRL` + `C`) to terminate the whole script.
trap "exit" INT

# Terminate script on error.
set -e

# Constant variable of the scripts' working directory to use for relative paths.
INSTALL_SCRIPT_DIRECTORY=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# Import functions and flags.
source "$INSTALL_SCRIPT_DIRECTORY/helpers/logs.sh"

# Copy the needed configuration files to the new machine.
log_info "Copying configuration files to '~/.config'..."
mkdir -p ~/.config && cp -R .config/* ~/.config/

log_info "Copying 'Git' configuration..."
cp "$INSTALL_SCRIPT_DIRECTORY/.gitconfig" ~
log_divider

# Detect `OS` and run the appropriate configuration script.
os_name=$(uname -s)
if [ "$os_name" = "Darwin" ]; then
  # Configure `macOS`.
  log_info "Starting 'macOS' configuration..."
  sh macos/configure.sh
elif [ "$os_name" = "Linux" ]; then
  # Check for `Arch Linux` specifically.
  if [ -f /etc/os-release ] && grep -q '^ID=arch$' /etc/os-release; then
    # Configure `Linux`.
    log_info "Starting 'Linux' configuration..."
    sh linux/configure.sh
  else
    log_error "Unsupported 'Linux' system!"
    exit 1
  fi
else
  log_error "Unsupported operating system!"
  exit 1
fi

log_success "System configuration completed!"

# Reboot system.
log_info "Initiating system reboot in 15 seconds..."
sleep 15
sudo reboot
