#!/bin/bash
set -e

update_system() {
    echo "Updating system..."
    sudo pacman -Syu --noconfirm
}

install_packages() {
    echo "Installing base packages..."
    sudo pacman -S --noconfirm --needed \
        base-devel libconfig dbus libev libx11 libxcb libxext libgl libegl libepoxy \
        meson ninja pcre2 pixman uthash xcb-util-image xcb-util-renderutil xorgproto \
        cmake libxft libimlib2 libxinerama libxcb-res xorg-xev xorg-xbacklight \
        alsa-utils ttf-dejavu ttf-font-awesome ttf-jetbrains-mono
}

install_extra_packages() {
    sudo pacman -S feh firefox python-pywal --noconfirm --needed
}

install_nerd_font() {
    echo "Installing Nerd Fonts..."
    sudo pacman -S --noconfirm --needed nerd-fonts

    echo "Rebuilding font cache..."
    fc-cache -fv || {
        echo "Failed to rebuild font cache"
        return 1
    }
}

clone_dwm() {
    echo "Creating directories for DWM, dmenu, and st..."
    mkdir -p "$HOME/.config/suckless/dwm" \
             "$HOME/.config/suckless/dmenu" \
             "$HOME/.config/suckless/st"

    echo "Cloning DWM repository..."
    if [ ! -d "$HOME/.config/suckless/dwm/.git" ]; then
        git clone https://github.com/umrian/dwm "$HOME/.config/suckless/dwm/"
    else
        echo "DWM repository already exists. Skipping clone."
    fi

    echo "Cloning dmenu repository..."
    if [ ! -d "$HOME/.config/suckless/dmenu/.git" ]; then
        git clone https://github.com/umrian/dmenu "$HOME/.config/suckless/dmenu/"
    else
        echo "dmenu repository already exists. Skipping clone."
    fi

    echo "Cloning st repository..."
    if [ ! -d "$HOME/.config/suckless/st/.git" ]; then
        git clone https://github.com/umrian/st "$HOME/.config/suckless/st/"
    else
        echo "st repository already exists. Skipping clone."
    fi

    cd "$HOME/.config/suckless/dwm/" || {
        echo "Failed to change directory to DWM. Exiting..."
        exit 1
    }
}


build_dwm() {
    echo "Building and installing DWM..."
    #echo "Building and installing DWM, dmenu, and st..."

    for app in dwm; do
    #for app in dwm dmenu st; do
        app_dir="$HOME/.config/suckless/$app"
        
        if [ -d "$app_dir" ]; then
            echo "Building and installing $app..."
            cd "$app_dir" || {
                echo "Failed to change directory to $app. Skipping..."
                continue
            }
            
            make && sudo make install || {
                echo "Failed to build/install $app. Skipping..."
                continue
            }
        else
            echo "Directory for $app not found. Skipping..."
        fi
    done

    echo "Adding DWM to .xinitrc..."
    if [ ! -f "$HOME/.xinitrc" ]; then
        echo "exec dwm" > "$HOME/.xinitrc"
    else
        echo "~/.xinitrc already exists. Please add 'exec dwm' manually."
    fi
}


install_picom() {
    echo "Setting up Picom..."
    mkdir -p ~/build
    if [ ! -d ~/build/picom ]; then
        if ! git clone https://github.com/FT-Labs/picom.git ~/build/picom; then
            echo "Failed to clone the Picom repository"
            return 1
        fi
    else
        echo "Picom repository already exists. Skipping clone."
    fi

    cd ~/build/picom || {
        echo "Failed to change directory to Picom. Exiting..."
        return 1
    }

    echo "Building Picom..."
    if ! meson setup --buildtype=release build; then
        echo "Meson setup failed"
        return 1
    fi

    if ! ninja -C build; then
        echo "Ninja build failed"
        return 1
    fi

    echo "Installing Picom..."
    if ! sudo ninja -C build install; then
        echo "Failed to install Picom"
        return 1
    fi

    echo "Picom installed successfully!"
}



update_system
install_packages
install_nerd_font
install_picom
#clone_dwm
build_dwm

echo "Done! You can now start DWM with the 'startx' command."
