#!/bin/bash -eux
yum -y update
yum -y install kernel-headers kernel-devel gcc make perl curl wget bzip2 dkms patch net-tools git
reboot
