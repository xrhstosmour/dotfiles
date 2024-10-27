#!/bin/bash

# Copy the needed desktop configuration files to the home directory.
cp -R .config/* ~/.config/

# Install the needed dependencies.
paru -S --noconfirm --needed - < packages/dependencies.txt

# Configure GNOME.
sh scripts/gnome.sh
