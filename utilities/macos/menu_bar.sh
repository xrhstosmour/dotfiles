#!/bin/bash
# Catch exit signal (`CTRL` + `C`) to terminate the whole script.
trap "exit" INT

# Terminate script on error.
set -e

# Constant variable of the scripts' working directory to use for relative paths.
MENU_BAR_SCRIPT_DIRECTORY=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# Import functions and flags.
source "$MENU_BAR_SCRIPT_DIRECTORY/../../helpers/logs.sh"

# Function to apply `Menu Bar` configuration.
# Usage:
#   apply_menu_bar_configuration
apply_menu_bar_configuration() {
    log_info "Applying 'Menu Bar' configuration..."

    # Show battery percentage in the `Menu Bar`.
    log_info "Showing battery percentage in the 'Menu Bar'..."
    defaults write com.apple.controlcenter BatteryShowPercentage -bool true

    # Show volume icon in the `Menu Bar`.
    log_info "Showing volume icon in the 'Menu Bar'..."
    defaults write com.apple.controlcenter Sound -int 18

    # Show `Bluetooth` icon in the `Menu Bar`.
    log_info "Showing 'Bluetooth' icon in the 'Menu Bar'..."
    defaults write com.apple.controlcenter Bluetooth -int 18

    log_success "'Menu Bar' configuration applied successfully."
}
