# Arch Server Install Script

It's configured to my liking when I set up a new linux server, but some configurations are user prompts to make it more usable. 
it will install under 3 minutes and be ~200 packages. 

- [x] A minimal install script for a Arch Linux server setup. 
- [x] It will setup various HDD configuration (EXT4, BTRFS, LUKS)


## Install instructions

```
git clone https://github.com/sevu11/arch-server-script
cd arch-server-script/
chmod +x install.sh
./install.sh
```

![Install time](https://raw.githubusercontent.com/sevu11/arch-server-script/main/images/install.png)
*Installation time* 

![Total packages](https://raw.githubusercontent.com/sevu11/arch-server-script/main/images/fetch.png)
*Default fastfetch*


## Locale Defaults

By default it will keep default locale settings.
It's recommended to change these files (after install and rebooted).

**/etc/locale.conf:**
```
LANG=en_US.UTF-8
```

**/etc/vconsole.conf:**
```
KEYMAP=yourlocale_keymap
```
See [keymaps](https://github.com/sevu11/arch-server-script/blob/main/keymaps.txt) as a reference.

## Credit
- Orginal script I based this one, was from [Chris Titus](https://github.com/ChrisTitusTech/ArchTitus)

## Known issues
- Currently, the script doesn't seem to save the correct keymap regardless of user input from the install script. This is a minor issue and can be corrected post-installation (see above).

## To do
- [ ] Add a post installation script for dotfiles
- [ ] Add a post installation script for my personal DWM and Slstatus configs.
- [ ] Add combine post installation scripts which we'll curl into Linutil from [Chris Titus](https://github.com/ChrisTitusTech/linutil)

