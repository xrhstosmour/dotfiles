# Function to disable audio for all existing `Android` emulators.
# Usage:
#   disable_android_emulators_audio
function disable_android_emulators_audio
    for line in (find ~/.android/avd -name "config.ini")
        grep -v "^audio" "$line" > /tmp/android_config_tmp
        and mv /tmp/android_config_tmp "$line"
        and echo "hw.audioInput = no" >> "$line"
        and echo "hw.audioOutput = no" >> "$line"
    end
end
