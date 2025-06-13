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
#
# ! IMPORTANT: On `macOS 15.0` and later you must head to `System Settings → Privacy & Security → Input Monitoring` and:
# !     - Grant permission to `/usr/bin/hidutil`.
# !     - Grant permission to `usr/bin/sudo`.
#
# More details:
#   - https://hidutil-generator.netlify.app/
#   - https://apple.stackexchange.com/questions/467341/hidutil-stopped-working-on-macos-14-2-update
#
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

    # Disable `Emoji` picker.
    log_info "Disabling 'Emoji' picker..."
    defaults write com.apple.HIToolbox AppleFnUsageType -int 0

    # Disable press & hold for accents.
    log_info "Disabling press & hold for accents..."
    defaults write -g ApplePressAndHoldEnabled -bool false

    # Clear all existing keyboard mappings first.
    keyboard_clear_all_mappings

    # Apply keyboard configurations.
    log_info "Configuring keybindings..."
    keyboard_configure_external_keyboards
    keyboard_configure_internal_keyboard

    log_success "Keyboard configuration applied successfully."
    log_divider
}

# Function to clear all existing keyboard mappings.
# Removes both per-keyboard defaults and `hidutil` mappings to start with a clean slate.
# Usage:
#   keyboard_clear_all_mappings
keyboard_clear_all_mappings() {
    log_info "Clearing all existing keyboard mappings..."

    # Clear all per-keyboard modifier mappings.
    for mapping_key in $(defaults -currentHost read -g 2>/dev/null | grep "com.apple.keyboard.modifiermapping" | cut -d '"' -f2); do
        defaults -currentHost delete -g "$mapping_key" 2>/dev/null || true
    done

    # Clear all `hidutil` mappings.
    log_info "Clearing 'hidutil' mappings..."
    /usr/bin/hidutil property --set '{"UserKeyMapping":[]}' >/dev/null 2>&1

    # Remove any existing launch agents.
    if [ -f ~/Library/LaunchAgents/com.local.KeyRemapping.plist ]; then
        log_info "Removing existing launch agent..."
        launchctl unload ~/Library/LaunchAgents/com.local.KeyRemapping.plist 2>/dev/null || true
        rm -f ~/Library/LaunchAgents/com.local.KeyRemapping.plist
    fi

    # Force reload of preferences.
    sudo killall -HUP cfprefsd 2>/dev/null || true

    log_success "All keyboard mappings cleared."
}

