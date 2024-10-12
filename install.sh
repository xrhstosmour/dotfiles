#!/bin/bash

# Copy the needed desktop configuration files to the home directory.
cp -R .config/* ~/.config/

# Install the needed dependencies.
paru -S --noconfirm --needed - < dependencies.txt

# Enable and configure GNOME extensions.
sh scripts/extensions.sh

# Configure GNOME.
sh scripts/gnome.sh
