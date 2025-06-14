#!/bin/bash

# Catch exit signal (`CTRL` + `C`) to terminate the whole script.
trap "exit" INT

# Terminate script on error.
set -e

# TODO: Configure either desktop or server.
# TODO: Add missing configuration from the `arch-tuner` repository.

# Install the needed utilities.
paru -S --noconfirm --needed - <packages/linux/utilities.txt

# Install the applications.
paru -S --noconfirm --needed - <packages/linux/applications.txt

# Disable the GNOME sleep when in AC mode.
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'

# Configure clock.
gsettings set org.gnome.desktop.interface clock-format '24h'
gsettings set org.gnome.desktop.interface clock-show-date false
gsettings set org.gnome.desktop.interface clock-show-seconds false
gsettings set org.gnome.desktop.interface clock-show-weekday false

# Set minimize, maximize, and close buttons to the right.
gsettings set org.gnome.desktop.wm.preferences button-layout ':minimize,maximize,close'

# Disable hot corners.
gsettings set org.gnome.desktop.interface enable-hot-corners false

# Configure workspaces.
gsettings set org.gnome.mutter dynamic-workspaces false
gsettings set org.gnome.desktop.wm.preferences num-workspaces 10

# Configure Font.
gsettings set org.gnome.desktop.interface font-name 'Fira Code Nerd 12'

# Configure Icons.
gsettings set org.gnome.desktop.interface icon-theme 'MoreWaita'

# Configure keybindings.
# ? Export commands:
# ? dconf dump /org/gnome/settings-daemon/plugins/media-keys/ > linux/keybindings/custom.conf
# ? dconf dump /org/gnome/desktop/wm/keybindings/ > linux/keybindings/window_manager.conf
cat linux/keybindings/custom.conf | dconf load /org/gnome/settings-daemon/plugins/media-keys/
cat linux/keybindings/windows_manager.conf | dconf load /org/gnome/desktop/wm/keybindings/

# Remove not needed GNOME packages.
declare -a packages=(
    epiphany
    vim
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
    gnome-console
    gnome-help
    gnome-document-scanner
    gnome-image-viewer
    gnome-font-viewer
)

for package in "${packages[@]}"; do
    if paru -Qi "$package" &>/dev/null; then
        paru -Rns --noconfirm "$package"
    fi
done

# Set wallpaper.
if [ ! -d ~/Pictures/Wallpapers ]; then
    mkdir -p ~/Pictures/Wallpapers
fi
cp -R Wallpapers/* ~/Pictures/Wallpapers/

gsettings set org.gnome.desktop.background picture-uri "file://$HOME/Pictures/Wallpapers/cloudy_abstract_island.png"
gsettings set org.gnome.desktop.background picture-uri-dark "file://$HOME/Pictures/Wallpapers/cloudy_abstract_island.png"

# Set dark style.
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

# Configure keyboard layout.
gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us'), ('xkb', 'gr')]"

# Set up touchpad to enable right-click functionality.
gsettings set org.gnome.desktop.peripherals.touchpad click-method areas

# Configure favorite applications.
gsettings set org.gnome.shell favorite-apps "[]"
gsettings set org.gnome.shell favorite-apps "[
    'google-chrome.desktop',
    'cromite.desktop',
    'org.gnome.Nautilus.desktop',
    'org.wezfurlong.wezterm.desktop',
    'code.desktop',
    'signal-desktop.desktop',
    'com.viber.Viber.desktop',
    'org.mozilla.Thunderbird.desktop',
    'spotify.desktop',
    'io.missioncenter.MissionCenter.desktop',
    'org.gnome.Settings.desktop'
]"

# Configure startup applications.
sh linux/scripts/startup.sh

# Configure `GNOME` extensions.
sh linux/scripts/extensions.sh

# Enable `gdm` service.
sudo systemctl enable gdm
