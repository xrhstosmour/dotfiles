#!/bin/bash
# ! IMPORTANT: You need to grant `System Settings → Privacy & Security → Accessibility` permissions to the application running this script for it to work properly.

# Disable `emoji` picker shortcuts.
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 190 '{enabled = 0;}' 2>/dev/null
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 184 '{enabled = 0;}' 2>/dev/null

# Set `Spotlight` to use Command+Space.
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 64 '{
    enabled = 1;
    value = {
        parameters = (32, 49, 1048576);
        type = "standard";
    };
}' 2>/dev/null

# Force reload.
/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u 2>/dev/null
sleep 0.1

# Now open `Spotlight`.
osascript -e 'tell application "System Events" to key code 49 using {command down}'