# Function to configure external keyboards.
# Applies Control ↔ Command swap only to external (non-Apple internal) keyboards.
# Usage:
#   keyboard_configure_external_keyboards
keyboard_configure_external_keyboards() {
    log_info "Configuring external keyboards (Control ↔ Command)..."

    # Detect all connected keyboards.
    local keyboard_temp_file="/tmp/keyboard_info_$$.txt"
    keyboard_detect_all_keyboards >"$keyboard_temp_file"

    local keyboard_modified_count=0
    local device_data=$(cat "$keyboard_temp_file")

    # Process Bluetooth keyboards.
    if [[ "$device_data" == *"Minor Type: Keyboard"* ]]; then
        # Extract vendor ID.
        local vendor_id=""
        local vendor_hex=$(echo "$device_data" | grep "Vendor ID:" | sed 's/.*0x//' | head -1)
        if [[ -n "$vendor_hex" ]]; then
            vendor_id=$((16#$vendor_hex))
        fi

        # Extract product ID.
        local product_id=""
        local product_hex=$(echo "$device_data" | grep "Product ID:" | sed 's/.*0x//' | head -1)
        if [[ -n "$product_hex" ]]; then
            product_id=$((16#$product_hex))
        fi

        # Extract product name.
        local product_name=""
        if [[ "$device_data" =~ Name:\ (.*) ]]; then
            product_name="${BASH_REMATCH[1]}"
        elif [[ "$device_data" =~ Bluetooth\ keyboard: ]]; then
            product_name="Bluetooth keyboard"
        fi

        # Apply mapping only to external keyboards.
        if [[ -n "$vendor_id" && -n "$product_id" ]]; then
            if ! keyboard_is_apple_internal_keyboard "$product_name"; then
                log_info "Applying Control ↔ Command to external keyboard: $product_name..."
                keyboard_apply_key_mapping "$vendor_id" "$product_id" "2" "4"
                keyboard_modified_count=$((keyboard_modified_count + 1))
            else
                log_info "Skipping internal keyboard: $product_name"
            fi
        fi
    fi

    # Clean up.
    rm -f "$keyboard_temp_file"

    if [ $keyboard_modified_count -eq 0 ]; then
        log_warning "No external keyboards detected."
    else
        log_success "External keyboards configured (Control ↔ Command)."
    fi
}

# Function to configure internal keyboard.
# Applies Option ↔ Control swap, Globe → Command, and Section Sign → Tilde mappings.
# Uses per-keyboard defaults for modifier keys and `hidutil` for special keys.
# Usage:
#   keyboard_configure_internal_keyboard
keyboard_configure_internal_keyboard() {
    log_info "Configuring internal keyboard (Option ↔ Control, Globe → Command, Section Sign → Tilde)..."

    # First, configure Option ↔ Control via per-keyboard mapping.
    local keyboard_ids=$(keyboard_detect_internal_keyboard)
    local keyboard_modified_count=0

    if [[ $? -eq 0 && -n "$keyboard_ids" ]]; then
        local vendor_id=$(echo "$keyboard_ids" | cut -d':' -f1)
        local product_id=$(echo "$keyboard_ids" | cut -d':' -f2)

        if [[ -n "$vendor_id" && -n "$product_id" ]]; then
            log_info "Applying Option ↔ Control to internal keyboard..."
            keyboard_apply_key_mapping "$vendor_id" "$product_id" "3" "2"
            keyboard_modified_count=$((keyboard_modified_count + 1))
        fi
    fi

    # Then, configure Globe → Command and Section Sign → Tilde via `hidutil`.
    log_info "Applying Globe → Command and Section Sign → Tilde mappings..."
    /usr/bin/hidutil property --set '{"UserKeyMapping":[
        {
          "HIDKeyboardModifierMappingSrc": 0xFF00000003,
          "HIDKeyboardModifierMappingDst": 0x7000000E3
        },
        {
          "HIDKeyboardModifierMappingSrc": 0x700000064,
          "HIDKeyboardModifierMappingDst": 0x700000035
        }
    ]}' >/dev/null 2>&1

    # Create launch agent for persistence.
    keyboard_create_launch_agent

    if [ $keyboard_modified_count -eq 0 ]; then
        log_warning "No internal keyboard detected for modifier key mapping."
    else
        log_success "Internal keyboard configured (Option ↔ Control, Globe → Command, Section Sign → Tilde)."
    fi
}

# Function to create launch agent for `hidutil` persistence.
# Creates a launch agent that will reapply `hidutil` mappings on system startup.
# Usage:
#   keyboard_create_launch_agent
keyboard_create_launch_agent() {
    log_info "Creating launch agent for 'hidutil' persistence..."

    # Create launch agent directory if it doesn't exist.
    mkdir -p ~/Library/LaunchAgents

    # Create the launch agent plist with the correct `hidutil` mappings.
    cat >~/Library/LaunchAgents/com.local.KeyRemapping.plist <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.local.KeyRemapping</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/bin/hidutil</string>
        <string>property</string>
        <string>--set</string>
        <string>{"UserKeyMapping":[
            {
              "HIDKeyboardModifierMappingSrc": 0xFF00000003,
              "HIDKeyboardModifierMappingDst": 0x7000000E3
            },
            {
              "HIDKeyboardModifierMappingSrc": 0x700000064,
              "HIDKeyboardModifierMappingDst": 0x700000035
            }
        ]}</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
EOF

    # Load the launch agent.
    launchctl load -w ~/Library/LaunchAgents/com.local.KeyRemapping.plist 2>/dev/null || true

    log_success "Launch agent created and loaded for 'hidutil' persistence."
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

    # Create the mapping using plutil for proper plist structure.
    # First create an empty array.
    defaults -currentHost write -g "$keyboard_mapping_key" -array

    # Add first mapping (source -> destination).
    defaults -currentHost write -g "$keyboard_mapping_key" -array-add \
        '<dict><key>HIDKeyboardModifierMappingDst</key><integer>'"$keyboard_destination_key"'</integer><key>HIDKeyboardModifierMappingSrc</key><integer>'"$keyboard_source_key"'</integer></dict>'

    # Add second mapping (destination -> source for bidirectional swap).
    defaults -currentHost write -g "$keyboard_mapping_key" -array-add \
        '<dict><key>HIDKeyboardModifierMappingDst</key><integer>'"$keyboard_source_key"'</integer><key>HIDKeyboardModifierMappingSrc</key><integer>'"$keyboard_destination_key"'</integer></dict>'

    # Force macOS to reload keyboard configuration.
    sudo killall -HUP cfprefsd 2>/dev/null || true

    return $?
}

# Function to detect the internal Apple keyboard.
# Uses system_profiler to detect the SPI-connected internal keyboard.
# Returns the vendor ID and product ID of the internal keyboard.
# Usage:
#   keyboard_detect_internal_keyboard
keyboard_detect_internal_keyboard() {
    # Use system_profiler to specifically target SPI devices (internal keyboard/trackpad).
    local spi_info=$(system_profiler SPSPIDataType 2>/dev/null)

    if [[ -n "$spi_info" && "$spi_info" == *"Apple Internal Keyboard"* ]]; then
        # Extract Product ID and Vendor ID.
        local product_id=$(echo "$spi_info" | grep "Product ID:" | head -1 | awk '{print $3}')
        local vendor_id=$(echo "$spi_info" | grep "Vendor ID:" | head -1 | awk '{print $3}')

        # Convert hex to decimal if needed.
        if [[ "$product_id" == 0x* ]]; then
            product_id=$(printf "%d" "$product_id")
        fi

        if [[ "$vendor_id" == 0x* ]]; then
            vendor_id=$(printf "%d" "$vendor_id")
        fi

        echo "$vendor_id:$product_id"
        return 0
    else
        return 1
    fi
}
