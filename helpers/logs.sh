#!/bin/bash

# Constant variable of the scripts' working directory to use for relative paths.
LOGS_SCRIPT_DIRECTORY=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# Import constant variables.
source "$LOGS_SCRIPT_DIRECTORY/../core/constants.sh"

# Function to log an info message using printf.
# Usage:
#   log_info "Info message to log"
#   log_info -n "Info message to log without newline"
log_info() {
  local prefix="\n" # Add leading newline by default
  if [[ "$1" == "-n" ]]; then
    prefix="" # Suppress leading newline if -n
    shift
  fi
  local info="$1"
  # Add prefix before color, always add trailing newline with \n in format string
  printf "${prefix}${BOLD_CYAN}%s${NO_COLOR}\n" "$info" >&2
}

# Function to log a success message using printf.
# Usage:
#   log_success "Success message to log"
#   log_success -n "Success message to log without newline"
log_success() {
  local prefix="\n"
  if [[ "$1" == "-n" ]]; then
    prefix=""
    shift
  fi
  local success="$1"
  printf "${prefix}${BOLD_GREEN}%s${NO_COLOR}\n" "$success" >&2
}

# Function to log a warning message using printf.
# Usage:
#   log_warning "Warning message to log"
#   log_warning -n "Warning message to log without newline"
log_warning() {
  local prefix="\n"
  if [[ "$1" == "-n" ]]; then
    prefix=""
    shift
  fi
  local warning="$1"
  printf "${prefix}${BOLD_YELLOW}%s${NO_COLOR}\n" "$warning" >&2
}

# Function to log an error message using printf.
# Usage:
#   log_error "Error message to log"
#   log_error -n "Error message to log without newline"
log_error() {
  local prefix="\n"
  if [[ "$1" == "-n" ]]; then
    prefix=""
    shift
  fi
  local error="$1"
  printf "${prefix}${BOLD_RED}%s${NO_COLOR}\n" "$error" >&2
}
