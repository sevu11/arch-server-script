# Arch Server Install Script

- [x] A minimal install script for a Arch Linux server setup. 
- [x] It will setup various HDD configuration (EXT4, BTRFS, LUKS)

By default it will keep default locale settings.
It's recommended to change these files.

**/etc/locale.conf:**
```
LANG=en_US.UTF-8
```

**/etc/vconsole.conf:**
```
KEYMAP=yourlocale_keymap
```
See `keymaps.txt` as a reference.

