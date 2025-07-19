#!/bin/bash
# Catch exit signal (`CTRL` + `C`) to terminate the whole script.
trap "exit" INT

# Terminate script on error.
set -e

# Constant variable of the scripts' working directory to use for relative paths.
SYSTEM_SCRIPT_DIRECTORY=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# Import constant variables.
source "$SYSTEM_SCRIPT_DIRECTORY/../../helpers/logs.sh"

# Function to apply System configuration.
# Usage:
#   apply_system_configuration
apply_system_configuration() {
    log_info "Applying System configuration..."

    # Turn off `Bluetooth`, if you don't have a mouse/keyboard/headphone connected.
    log_info "Turning off 'Bluetooth' when not using a mouse/keyboard/headphone..."
    sudo defaults write /Library/Preferences/com.apple.Bluetooth ControllerPowerState -int 0

    # Save screenshots to the 'Desktop'.
    log_info "Saving screenshots to the 'Desktop'..."
    defaults write com.apple.screencapture location -string "${HOME}/Desktop"

    # Save screenshots in lossless `PNG` format.
    log_info "Saving screenshots in lossless 'PNG' format..."
    defaults write com.apple.screencapture type -string "png"

    # Show scroll-bars always.
    log_info "Showing scroll-bars always..."
    defaults write NSGlobalDomain AppleShowScrollBars -string "Always"

    # Disable `Siri`.
    log_info "Disabling 'Siri'..."
    defaults write com.apple.Siri StatusMenuVisible -bool false
    defaults write com.apple.assistant.support "Assistant Enabled" -bool false

    # Disabling `Reopen Windows When Logging Back`.
    log_info "Disabling 'Reopen Windows When Logging Back'..."
    defaults write com.apple.loginwindow TALLogoutSavesState -bool false

    # Disable password hints.
    log_info "Disabling password hints..."
    defaults write com.apple.loginwindow RetriesUntilHint -int 0

    # Change time and date format.
    log_info "Changing time and date format..."
    defaults write com.apple.menuextra.clock IsAnalog -bool false
    defaults write com.apple.menuextra.clock DateFormat -string "EEE d MMM HH:mm"
    defaults write .GlobalPreferences AppleICUForce24HourTime -bool true

    # Enable Firewall and stealth mode with exceptions for file sharing apps
    log_info "Enabling firewall and stealth mode with exceptions for file sharing apps..."
    /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
    /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on

    # Allow file sharing applications through firewall.
    log_info "Exclude applications from the firewall rules..."
    for app in "LocalSend" "Syncthing"; do
        if [ -d "/Applications/$app.app" ]; then
            log_info "Adding $app to firewall exceptions..."
            /usr/libexec/ApplicationFirewall/socketfilterfw --add "/Applications/$app.app"
            /usr/libexec/ApplicationFirewall/socketfilterfw --unblock "/Applications/$app.app"
        fi
    done

    # ! IMPORTANT: You need to grant `Full Disk Access` to the terminal running this script.
    # Exclude applications from quarantine.
    log_info "Exclude applications from quarantine..."
    for app in "LocalSend" "Syncthing"; do
        if [ -d "/Applications/$app.app" ]; then
            log_info "Exclude $app from quarantine..."
            sudo xattr -dr com.apple.quarantine "/Applications/$app.app"
        fi
    done


    # Remove unneeded default applications from the Applications folder.
    log_info "Removing unneeded default applications from /Applications..."
    for app in "GarageBand" "iMovie" "Pages" "Keynote" "Books" "Chess" "Dictionary" "Numbers" "News" "Podcasts" "Stocks" "TV" "Music"; do
        if [ -d "/Applications/$app.app" ]; then
            sudo rm -rf "/Applications/$app.app"
            log_info "Removed $app.app."
        fi
    done

    # Remove leftover user/library data for deleted apps.
    log_info "Removing leftover Library data for deleted apps..."
    for dir in "~/Library/Containers/com.apple.TV" "~/Library/Containers/com.apple.Music" "~/Library/Containers/com.apple.iWork.Pages" "~/Library/Containers/com.apple.iWork.Keynote" "~/Library/Containers/com.apple.iWork.Numbers"; do
        eval expanded_dir=$dir
        if [ -d "$expanded_dir" ]; then
            rm -rf "$expanded_dir"
            log_info "Removed $expanded_dir."
        fi
    done

    # Show all processes in `Activity Monitor`.
    log_info "Showing all processes in 'Activity Monitor'..."
    defaults write com.apple.ActivityMonitor ShowCategory -int 0

    # Show the main window when launching `Activity Monitor`.
    log_info "Showing the main window when launching 'Activity Monitor'..."
    defaults write com.apple.ActivityMonitor OpenMainWindow -bool true

    log_info "Configuring 'Login Items'..."
    for application in "Filen" "KeePassXC" "Maccy" "SwipeAeroSpace" "Syncthing"; do
        if ! osascript -e 'tell application "System Events" to get the name of every login item' | tr ', ' '\n' | grep -Fxq "$application"; then
            log_info "Adding '$application' to login items..."
            osascript -e "tell application \"System Events\" to make login item at end with properties {name: \"$application\", path:\"/Applications/$application.app\", hidden:true}"
        fi
    done

    log_success "System configuration applied successfully."
    log_divider
}
