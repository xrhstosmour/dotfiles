#!/bin/bash

# Reload environment.
aerospace reload-config
aerospace flatten-workspace-tree
~/.config/scripts/utilities/macos/configure_workspaces.sh
sudo ~/.config/scripts/utilities/macos/keyboard.sh apply_keyboard_configuration
