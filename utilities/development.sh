#!/bin/bash

# Catch exit signal (CTRL + C), to terminate the whole script.
trap "exit" INT

# Terminate script on error.
set -e

# Constant variable of the scripts' working directory to use for relative paths.
DEVELOPMENT_SCRIPT_DIRECTORY=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# List of available programming languages, their display names and installation names.
LANGUAGE_DISPLAY_NAMES=(
    ".NET Core"
    "Go"
    "Java"
    "Node.js"
    "Python"
    "Ruby"
)

LANGUAGE_NAMES=(
    "dotnet"
    "go"
    "java"
    "node"
    "python"
    "ruby"
)


# Import functions and flags.
source "$DEVELOPMENT_SCRIPT_DIRECTORY/../helpers/ui.sh"

log_info "Installing programming languages..."

# Iterate over the available languages and ask the user to install them.
for i in "${!LANGUAGE_DISPLAY_NAMES[@]}"; do
    display_name="${LANGUAGE_DISPLAY_NAMES[$i]}"
    mise_name="${LANGUAGE_NAMES[$i]}"
    command="mise use --global $mise_name@latest"

    # Check if the language is already installed, before proceeding.
    if mise ls -i "$mise_name" 2>/dev/null | grep -q .; then
        continue
    fi

    message="Do you want to install $display_name?"
    user_answer=$(ask_user_before_execution "$message" "true" "$command")
    if [ "$user_answer" = "y" ]; then
        log_success "$display_name installation finished!"
    fi
done

log_divider
