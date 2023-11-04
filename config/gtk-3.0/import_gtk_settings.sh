#!/bin/sh

# Get the gtk configuration if exists and proceed the setup.
config="${XDG_CONFIG_HOME:-$HOME/.config}/gtk-3.0/settings.ini"
if [ ! -f "$config" ]; then exit 1; fi

# Get the gnome schema.
gnome_schema="org.gnome.desktop.interface"

# Get the gtk theme.
gtk_theme="$(grep 'gtk-theme-name' "$config" | sed 's/.*\s*=\s*//')"

# Get the icon theme.
icon_theme="$(grep 'gtk-icon-theme-name' "$config" | sed 's/.*\s*=\s*//')"

# Get the cursor theme.
cursor_theme="$(grep 'gtk-cursor-theme-name' "$config" | sed 's/.*\s*=\s*//')"

# Get the font name.
font_name="$(grep 'gtk-font-name' "$config" | sed 's/.*\s*=\s*//')"

# Set gtk_theme, icon_theme, cursor_theme and font_name at the gnome_schema
gsettings set "$gnome_schema" gtk-theme "$gtk_theme"
gsettings set "$gnome_schema" icon-theme "$icon_theme"
gsettings set "$gnome_schema" cursor-theme "$cursor_theme"
gsettings set "$gnome_schema" font-name "$font_name"
