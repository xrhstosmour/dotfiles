#!/bin/bash
# Catch exit signal (`CTRL` + `C`) to terminate the whole script.
trap "exit" INT

# Terminate script on error.
set -e

# Constant variable of the scripts' working directory to use for relative paths.
APPEARANCE_SCRIPT_DIRECTORY=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# Import constant variables.
source "$APPEARANCE_SCRIPT_DIRECTORY/../../helpers/logs.sh"

# Function to apply Appearance configuration.
# Usage:
#   apply_appearance_configuration
apply_appearance_configuration() {
    log_info "Applying Appearance configuration..."

    # Set wallpaper.
    log_info "Setting wallpaper..."
    if [ ! -d ~/Pictures/wallpapers ]; then
        mkdir -p ~/Pictures/wallpapers
    fi
    cp -R Wallpapers/* ~/Pictures/wallpapers/
    osascript -e 'tell application "System Events" to tell every desktop to set picture to POSIX file "~/Pictures/wallpapers/rocks_milky_stream.png"'

    # Set dark mode.
    log_info "Setting dark mode..."
    defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"

    # Set accent color to blue.
    log_info "Setting accent color to blue..."
    defaults write NSGlobalDomain AppleAccentColor -int 4

    # Disable `Click to wallpaper to reveal desktop`.
    log_info "Disabling 'Click to wallpaper to reveal desktop'..."
    defaults write com.apple.WindowManager EnableStandardClickToShowDesktop -bool false

    log_success "Appearance configuration applied successfully."
}
