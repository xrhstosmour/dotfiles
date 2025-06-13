#!/bin/bash
# Catch exit signal (`CTRL` + `C`) to terminate the whole script.
trap "exit" INT

# Terminate script on error.
set -e

# Constant variable of the scripts' working directory to use for relative paths.
SOUND_SCRIPT_DIRECTORY=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# Import constant variables.
source "$SOUND_SCRIPT_DIRECTORY/../../helpers/logs.sh"

# Function to apply Sound configuration.
# Usage:
#   apply_sound_configuration
apply_sound_configuration() {
    log_info "Applying Sound configuration..."

    # Disable sound on startup/boot.
    log_info "Disabling sound on startup/boot..."
    sudo nvram StartupMute=%01

    # Increase sound quality for `Bluetooth` headphones/headsets.
    log_info "Increasing sound quality for 'Bluetooth' headphones/headsets..."
    defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40

    # Reduce latency for `Bluetooth` headphones/headsets.
    log_info "Reducing latency for 'Bluetooth' headphones/headsets..."
    sudo defaults write bluetoothaudiod "Enable AAC codec" -bool true

    # Disable `AirDrop`.
    log_info "Disabling 'AirDrop'..."
    defaults write com.apple.sharingd DiscoverableMode -string "Off"

    # Disable speech recognition
    log_info "Disabling speech recognition..."
    sudo defaults write "com.apple.speech.recognition.AppleSpeechRecognition.prefs" StartSpeakableItems -bool false

    # Stop `iTunes` from responding to the keyboard media keys.
    log_info "Stopping 'iTunes' from responding to the keyboard media keys..."
    launchctl unload -w /System/Library/LaunchAgents/com.apple.rcd.plist 2>/dev/null

    log_success "Sound configuration applied successfully."
    log_divider
}
