# Arch Server Install Script

It's configured to my liking when I set up a new linux server, but some configurations are user prompts to make it more usable. 

- [x] A minimal install script for a Arch Linux server setup. 
- [x] It will setup various HDD configuration (EXT4, BTRFS, LUKS)

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

