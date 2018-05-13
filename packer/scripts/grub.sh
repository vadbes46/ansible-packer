#!/usr/bin/env bash

# grub configuration.
sourceFile=/etc/default/grub
echo "grub configuration."
setterm -blank 0
sed -i 's/\\(^GRUB_TIMEOUT=\\).*/\\GRUB_TIMEOUT=0/g' "$sourceFile"
sed -ie 's/^GRUB_CMDLINE_LINUX=.*/GRUB_CMDLINE_LINUX=\"consoleblank=0\"/g' "$sourceFile"
grub2-mkconfig -o /boot/grub2/grub.cfg

# kbd configuration.
# sed -ie 's/#*BLANK_TIME=30/BLANK_TIME=0/g' /etc/kbd/config
# sed -ie 's/#*POWERDOWN_TIME=30/POWERDOWN_TIME=0/g' /etc/kbd/config
# sed -ie 's/#*LEDS.*/LEDS+=num/g' /etc/kbd/config

exit
