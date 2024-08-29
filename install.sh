#!/bin/bash

# Redirect stdout and stderr to archsetup.txt and still output to console
exec > >(tee -i archsetup.txt)
exec 2>&1

echo -ne "
-------------------------------------------------------------------------
 █████╗ ██████╗  ██████╗██╗  ██╗████████╗██╗████████╗██╗   ██╗███████╗
██╔══██╗██╔══██╗██╔════╝██║  ██║╚══██╔══╝██║╚══██╔══╝██║   ██║██╔════╝
███████║██████╔╝██║     ███████║   ██║   ██║   ██║   ██║   ██║███████╗
██╔══██║██╔══██╗██║     ██╔══██║   ██║   ██║   ██║   ██║   ██║╚════██║
██║  ██║██║  ██║╚██████╗██║  ██║   ██║   ██║   ██║   ╚██████╔╝███████║
╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝   ╚═╝   ╚═╝   ╚═╝    ╚═════╝ ╚══════╝
-------------------------------------------------------------------------
                    Automated Arch Linux Installer
-------------------------------------------------------------------------

Verifying Arch Linux ISO is Booted

"
if [ ! -f /usr/bin/pacstrap ]; then
    echo "This script must be run from an Arch Linux ISO environment."
    exit 1
fi

root_check() {
    if [[ "$(id -u)" != "0" ]]; then
        echo -ne "ERROR! This script must be run under the 'root' user!\n"
        exit 1
    fi
}

docker_check() {
    if awk -F/ '$2 == "docker"' /proc/self/cgroup | read -r; then
        echo -ne "ERROR! Docker container is not supported (at the moment)\n"
        exit 1
    elif [[ -f /.dockerenv ]]; then
        echo -ne "ERROR! Docker container is not supported (at the moment)\n"
        exit 1
    fi
}

arch_check() {
    if [[ ! -e /etc/arch-release ]]; then
        echo -ne "ERROR! This script must be run in Arch Linux!\n"
        exit 1
    fi
}

pacman_check() {
    if [[ -f /var/lib/pacman/db.lck ]]; then
        echo "ERROR! Pacman is blocked."
        echo -ne "If not running, remove /var/lib/pacman/db.lck.\n"
        exit 1
    fi
}

background_checks() {
    root_check
    arch_check
    pacman_check
    docker_check
}

select_option() {
    local options=("$@")
    local num_options=${#options[@]}
    local selected=0
    local last_selected=-1

    while true; do
        # Move cursor up to the start of the menu
        if [ $last_selected -ne -1 ]; then
            echo -ne "\033[${num_options}A"
        fi

        if [ $last_selected -eq -1 ]; then
            echo "Please select an option using the arrow keys and Enter:"
        fi
        for i in "${!options[@]}"; do
            if [ $i -eq $selected ]; then
                echo "> ${options[$i]}"
            else
                echo "  ${options[$i]}"
            fi
        done

        last_selected=$selected

        # Read user input
        read -rsn1 key
        case $key in
            $'\x1b') # ESC sequence
                read -rsn2 -t 0.1 key
                case $key in
                    '[A') # Up arrow
                        ((selected--))
                        if [ $selected -lt 0 ]; then
                            selected=$((num_options - 1))
                        fi
                        ;;
                    '[B') # Down arrow
                        ((selected++))
                        if [ $selected -ge $num_options ]; then
                            selected=0
                        fi
                        ;;
                esac
                ;;
            '') # Enter key
                break
                ;;
        esac
    done

    return $selected
}

logo() {
    # Display logo
    echo -ne "
-------------------------------------------------------------------------
 █████╗ ██████╗  ██████╗██╗  ██╗████████╗██╗████████╗██╗   ██╗███████╗
██╔══██╗██╔══██╗██╔════╝██║  ██║╚══██╔══╝██║╚══██╔══╝██║   ██║██╔════╝
███████║██████╔╝██║     ███████║   ██║   ██║   ██║   ██║   ██║███████╗
██╔══██║██╔══██╗██║     ██╔══██║   ██║   ██║   ██║   ██║   ██║╚════██║
██║  ██║██║  ██║╚██████╗██║  ██║   ██║   ██║   ██║   ╚██████╔╝███████║
╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝   ╚═╝   ╚═╝   ╚═╝    ╚═════╝ ╚══════╝
------------------------------------------------------------------------
            Please select presetup settings for your system              
------------------------------------------------------------------------
"
}

filesystem() {
    echo -ne "Please Select your file system for both boot and root\n"
    options=("btrfs" "ext4" "luks" "exit")
    select_option "${options[@]}"

    case $? in
    0) export FS=btrfs;;
    1) export FS=ext4;;
    2) 
        set_password "LUKS_PASSWORD"
        export FS=luks
        ;;
    3) exit ;;
    *) echo "Wrong option. Please select again"; filesystem;;
    esac
}

timezone() {
    time_zone="$(curl --fail https://ipapi.co/timezone)"
    echo -ne "System detected your timezone to be '$time_zone'\n"
    echo -ne "Is this correct?\n" 
    options=("Yes" "No")
    select_option "${options[@]}"

    case ${options[$?]} in
        y|Y|yes|Yes|YES)
        echo "${time_zone} set as timezone"
        export TIMEZONE=$time_zone;;
        n|N|no|NO|No)
        echo "Please enter your desired timezone e.g. Europe/London :" 
        read new_timezone
        echo "${new_timezone} set as timezone"
        export TIMEZONE=$new_timezone;;
        *) echo "Wrong option. Try again"; timezone;;
    esac
}

