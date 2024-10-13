#!/bin/bash

# Disable the GNOME sleep when in AC mode.
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'

# Set minimize, maximize, and close buttons to the right.
gsettings set org.gnome.desktop.wm.preferences button-layout ':minimize,maximize,close'

# Disable hot corners.
gsettings set org.gnome.desktop.interface enable-hot-corners false

# Configure workspaces.
gsettings set org.gnome.mutter dynamic-workspaces false
gsettings set org.gnome.desktop.wm.preferences num-workspaces 10
for i in {1..9} 10; do
    gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-$i "['<Alt>$i']"
    gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-$i "['<Alt><Shift>$i']"
done

# Remove not needed GNOME packages.
declare -a packages=(
    epiphany
    gnome-software
    gnome-contacts
    gnome-backgrounds
    gnome-maps
    gnome-weather
    gnome-photos
    gnome-music
    gnome-documents
    gnome-logs
    gnome-usage
    gnome-todo
    gnome-clocks
    gnome-calculator
    gnome-characters
    gnome-screenshot
    gnome-system-monitor
    gnome-text-editor
    gnome-terminal
    gnome-help
    gnome-document-scanner
    gnome-image-viewer
    gnome-font-viewer
)

for pkg in "${packages[@]}"; do
    if paru -Qi "$pkg" &> /dev/null; then
        paru -Rns --noconfirm "$pkg"
    fi
done

# Set wallpaper.
if [ ! -d ~/Pictures/Wallpapers ]; then
    mkdir -p ~/Pictures/Wallpapers
fi
cp -R Wallpapers/* ~/Pictures/Wallpapers/

gsettings set org.gnome.desktop.background picture-uri-dark file:///~/Pictures/Wallpapers/cloudy_abstract_island.png

# Configure keyboard layout.
gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us'), ('xkb', 'gr')]"
