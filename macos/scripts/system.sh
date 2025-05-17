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

#? `Dock` configuration:
# Clear the `Dock`.
log_info "Clearing the 'Dock'..."
defaults delete com.apple.dock persistent-apps 2>/dev/null || true
defaults delete com.apple.dock persistent-others 2>/dev/null || true

# Add applications to the `Dock`.
log_info "Adding applications to the 'Dock'..."
dock_apps=(
    "/Applications/Google Chrome.app"
    "/Applications/Viber.app"
    "/Applications/Signal.app"
    "/Applications/Visual Studio Code.app"
    "/Applications/Sublime Text.app"
    "/Applications/Docker.app"
    "/Applications/Postman.app"
    "/Applications/Spotify.app"
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
        log_error "Application not found, not adding to Dock: $app_path"
    fi
done

# TODO: Add divider to the `Dock` for non pinned applications.

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

#? Keyboard configuration:
# Enable full keyboard access for all controls.
log_info "Enabling full keyboard access for all controls..."
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

#? Trackpad configuration:
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

#? Sound configuration:
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

#? Images configuration:
# Save screenshots to the 'Desktop'.
log_info "Saving screenshots to the 'Desktop'..."
defaults write com.apple.screencapture location -string "${HOME}/Desktop"

# Save screenshots in lossless `PNG` format.
log_info "Saving screenshots in lossless 'PNG' format..."
defaults write com.apple.screencapture type -string "png"

#? 'Desktop' configuration:
# Set wallpaper.
log_info "Setting wallpaper..."
if [ ! -d ~/Pictures/wallpapers ]; then
    mkdir -p ~/Pictures/wallpapers
fi
cp -R Wallpapers/* ~/Pictures/wallpapers/
osascript -e 'tell application "System Events" to tell every desktop to set picture to POSIX file "~/Pictures/wallpapers/cloudy_abstract_island.png"'

# Set dark mode.
log_info "Setting dark mode..."
defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"

# Set accent color to blue.
log_info "Setting accent color to blue..."
defaults write NSGlobalDomain AppleAccentColor -int 4

#? `Smart Typing` configuration:
# Disable smart quotes when typing code.
log_info "Disabling smart quotes when typing code..."
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

# Disable smart dashes when typing code.
log_info "Disabling smart dashes when typing code..."
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# Disable auto-correct.
log_info "Disabling auto-correct..."
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

#? System Preferences configuration:
# Disable press & hold for accents.
log_info "Disabling press & hold for accents..."
defaults write -g ApplePressAndHoldEnabled -bool false

# Turn off `Bluetooth`, if you don't have a mouse/keyboard/headphone connected.
log_info "Turning off 'Bluetooth' when not using a mouse/keyboard/headphone..."
sudo defaults write /Library/Preferences/com.apple.Bluetooth ControllerPowerState -int 0

# Show scroll-bars always.
log_info "Showing scroll-bars always..."
defaults write NSGlobalDomain AppleShowScrollBars -string "Always"

#? Change time and date format.
log_info "Changing time and date format..."
defaults write com.apple.menuextra.clock IsAnalog -bool false
defaults write com.apple.menuextra.clock DateFormat -string "EEE d MMM HH:mm"
defaults write .GlobalPreferences AppleICUForce24HourTime -bool true

#? Activity Monitor configuration:
# Show all processes in `Activity Monitor`.
log_info "Showing all processes in 'Activity Monitor'..."
defaults write com.apple.ActivityMonitor ShowCategory -int 0

# Show the main window when launching `Activity Monitor`.
log_info "Showing the main window when launching 'Activity Monitor'..."
defaults write com.apple.ActivityMonitor OpenMainWindow -bool true

#? Applications configuration:
for application in "Filen" "KeePassXC" "Syncthing"; do
    if ! osascript -e 'tell application "System Events" to get the name of every login item' | tr ', ' '\n' | grep -Fxq "$application"; then
        log_info "Adding '$application' to login items..."
        osascript -e "tell application \"System Events\" to make login item at end with properties {name: \"$application\", path:\"/Applications/$application.app\", hidden:true}"
    fi
done

#? 'Display' configuration:
# TODO: Enable `Reduce Transparency`.

# TODO: Disable `True Tone`.

# TODO: Disable `Automatically adjust brightness`.

# Change display resolution to hide the notch.
log_info "Hiding 'Notch' via changing display resolution..."
display_id=$(displayplacer list | grep "Persistent screen id:" | head -1 | awk '{print $4}')
current_mode_number=$(displayplacer list | grep "<-- current mode" | grep -o "mode [0-9]*:" | grep -o "[0-9]*")
previous_mode_number=$((current_mode_number - 1))
previous_mode_info=$(displayplacer list | grep -E "mode $previous_mode_number:")
previous_resolution=$(echo "$previous_mode_info" | awk '{print $3}' | cut -d':' -f2)
previous_hz=$(echo "$previous_mode_info" | awk '{print $4}' | cut -d':' -f2)
previous_color_depth=$(echo "$previous_mode_info" | awk '{print $5}' | cut -d':' -f2)
displayplacer "id:$display_id res:$previous_resolution hz:$previous_hz color_depth:$previous_color_depth scaling:on origin:(0,0) degree:0"
