#!/bin/bash
# ! IMPORTANT: You need to grant `System Settings → Privacy & Security → Accessibility` permissions to the application running this script for it to work properly.

osascript <<'EOF'
tell application "System Events"
    -- Click on desktop to ensure we're in `Finder` context (avoids app-specific shortcuts).
    tell application "Finder"
        activate
        delay 0.05
    end tell

    -- Send `Spotlight` keystroke.
    keystroke space using {command down}
end tell
EOF
