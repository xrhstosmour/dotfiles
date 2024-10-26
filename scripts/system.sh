#!/bin/bash

# TODO: Move this to arch-tuner and check if bluetooth is available before doing anything.
# Enable and start bluetooth services.
sudo systemctl start bluetooth
sudo systemctl enable bluetooth

# Ensure AutoEnable is set to true in /etc/bluetooth/main.conf
if grep -q 'AutoEnable=' /etc/bluetooth/main.conf; then
    sudo sed -i 's/^#*AutoEnable=.*/AutoEnable=true/' /etc/bluetooth/main.conf
else
    sudo sed -i '/\[Policy\]/a AutoEnable=true' /etc/bluetooth/main.conf
fi

# Restart Bluetooth service to apply changes.
sudo systemctl restart bluetooth
