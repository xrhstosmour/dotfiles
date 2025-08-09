
#!/bin/bash

# Catch exit signal (`CTRL` + `C`) to terminate the whole script.
trap "exit" INT

# Terminate script on error.
set -e

# Function to print monitor information.
# Usage:
#   get_monitor_info
get_monitor_info() {
    aerospace list-monitors
}


# Function to get the number of connected displays.
# Usage:
#   get_display_count
get_display_count() {
    aerospace list-monitors | wc -l | tr -d ' '
}


# Function to check if `MacBook` built-in display is present.
# Returns `true` if found, `false` otherwise.
# Usage:
#   has_builtin_display
has_builtin_display() {
        # Built-in displays usually have names like "Built-in", "Color LCD", etc.
    if aerospace list-monitors | grep -qi "built-in\|color lcd\|liquid retina"; then
        echo "true"
    else
        echo "false"
    fi
}


# Function to distribute 10 workspaces evenly across all connected displays.
# If there is a remainder, it is assigned to the built-in display, if present,
# otherwise distributed round-robin to external displays.
#
# Usage:
#   configure_workspaces <display_count> <has_builtin>
configure_workspaces() {
    local total_displays=$1
    local has_builtin=$2

    if [ "$total_displays" -eq 0 ]; then
        return 1
    fi

    # Get monitor IDs.
    local monitor_ids=($(aerospace list-monitors | awk '{print $1}'))

    # Clean up any extra workspaces (keep only 1-10).
    for workspace in $(aerospace list-workspaces --all | grep -v '^[1-9]$\|^10$'); do
        if [[ "$workspace" =~ ^[0-9]+$ ]] && [ "$workspace" -gt 10 ]; then
            # Move to workspace to delete it if it has windows, or it will be auto-removed when empty.
            aerospace workspace "$workspace" 2>/dev/null || true
        fi
    done

    # Identify built-in monitor if present.
    local builtin_monitor=""
    local external_monitors=()

    if [ "$has_builtin" = "true" ]; then
        for monitor_id in "${monitor_ids[@]}"; do
            local monitor_name=$(aerospace list-monitors | grep "^$monitor_id " | cut -d'|' -f2 | tr -d ' ')
            if [[ "$monitor_name" =~ Built-in|Retina|LCD ]]; then
                builtin_monitor="$monitor_id"
            else
                external_monitors+=("$monitor_id")
            fi
        done
    else
    # All monitors are external when lid is closed.
        external_monitors=("${monitor_ids[@]}")
    fi

    # Calculate distribution and split 10 workspaces evenly, give remainder to built-in.
    local workspaces_per_display=$((10 / total_displays))
    local remainder=$((10 % total_displays))
    local workspace=1

    # Distribute to external monitors first.
    for monitor_id in "${external_monitors[@]}"; do
        for i in $(seq 1 $workspaces_per_display); do
            aerospace move-workspace-to-monitor --workspace "$workspace" "$monitor_id"
            workspace=$((workspace + 1))
        done
    done

    # Distribute to built-in monitor.
    if [ -n "$builtin_monitor" ]; then
        local builtin_count=$((workspaces_per_display + remainder))
        if [ "$builtin_count" -gt 0 ]; then
            for i in $(seq 1 $builtin_count); do
                aerospace move-workspace-to-monitor --workspace "$workspace" "$builtin_monitor"
                workspace=$((workspace + 1))
            done
        fi
    else
    # If no built-in, distribute remainder to external monitors.
        if [ "$remainder" -gt 0 ]; then
            for i in $(seq 1 $remainder); do
                local monitor_index=$(((i - 1) % ${#external_monitors[@]}))
                local monitor_id="${external_monitors[$monitor_index]}"
                aerospace move-workspace-to-monitor --workspace "$workspace" "$monitor_id"
                workspace=$((workspace + 1))
            done
        fi
    fi
}


# Main execution function.
# Prints current monitor setup, computes workspace distribution, and applies it.
# Usage:
#   main
main() {
    local display_count=$(get_display_count)
    local has_builtin=$(has_builtin_display)

    configure_workspaces "$display_count" "$has_builtin"
}

# Run if executed directly.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
