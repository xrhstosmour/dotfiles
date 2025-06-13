#!/bin/bash
# Catch exit signal (`CTRL` + `C`) to terminate the whole script.
trap "exit" INT

# Terminate script on error.
set -e

# Constant variable of the scripts' working directory to use for relative paths.
TRACKPAD_SCRIPT_DIRECTORY=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# Import constant variables.
source "$TRACKPAD_SCRIPT_DIRECTORY/../../helpers/logs.sh"

# Function to apply Trackpad configuration.
# Usage:
#   apply_trackpad_configuration
apply_trackpad_configuration() {
    log_info "Applying 'Trackpad' configuration..."

    # Map bottom right corner to right-click.
    log_info "Mapping bottom right corner to right-click..."
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick -int 2
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
    defaults -currentHost write NSGlobalDomain com.apple.trackpad.trackpadCornerClickBehavior -int 1
    defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true
    defaults write com.apple.AppleMultitouchTrackpad TrackpadCornerSecondaryClick -int 2
    defaults write com.apple.AppleMultitouchTrackpad TrackpadRightClick -bool true

    # Set preferred tracking speed.
    log_info "Setting preferred tracking speed..."
    defaults write -g com.apple.mouse.scaling 0.5

    # Invert mouse scroll.
    log_info "Inverting mouse scroll..."
    defaults write -g com.apple.swipescrolldirection -bool false

    # Disable `Dictionary` pop-up when right-clicking.
    log_info "Disabling 'Dictionary' pop-up when right-clicking..."
    defaults write com.apple.finder FXEnableDictionary -bool false

    log_success "Trackpad configuration applied successfully."
    log_divider
}
