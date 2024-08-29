#!/bin/bash

# Define the locale and keymap settings
LOCALE="en_US.UTF-8"
KEYMAP="se-lat6"

# Update /etc/locale.conf
echo "Updating /etc/locale.conf to set LANG=${LOCALE}..."
if [ -f /etc/locale.conf ]; then
    sed -i "s/^LANG=.*/LANG=${LOCALE}/" /etc/locale.conf
else
    echo "LANG=${LOCALE}" > /etc/locale.conf
fi

# Update /etc/vconsole.conf
echo "Updating /etc/vconsole.conf to set keymap=${KEYMAP}..."
if [ -f /etc/vconsole.conf ]; then
    sed -i "s/^KEYMAP=.*/KEYMAP=${KEYMAP}/" /etc/vconsole.conf
else
    echo "KEYMAP=${KEYMAP}" > /etc/vconsole.conf
fi

echo "Post-install script executed successfully."

# Remove the systemd service file after execution
rm -f /etc/systemd/system/post-install.service
