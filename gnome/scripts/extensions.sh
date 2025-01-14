#!/bin/bash

# Install the needed extensions.
paru -S --noconfirm --needed - < gnome/packages/extensions.txt

# Enable GNOME extensions.
gnome-extensions enable dash-to-dock@micxgx.gmail.com
gnome-extensions enable blur-my-shell@aunetx
gnome-extensions enable appindicatorsupport@rgcjonas.gmail.com
gnome-extensions enable just-perfection-desktop@just-perfection

# Dock configuration.
gsettings set org.gnome.shell.extensions.dash-to-dock transparency-mode 'FIXED'
gsettings set org.gnome.shell.extensions.dash-to-dock background-opacity 0.5
gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'BOTTOM'
gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false
gsettings set org.gnome.shell.extensions.dash-to-dock disable-overview-on-startup true

# Blur configuration.
gsettings set org.gnome.shell.extensions.blur-my-shell brightness 0.5
