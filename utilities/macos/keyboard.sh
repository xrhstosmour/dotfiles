#!/bin/bash
# Catch exit signal (`CTRL` + `C`) to terminate the whole script.
trap "exit" INT

# Terminate script on error.
set -e

# Constant variable of the scripts' working directory to use for relative paths.
KEYBOARD_SCRIPT_DIRECTORY=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# Import constant variables.
source "$KEYBOARD_SCRIPT_DIRECTORY/../../helpers/logs.sh"

# Function to apply Keyboard configuration.
# Usage:
#   apply_keyboard_configuration
apply_keyboard_configuration() {
    log_info "Applying Keyboard configuration..."

    # Enable full keyboard access for all controls.
    log_info "Enabling full keyboard access for all controls..."
    defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

    # Disable `Smart Quotes` when typing code.
    log_info "Disabling 'Smart Quotes' when typing code..."
    defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

    # Disable `Smart Dashes` when typing code.
    log_info "Disabling 'Smart Dashes' when typing code..."
    defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

    # Disable auto-correct.
    log_info "Disabling auto-correct..."
    defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

    # Disable press & hold for accents.
    log_info "Disabling press & hold for accents..."
    defaults write -g ApplePressAndHoldEnabled -bool false

    # Apply `CMD`-`CTRL` swap on external keyboards.
    log_info "Configuring keybindings..."
    keyboard_swap_command_control_on_external_keyboards

    log_success "Keyboard configuration applied successfully."
}

# Function to detect all keyboards connected to the system.
# Returns information about each keyboard including vendor ID, product ID, and product name.
# Usage:
#   keyboard_detect_all_keyboards
keyboard_detect_all_keyboards() {
    # Try multiple detection methods to ensure we find keyboards.

    # Check for USB keyboards.
    local usb_keyboard_data=$(system_profiler SPUSBDataType 2>/dev/null | grep -A 20 "Keyboard" | grep -E "Product ID|Vendor ID|Product Name" | sed 's/^ *//')

    # For Bluetooth, extract ONLY devices that have "Minor Type: Keyboard".
    local bt_keyboard_data=""
    local device_info=""
    local is_keyboard=false

    # Create a temporary file for Bluetooth data.
    local bt_temp_file="/tmp/bt_data_$$.txt"
    system_profiler SPBluetoothDataType 2>/dev/null | grep -E "Address:|Name:|Minor Type:|Vendor ID:|Product ID:" | sed 's/^ *//' >"$bt_temp_file"

    # Read the entire Bluetooth data and process it line by line.
    while IFS= read -r line; do
        # Start of a new device.
        if [[ $line == *"Address:"* ]]; then
            # If previous device was a keyboard, add its info.
            if [[ "$is_keyboard" == "true" && -n "$device_info" ]]; then
                if [[ -n "$bt_keyboard_data" ]]; then
                    bt_keyboard_data+=$'\n'
                fi
                bt_keyboard_data+="$device_info"
            fi

            # Reset for new device.
            device_info="$line"
            is_keyboard=false
        elif [[ $line == *"Minor Type: Keyboard"* ]]; then
            is_keyboard=true
            device_info+=$'\n'"$line"
        elif [[ -n "$device_info" ]]; then
            # Add other relevant info for the current device.
            if [[ $line == *"Name:"* || $line == *"Vendor ID:"* || $line == *"Product ID:"* ]]; then
                device_info+=$'\n'"$line"
            fi
        fi
    done <"$bt_temp_file"

    # Clean up temporary file.
    rm -f "$bt_temp_file"

    # Add the last device if it's a keyboard.
    if [[ "$is_keyboard" == "true" && -n "$device_info" ]]; then
        if [[ -n "$bt_keyboard_data" ]]; then
            bt_keyboard_data+=$'\n'
        fi
        bt_keyboard_data+="$device_info"
    fi

    # Combine the data.
    local keyboard_data="$usb_keyboard_data"
    if [ -n "$bt_keyboard_data" ]; then
        if [ -n "$keyboard_data" ]; then
            keyboard_data="$keyboard_data"$'\n'"$bt_keyboard_data"
        else
            keyboard_data="$bt_keyboard_data"
        fi
    fi

    # If still no results, fall back to `IOKit` registry search.
    if [ -z "$keyboard_data" ]; then
        # Method 2: `IOKit` registry for keyboard devices.
        keyboard_data=$(ioreg -c IOHIDKeyboard -r | grep -e '"VendorID"' -e '"ProductID"' -e '"Product"')
    fi

    # Last resort - get any input devices.
    if [ -z "$keyboard_data" ]; then
        keyboard_data=$(ioreg -c IOHIDDevice -r | grep -e "VendorID" -e "ProductID" -e "Product" | grep -v "Apple Internal")
    fi

    echo "$keyboard_data"
}

