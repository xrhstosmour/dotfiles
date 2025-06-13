#!/bin/bash
# Catch exit signal (`CTRL` + `C`) to terminate the whole script.
trap "exit" INT

# Terminate script on error.
set -e

# Constant variable of the scripts' working directory to use for relative paths.
DISPLAY_SCRIPT_DIRECTORY=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# Import constant variables.
source "$DISPLAY_SCRIPT_DIRECTORY/../../helpers/logs.sh"

# Function to apply Display configuration.
# Usage:
#   apply_display_configuration
apply_display_configuration() {
    log_info "Applying Display configuration..."

    # TODO: Disable `True Tone`.

    # TODO: Disable `Automatically adjust brightness`.

    # TODO: Do not change the display resolution if it is already set to a non default one.
    # Change display resolution to hide the notch.
    display_id=$(displayplacer list | grep -B 3 "Type: MacBook built in screen" | head -1 | sed 's/Persistent screen id: //')
    if [ -z "$display_id" ]; then
        log_warning "Built-in display not detected or disabled."
    else
        current_mode_number=$(displayplacer list | grep "$display_id" -A 10 | grep "<-- current mode" | grep -o "mode [0-9]*:" | grep -o "[0-9]*" | head -1)
        previous_mode_number=$((current_mode_number - 1))
        previous_mode_info=$(displayplacer list | grep "$display_id" -A 10 | grep -E "mode $previous_mode_number:")
        previous_resolution=$(echo "$previous_mode_info" | awk '{print $3}' | cut -d':' -f2)
        previous_hz=$(echo "$previous_mode_info" | awk '{print $4}' | cut -d':' -f2)
        previous_color_depth=$(echo "$previous_mode_info" | awk '{print $5}' | cut -d':' -f2)
        log_info "Hiding 'Notch' via changing display resolution..."
        displayplacer "id:$display_id res:$previous_resolution hz:$previous_hz color_depth:$previous_color_depth scaling:on origin:(0,0) degree:0"
    fi

    log_success "Display configuration applied successfully."
    log_divider
}
