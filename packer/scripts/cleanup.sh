#!/usr/bin/env bash

# Clean up .vbox_version
echo "Cleaning up .vbox_version"
rm -f /home/vagrant/.vbox_version &>/dev/null

# Remove Ansible and its dependencies.
yum remove ansible -y &>/dev/null

# Zero out the free space to save space in the final image:
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY

# Add `sync` so Packer doesn't quit too early, before the large file is deleted.
sync

exit