# Function to determine if a keyboard is an Apple internal keyboard based on its product name.
# Returns true (0) if it's an Apple internal keyboard, false (1) otherwise.
# Usage:
#   keyboard_is_apple_internal_keyboard "Keyboard Product Name"
#   if keyboard_is_apple_internal_keyboard "$keyboard_product_name"; then
#     echo "This is an Apple internal keyboard"
#   fi
keyboard_is_apple_internal_keyboard() {
    local keyboard_product_name="$1"
    [[ "$keyboard_product_name" == *"Apple Internal Keyboard"* ||
        "$keyboard_product_name" == *"Apple keyboard"* ||
        "$keyboard_product_name" == *"Built-in"* ||
        "$keyboard_product_name" == *"MacBook"* ]]
}

# Function to apply key mapping to a specific keyboard.
# Maps one key to another and vice versa.
# Usage:
#   keyboard_apply_key_mapping "1452" "579" "2" "4"
#
# @param keyboard_vendor_id [String] The vendor ID of the keyboard.
# @param keyboard_product_id [String] The product ID of the keyboard.
# @param keyboard_source_key [String] The source key code to map from.
# @param keyboard_destination_key [String] The destination key code to map to.
#
# Key codes:
#   -1 = None (Disable the key)
#    0 = Caps Lock
#    1 = Shift (Left)
#    2 = Control (Left)
#    3 = Option (Left)
#    4 = Command (Left)
#    5 = Keypad 0
#    6 = Help
#    9 = Shift (Right)
#   10 = Control (Right)
#   11 = Option (Right)
#   12 = Command (Right)
keyboard_apply_key_mapping() {
    local keyboard_vendor_id="$1"
    local keyboard_product_id="$2"
    local keyboard_source_key="$3"
    local keyboard_destination_key="$4"

    # Format the key exactly as macOS expects it.
    local keyboard_mapping_key="com.apple.keyboard.modifiermapping.${keyboard_vendor_id}-${keyboard_product_id}-0"

    # Force clear any existing mappings.
    defaults -currentHost delete -g "$keyboard_mapping_key" 2>/dev/null || true

    # Apply new mapping - exact format that matches macOS internal structure.
    defaults -currentHost write -g "$keyboard_mapping_key" -array \
        '<dict>
            <key>HIDKeyboardModifierMappingDst</key>
            <integer>'$keyboard_destination_key'</integer>
            <key>HIDKeyboardModifierMappingSrc</key>
            <integer>'$keyboard_source_key'</integer>
        </dict>
        <dict>
            <key>HIDKeyboardModifierMappingDst</key>
            <integer>'$keyboard_source_key'</integer>
            <key>HIDKeyboardModifierMappingSrc</key>
            <integer>'$keyboard_destination_key'</integer>
        </dict>'

    # Force macOS to reload keyboard configuration.
    sudo killall -HUP cfprefsd 2>/dev/null || true

    # For keyboard changes, also try killing and restarting the keyboard service.
    sudo pkill -f "keyboard" 2>/dev/null || true

    return $?
}

# Function to swap `Command` and `Control` keys on all external keyboards.
# Detects all connected keyboards, identifies which are external (non-Apple),
# and applies the swap to those keyboards only.
# Usage:
#   keyboard_swap_command_control_on_external_keyboards
keyboard_swap_command_control_on_external_keyboards() {
    log_info "Swapping 'Command' and 'Control' keys on external keyboards..."

    # Create temp file for keyboard info.
    local keyboard_temp_file="/tmp/keyboard_info_$$.txt"
    keyboard_detect_all_keyboards >"$keyboard_temp_file"

    # Simplified approach: Look for complete sets of keyboard information.
    local keyboard_modified_count=0
    local device_data=$(cat "$keyboard_temp_file")

    # Check if the data contains a keyboard marker.
    if [[ "$device_data" == *"Minor Type: Keyboard"* ]]; then
        # Extract the vendor ID.
        local vendor_id=""
        if [[ "$device_data" =~ Vendor\ ID:\ 0x([0-9A-F]+) ]]; then
            vendor_id=$((16#${BASH_REMATCH[1]}))
        fi

        # Extract the product ID.
        local product_id=""
        if [[ "$device_data" =~ Product\ ID:\ 0x([0-9A-F]+) ]]; then
            product_id=$((16#${BASH_REMATCH[1]}))
        fi

        # Extract the name if available.
        local product_name=""
        if [[ "$device_data" =~ Name:\ (.*) ]]; then
            product_name="${BASH_REMATCH[1]}"
        fi

        # If we have both IDs, process the keyboard.
        if [[ -n "$vendor_id" && -n "$product_id" ]]; then
            if ! keyboard_is_apple_internal_keyboard "$product_name"; then
                keyboard_apply_key_mapping "$vendor_id" "$product_id" "2" "4"
                keyboard_modified_count=$((keyboard_modified_count + 1))
            fi
        fi

    fi

    # Clean up.
    rm -f "$keyboard_temp_file"

    if [ $keyboard_modified_count -eq 0 ]; then
        log_warning "No external keyboards detected for keybinding configuration."
    fi

    log_success "'Command' and 'Control' keys swapped successfully on external keyboards."
}
