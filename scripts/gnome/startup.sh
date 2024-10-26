#!/bin/bash

# Ensure the autostart directory exists.
mkdir -p ~/.config/autostart

# Create Ulauncher autostart entry.
cat <<EOF > ~/.config/autostart/ulauncher.desktop
[Desktop Entry]
Name=Ulauncher
Comment=Application launcher for Linux
GenericName=Launcher
Categories=GNOME;GTK;Utility;
TryExec=/usr/bin/ulauncher
Exec=env GDK_BACKEND=x11 /usr/bin/ulauncher --hide-window --hide-window
Icon=ulauncher
Terminal=false
Type=Application
X-GNOME-Autostart-enabled=true
EOF

# Create Flameshot autostart entry.
cat <<EOF > ~/.config/autostart/org.flameshot.Flameshot.desktop
[Desktop Entry]
Name=Flameshot
GenericName=Screenshot tool
Comment=Powerful yet simple to use screenshot software.
Keywords=flameshot;screenshot;capture;shutter;
Exec=/usr/bin/flameshot
Icon=org.flameshot.Flameshot
Terminal=false
Type=Application
Categories=Graphics;
StartupNotify=false
StartupWMClass=flameshot
Actions=Configure;Capture;Launcher;
X-DBUS-StartupType=Unique
X-DBUS-ServiceName=org.flameshot.Flameshot
X-KDE-DBUS-Restricted-Interfaces=org.kde.kwin.Screenshot,org.kde.KWin.ScreenShot2
EOF

# Create Filen autostart entry.
cat <<EOF > ~/.config/autostart/filen-desktop.desktop
[Desktop Entry]
Name=Filen
Exec=/usr/bin/filen-desktop %F
Terminal=false
Type=Application
Icon=filen-desktop
StartupWMClass=Filen
X-AppImage-Version=2.0.22
Comment=Filen Desktop Client
Categories=Utility;
EOF
