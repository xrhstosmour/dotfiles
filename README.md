# Dotfiles Utilities

This repository configures system settings across `macOS` and `Arch Linux` via seamless shell scripts.

## Overview

- Copy dotfiles to `~/.config` and `.gitconfig` to the home directory.
- Detect operating system and automatically invoke `macOS` or Arch `Arch Linux` setup.

## `macOS` Configuration

- **Developer Tools**: Install `Xcode` Command Line Tools.
- **Package Management**: Install `Homebrew` and apply `Brewfile` packages.
- **Shell**: Switch default shell to `Fish` and add to `/etc/shells`.
- **`Finder`**: Apply tweaks (show path/status bar, hidden files, list view, disable `.DS_Store` on network/USB drives).
- **`Dock` & Menu Bar**: Configure layout (clear existing, add preferred apps, autohide, hide recents, show battery/volume/`Bluetooth` icons).
- **Keyboard Remapping**: Swaps (Control⇄Option/Command⇄Control), Globe→Command, Section Sign→Tilde, Right Shift→Delete, persisted via LaunchAgent.
- **`AeroSpace` Window Manager**: Dual keyboard support with:
  - Window navigation (H/J/K/L), movement, and resizing with consistent bindings.
  - Workspace switching and window-to-workspace movement (1-10).
  - Application shortcuts: Spotlight (A), Chrome (B), VS Code (E), Finder (F), Spotify (M), Obsidian (N), System Settings (S), Sublime Text (T), Terminal (Enter).
  - Input source switching (Space) and layout rotation (R).
  - Layout floating/tiling toggle (Option/Alt + Shift + F).
  - Service mode (; key) for configuration reload (L) and layout reset (R).
  - Dual bindings for internal (Alt) and external keyboards (Ctrl) to handle key remapping.
- **Display**: Adjust settings (hide the notch by stepping down resolution, cache original resolution).
- **Appearance**: Configure themes, wallpapers, dark mode.
- **Audio**: Configure sound settings.
- **Trackpad**: Configure gestures and click behavior.
- **`Bluetooth`**: Turn off when unneeded.
- **Screenshots**: Save to Desktop in PNG format.
- **Scrollbars**: Set always displayed.
- **System**: Disable Siri and password hints.
- **Clock**: Set 24-hour format and custom date format.
- **Security**: Enable firewall and stealth mode; whitelist file-sharing apps.
- **Monitoring**: Configure Activity Monitor and Login Items.
- **Default App Removal & Cleanup**: The following default `macOS` applications and their Library data are removed for a cleaner system:
  - `GarageBand`
  - `iMovie`
  - `Pages`
  - `Keynote`
  - `Books`
  - `Chess`
  - `Dictionary`
  - `Numbers`
  - `News`
  - `Podcasts`
  - `Stocks`
  - `TV`
  - `Music`

## `Arch Linux` Configuration

- **Package Management**: Install utilities and applications via `paru` from `packages/linux/*.txt`.
- **Power Management**: Disable `GNOME` sleep on AC power.
- **Clock**: Configure format, date, seconds display, and weekday.
- **Window Management**: Set button layout, disable hot corners, configure workspaces.
- **Theming**: Apply font, icon theme, wallpaper, and dark mode.
- **Input**: Load custom `GNOME` keybindings; configure keyboard layout and touchpad click method.
- **System Cleanup**: Remove unneeded `GNOME` packages.
- **Applications**: Set favorite apps, startup scripts, `GNOME` extensions; enable GDM service.

## ToDos

- Disable True Tone on `macOS`.
- Disable Automatically Adjust Brightness on `macOS`.
- Skip display changes if resolution is already non-default.
- Install and configure `sketchybar` on `macOS`.
- Configure desktop vs. server environment on `Arch Linux`.
- Integrate missing settings from the `arch-tuner` repository on `Arch Linux`.
- Replace `fzf` with `skim` in `Fish` functions (`git`, `trashy`).
- Helix editor installation may require manual fixes.

## Notes

- **`macOS` 15+ Permissions**: Grant Input Monitoring permission to `/usr/bin/hidutil` and `/usr/bin/sudo` via System Settings → Privacy & Security → Input Monitoring.
- **AeroSpace Permissions**: Scripts require Accessibility permissions via System Settings → Privacy & Security → Accessibility for `Spotlight` functionality to work properly.
- **Full Disk Access Required**: For system cleanup and quarantine removal, you must grant Full Disk Access to your Terminal (or script runner). Go to System Settings → Privacy & Security → Full Disk Access, add your Terminal app, and restart it before running this script. This is required for modifying protected files and attributes.
