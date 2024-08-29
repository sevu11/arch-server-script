#!/bin/bash

MARKER_FILE="/etc/.locale_setup_done"

if [ -f "$MARKER_FILE" ]; then
    exit 0
fi

declare -A keymap_mapping=(
    [us]="us"
    [by]="by"
    [ca]="ca"
    [cf]="cf"
    [cz]="cz"
    [de]="de"
    [dk]="dk"
    [es]="es"
    [et]="et"
    [fa]="fa"
    [fi]="fi"
    [fr]="fr"
    [gr]="gr"
    [hu]="hu"
    [il]="il"
    [it]="it"
    [lt]="lt"
    [lv]="lv"
    [mk]="mk"
    [nl]="nl"
    [no]="no"
    [pl]="pl"
    [ro]="ro"
    [ru]="ru"
    [se]="se-lat6"
    [sg]="sg"
    [ua]="ua"
    [uk]="uk"
)

prompt_for_input() {
    read -p "$1: " input
    echo "$input"
}

user_input=$(prompt_for_input "Enter your keymap (e.g., us, de, fr)")

if [[ -n "${keymap_mapping[$user_input]}" ]]; then
    LOCALE="${keymap_mapping[$user_input]}"
    LANG="${keymap_mapping[$user_input]}.UTF-8"

    echo "Generating locale: $LANG"
    sed -i "/^#$LANG/s/^#//" /etc/locale.gen
    locale-gen

    echo "Setting locale to $LANG"
    echo "LANG=$LANG" > /etc/locale.conf

    export LANG=$LANG

    echo "Locale configuration completed."

    touch "$MARKER_FILE"
else
    echo "Invalid keymap: $user_input"
    exit 1
fi