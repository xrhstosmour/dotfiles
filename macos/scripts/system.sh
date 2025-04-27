#!/bin/bash

# Catch exit signal (`CTRL` + `C`) to terminate the whole script.
trap "exit" INT

# Terminate script on error.
set -e

# Constant variable of the scripts' working directory to use for relative paths.
SYSTEM_SCRIPT_DIRECTORY=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# Import functions and flags.
source "$SYSTEM_SCRIPT_DIRECTORY/../../helpers/logs.sh"

log_info "Applying 'macOS' system configurations..."

#? `Finder` configuration.
# Display path in `Finder` windows.
defaults write com.apple.finder ShowPathbar -bool true

# Show status bar in `Finder` windows.
defaults write com.apple.finder ShowStatusBar -bool true

# Show hidden files in `Finder` windows.
defaults write com.apple.finder AppleShowAllFiles true

# Show files's extensions.
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write -g AppleShowAllExtensions -bool true

# Show all hidden files.
defaults write com.apple.Finder AppleShowAllFiles true

# Show hidden `/Volumes` and `~/Library` folders.
chflags nohidden ~/Library
sudo chflags nohidden /Volumes

# Show icons for external hard drives, servers, and removable media on the desktop.
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

# Use list view in all `Finder` windows by default.
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Stop `.DS_Store` creation at network shares and removable drives.
defaults write com.apple.desktopservices DSDontWriteNetworkStores true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

#? `Dock` configuration:
# Clear the `Dock`.
defaults delete com.apple.dock persistent-apps 2>/dev/null || true
defaults delete com.apple.dock persistent-others 2>/dev/null || true

# Add applications to the `Dock`.
defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Google Chrome.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"
defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/ChatGPT.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"
defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Viber.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"
defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Signal.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"
defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Visual Studio Code.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"
defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Sublime Text.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"
defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Docker.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"
defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Postman.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"
defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Spotify.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"
defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Obsidian.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"
defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/KeePassXC.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"
defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/WezTerm.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"
defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/System/Applications/System Settings.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"

# Disable single application mode.
defaults write com.apple.dock single-app -bool false

# Disable animation when opening applications.
defaults write com.apple.dock launchanim -bool false

# Disable animation when opening applications.
defaults write com.apple.dock launchanim -bool false

# Automatically hide and show the `Dock`.
sudo defaults write /Library/Preferences/com.apple.dock autohide -bool true
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0

# Show indicator lights for open applications in the `Dock`.
defaults write com.apple.dock show-process-indicators -bool true

# Change minimize/maximize window effect to `Scale`.
defaults write com.apple.dock mineffect -string "scale"

# Hide recent applications.
defaults write com.apple.dock show-recents -bool false

# Minimize windows into application icon.
defaults write com.apple.dock minimize-to-application -bool true

#? Keyboard configuration:
# Enable full keyboard access for all controls.
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

#? Trackpad configuration:
# Map bottom right corner to right-click.
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick -int 2
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
defaults -currentHost write NSGlobalDomain com.apple.trackpad.trackpadCornerClickBehavior -int 1
defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true
defaults write com.apple.AppleMultitouchTrackpad TrackpadCornerSecondaryClick -int 2
defaults write com.apple.AppleMultitouchTrackpad TrackpadRightClick -bool true

# Set preffered tracking speed.
defaults write -g com.apple.mouse.scaling 0.5

# Invert mouse scroll.
defaults write -g com.apple.swipescrolldirection -bool false

#? Sound configuration:
# Disable sound on startup/boot.
sudo nvram StartupMute=%01

# Increase sound quality for `Bluetooth` headphones/headsets.
defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40

# Reduce latency for `Bluetooth` headphones/headsets.
sudo defaults write bluetoothaudiod "Enable AAC codec" -bool true

# TODO: Disable `AirDrop`.

# Disable speech recognition
sudo defaults write "com.apple.speech.recognition.AppleSpeechRecognition.prefs" StartSpeakableItems -bool false

# Stop `iTunes` from responding to the keyboard media keys.
launchctl unload -w /System/Library/LaunchAgents/com.apple.rcd.plist 2>/dev/null

#? Images configuration:
# Save screenshots to the desktop.
defaults write com.apple.screencapture location -string "${HOME}/Desktop"

# Save screenshots in lossless `PNG` format.
defaults write com.apple.screencapture type -string "png"

#? Desktop configuration:
# Set wallpaper.
if [ ! -d ~/Pictures/wallpapers ]; then
    mkdir -p ~/Pictures/wallpapers
fi
cp -R Wallpapers/* ~/Pictures/wallpapers/
osascript -e 'tell application "System Events" to tell every desktop to set picture to POSIX file "~/Pictures/wallpapers/cloudy_abstract_island.png"'

# Set dark mode.
defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"

# Set accent color to blue.
defaults write NSGlobalDomain AppleAccentColor -int 4

#? `Smart Typing` configuration:
# Disable smart quotes when typing code.
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

# Disable smart dashes when typing code.
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# Disable auto-correct.
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

#? System Preferences configuration:
# Disable press & hold for accents.
defaults write -g ApplePressAndHoldEnabled -bool false

# Turn off `Bluetooth`, if you don't have a mouse/keyboard/headphone connected.
sudo defaults write /Library/Preferences/com.apple.Bluetooth ControllerPowerState -int 0

# Show scroll-bars always.
defaults write NSGlobalDomain AppleShowScrollBars -string "Always"

# TODO: Disable Automatic Brightness

# TODO: Change time and date format.

#? Activity Monitor configuration:
# Show all processes in `Activity Monitor`.
defaults write com.apple.ActivityMonitor ShowCategory -int 0

# Show the main window when launching `Activity Monitor`.
defaults write com.apple.ActivityMonitor OpenMainWindow -bool true