keymap() {
    echo -ne "Please select your keyboard layout from this list:\n"
    options=("us" "se" "by" "ca" "cf" "cz" "de" "dk" "es" "et" "fa" "fi" "fr" "gr" "hu" "il" "it" "lt" "lv" "mk" "nl" "no" "pl" "ro" "ru" "sg" "ua" "uk")
    select_option "${options[@]}"

    selected_layout=${options[$?]}
    echo -ne "You selected: ${selected_layout}\n"

    # Mapping from user-friendly names to actual keymap file names
    declare -A keymap_mapping=(
        [us]="us"
        [se]="se-lat6"
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
        [sg]="sg"
        [ua]="ua"
        [uk]="uk"
    )

    # Use the mapping to get the correct keymap name
    keymap_file="${keymap_mapping[$selected_layout]}"

    if [[ -z "$keymap_file" ]]; then
        echo -ne "Selected layout is not supported.\n"
        return 1
    fi

    echo -ne "Setting keymap to: ${keymap_file}\n"
    export KEYMAP=$keymap_file
}


drivessd() {
    echo -ne "Is this an SSD? yes/no:\n"
    options=("Yes" "No")
    select_option "${options[@]}"

    case ${options[$?]} in
        y|Y|yes|Yes|YES)
        export MOUNT_OPTIONS="noatime,compress=zstd,ssd,commit=120";;
        n|N|no|NO|No)
        export MOUNT_OPTIONS="noatime,compress=zstd,commit=120";;
        *) echo "Wrong option. Try again"; drivessd;;
    esac
}

diskpart() {
    echo -ne "
-------------------------------------------------------------------------
    THIS WILL FORMAT AND DELETE ALL DATA ON THE DISK
    Please make sure you know what you are doing because
    after formatting your disk there is no way to get data back
    *****BACKUP YOUR DATA BEFORE CONTINUING*****
    ***I AM NOT RESPONSIBLE FOR ANY DATA LOSS***
-------------------------------------------------------------------------
"

    PS3='Select the disk to install on: '
    options=($(lsblk -n --output TYPE,KNAME,SIZE | awk '$1=="disk"{print "/dev/"$2"|"$3}'))

    select_option "${options[@]}"
    disk=${options[$?]%|*}

    echo -e "\n${disk%|*} selected\n"
    export DISK=${disk%|*}

    drivessd
}

userinfo() {
    while true; do 
        read -p "Please enter username: " username
        if [[ "${username,,}" =~ ^[a-z_]([a-z0-9_-]{0,31}|[a-z0-9_-]{0,30}\$)$ ]]; then 
            break
        fi 
        echo "Incorrect username."
    done 
    export USERNAME=$username

    while true; do
        read -rs -p "Please enter password: " password
        echo
        read -rs -p "Confirm password: " password_confirm
        echo
        if [[ "$password" == "$password_confirm" ]]; then
            break
        else
            echo "Passwords do not match. Please try again."
        fi
    done
    export PASSWORD=$password
}

set_password() {
    local var_name="$1"
    local password

    while true; do
        read -rs -p "Please enter password for LUKS encryption: " password
        echo
        read -rs -p "Confirm password: " password_confirm
        echo
        if [[ "$password" == "$password_confirm" ]]; then
            export "$var_name"="$password"
            break
        else
            echo "Passwords do not match. Please try again."
        fi
    done
}

install_base() {
    echo -ne "
-------------------------------------------------------------------------
                      Install Base System
-------------------------------------------------------------------------
"
    pacstrap /mnt base base-devel linux linux-firmware
    genfstab -U /mnt >> /mnt/etc/fstab
}

configure_chroot() {
    arch-chroot /mnt /bin/bash <<EOF
# Set up locale and timezone
echo -ne "
-------------------------------------------------------------------------
                    Setting up locale and timezone
-------------------------------------------------------------------------
"
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
ln -sf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime
hwclock --systohc

# Set up keymap and font
echo -ne "
-------------------------------------------------------------------------
                    Setting up console keymap and font
-------------------------------------------------------------------------
"
echo "KEYMAP=${KEYMAP}" > /etc/vconsole.conf
echo "FONT=ter-v18b" >> /etc/vconsole.conf

# Set root password
echo "root:${PASSWORD}" | chpasswd

# Create a new user
useradd -m -G wheel ${USERNAME}
echo "${USERNAME}:${PASSWORD}" | chpasswd

# Allow members of the wheel group to use sudo without a password
sed -i 's/^# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers
EOF
}

setup_bootloader() {
    echo -ne "
-------------------------------------------------------------------------
                      Installing Bootloader
-------------------------------------------------------------------------
"
    arch-chroot /mnt /bin/bash <<EOF
# Install bootloader
pacman -S --noconfirm grub
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=grub --recheck
grub-mkconfig -o /boot/grub/grub.cfg
EOF
}

finish_installation() {
    echo -ne "
-------------------------------------------------------------------------
                      Finalizing Installation
-------------------------------------------------------------------------
"
    umount -R /mnt
    echo -ne "
-------------------------------------------------------------------------
Installation complete! You can now reboot into your new system.
-------------------------------------------------------------------------
"
}

# Execution flow
background_checks
logo
filesystem
timezone
keymap
diskpart
userinfo
install_base
configure_chroot
setup_bootloader
finish_installation
