#!/bin/bash

prompt_for_input() {
    read -p "$1: " input
    echo "$input"
}

LOCALE="en_US.UTF-8"
echo "LANG=$LOCALE" > /etc/locale.conf

KEYMAP=$(prompt_for_input "Enter your keymap (e.g., us, de, fr, se)")

if [[ -z "$KEYMAP" ]]; then
    echo "Error: Keymap cannot be empty."
    exit 1
fi

echo "KEYMAP=$KEYMAP" > /etc/vconsole.conf

echo "Locale and keymap configuration completed."
