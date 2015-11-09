#!/bin/bash -eux
# TODO error handling etc would be nice
VBOX_VERSION=$(cat /home/vagrant/.vbox_version)
VBOX_GA_ISO=/home/vagrant/VBoxGuestAdditions_${VBOX_VERSION}.iso
mount -o loop ${VBOX_GA_ISO} /mnt
sh /mnt/VBoxLinuxAdditions.run
umount /mnt
