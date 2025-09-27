#!/bin/bash
# ! IMPORTANT: You need to grant `System Settings → Privacy & Security → Accessibility` permissions to the application running this script for it to work properly.

# Lock screen by sending Control+Command+Q using AppleScript.
osascript -e 'tell application "System Events" to key code 12 using {control down, command down}'
