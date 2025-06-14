#!/bin/bash
# Catch exit signal (`CTRL` + `C`) to terminate the whole script.
trap "exit" INT

# Terminate script on error.
set -e

# Constant variable of the scripts' working directory to use for relative paths.
DOCK_SCRIPT_DIRECTORY=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# Import functions and flags.
source "$DOCK_SCRIPT_DIRECTORY/../../helpers/logs.sh"

# Function to apply `Dock` configuration.
# Usage:
#   apply_dock_configuration
apply_dock_configuration() {
    log_info "Applying 'Dock' configuration..."

    # Clear the `Dock`.
    log_info "Clearing the 'Dock'..."
    defaults delete com.apple.dock persistent-apps 2>/dev/null || true
    defaults delete com.apple.dock persistent-others 2>/dev/null || true

    # Add applications to the `Dock`.
    log_info "Adding applications to the 'Dock'..."
    dock_apps=(
        "/Applications/Google Chrome.app"
        "/Applications/Brave Browser.app"
        "/Applications/Viber.app"
        "/Applications/Signal.app"
        "/Applications/Visual Studio Code.app"
        "/Applications/Sublime Text.app"
        "/Applications/Docker.app"
        "/Applications/Postman.app"
        "/Applications/Spotify.app"
        "/Applications/LocalSend.app"
        "/Applications/Obsidian.app"
        "/Applications/KeePassXC.app"
        "/Applications/WezTerm.app"
        "/System/Applications/Utilities/Activity Monitor.app"
        "/System/Applications/System Settings.app"
    )

    for app_path in "${dock_apps[@]}"; do
        if [ -d "$app_path" ]; then
            defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>$app_path</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"
        else
            log_error "Application not found, not adding to Dock: $app_path."
        fi
    done

    # Disable single application mode.
    log_info "Disabling single application mode..."
    defaults write com.apple.dock single-app -bool false

    # Disable animation when opening applications.
    log_info "Disabling animation when opening applications..."
    defaults write com.apple.dock launchanim -bool false

    # Disable animation when opening applications.
    log_info "Disabling animation when opening applications..."
    defaults write com.apple.dock launchanim -bool false

    # Automatically hide and show the `Dock`.
    log_info "Automatically hiding and showing the 'Dock'..."
    sudo defaults write /Library/Preferences/com.apple.dock autohide -bool true
    defaults write com.apple.dock autohide -bool true
    defaults write com.apple.dock autohide-delay -float 0

    # Show indicator lights for open applications in the `Dock`.
    log_info "Showing indicator lights for open applications in the 'Dock'..."
    defaults write com.apple.dock show-process-indicators -bool true

    # Change `Minimize/Maximize` window effect to `Scale`.
    log_info "Changing 'Minimize/Maximize' window effect to 'Scale'..."
    defaults write com.apple.dock mineffect -string "scale"

    # Hide recent applications.
    log_info "Hiding recent applications in the 'Dock'..."
    defaults write com.apple.dock show-recents -bool false

    # Minimize windows into application icon.
    log_info "Minimizing windows into application icon in the 'Dock'..."
    defaults write com.apple.dock minimize-to-application -bool true

    log_success "'Dock' configuration applied successfully."
    log_divider
}
