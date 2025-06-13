#!/bin/bash
# Catch exit signal (`CTRL` + `C`) to terminate the whole script.
trap "exit" INT

# Terminate script on error.
set -e

# Constant variable of the scripts' working directory to use for relative paths.
FINDER_SCRIPT_DIRECTORY=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# Import functions and flags.
source "$FINDER_SCRIPT_DIRECTORY/../../helpers/logs.sh"

# Function to apply `Finder` configuration.
# Usage:
#   apply_finder_configuration
apply_finder_configuration() {
    log_info "Applying 'Finder' configuration..."

    # Display path in `Finder` windows.
    log_info "Showing path bar in 'Finder' windows..."
    defaults write com.apple.finder ShowPathbar -bool true

    # Show status bar in `Finder` windows.
    log_info "Showing status bar in 'Finder' windows..."
    defaults write com.apple.finder ShowStatusBar -bool true

    # Show hidden files in `Finder` windows.
    log_info "Showing hidden files in 'Finder' windows..."
    defaults write com.apple.finder AppleShowAllFiles true

    # Show files's extensions.
    log_info "Showing files' extensions in 'Finder' windows..."
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true
    defaults write -g AppleShowAllExtensions -bool true

    # Show all hidden files.
    log_info "Showing all hidden files in 'Finder' windows..."
    defaults write com.apple.Finder AppleShowAllFiles true

    # Show hidden `/Volumes` and `~/Library` folders.
    log_info "Showing hidden '/Volumes' and '~/Library' folders in 'Finder' windows..."
    chflags nohidden ~/Library
    sudo chflags nohidden /Volumes

    # Show icons for external hard drives, servers, and removable media on the 'Desktop'.
    log_info "Showing icons for external hard drives, servers, and removable media on the 'Desktop'..."
    defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
    defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
    defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

    # Use list view in all `Finder` windows by default.
    log_info "Using list view in all 'Finder' windows by default..."
    defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

    # Stop `.DS_Store` creation at network shares and removable drives.
    log_info "Stopping '.DS_Store' creation at network shares and removable drives..."
    defaults write com.apple.desktopservices DSDontWriteNetworkStores true
    defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

    # Expand `Save` panel by default.
    log_info "Expanding 'Save Panel' by default..."
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true

    # Expand `Print Panel` by default.
    log_info "Expanding 'Print Panel' by default..."
    defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
    defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

    # Set `Finder` windows to open in the home directory by default.
    log_info "Setting new 'Finder' windows to point to home directory..."
    defaults write com.apple.finder NewWindowTarget -string "PfHm"

    # Disable the warning when changing a file extension.
    log_info "Disabling the warning when changing a file extension..."
    defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

    log_success "'Finder' configuration applied successfully."
    log_divider
}
