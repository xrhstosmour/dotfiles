#!/bin/bash

# Copy the needed desktop configuration files to the home directory.
cp -R .config/* ~/.config/

# TODO: Make the installation OS agnostic.
# Install the needed dependencies.
paru -S --noconfirm --needed - < packages/dependencies.txt

# Install the applications.
paru -S --noconfirm --needed - < packages/applications.txt

# Configure GNOME.
sh gnome/install.sh
