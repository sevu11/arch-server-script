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

If you wish to change your keyboard layout (i.e keymap) you can edit the following file:

**/etc/vconsole.conf:**
```
KEYMAP=yourlocale_keymap
```
See [keymaps](https://github.com/sevu11/arch-server-script/blob/main/keymaps.txt) as a reference.

## Credit
- Orginal script I based this one, was from [Chris Titus](https://github.com/ChrisTitusTech/ArchTitus)
