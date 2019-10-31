#!/bin/sh -e

DISK=/dev/sda
MOUNTPOINT=/mnt/nixos

mkdir -p $MOUNTPOINT

# Setup partition layout
# Swap should be >RAM size if you're going to use hibernate
wipefs --all --force ${DISK}
parted ${DISK} -- mklabel gpt
parted ${DISK} -- mkpart ESP fat32 1MiB 512MiB  # boot
parted ${DISK} -- set 1 boot on
parted ${DISK} -- mkpart primary 512MiB -1GiB  # root
parted ${DISK} -- mkpart primary linux-swap -1GiB 100%  # swap

# Generate root private key file
if [ ! -f cryptroot.key ]; then
  dd if=/dev/urandom of=cryptroot.key bs=1 count=4096
  chmod 0400 cryptroot.key
fi

# Encrypt the partitions
# Swap partition is also encrypted, so our hibernate state is encrypted.
cryptsetup luksFormat ${DISK}2  # Enter password
cryptsetup luksFormat ${DISK}3  # Enter the same password
cryptsetup luksAddKey ${DISK}2 cryptroot.key
cryptsetup luksAddKey ${DISK}3 cryptroot.key

# Open the encrypted partitions
cryptsetup open -d cryptroot.key ${DISK}2 cryptroot
cryptsetup open -d cryptroot.key ${DISK}3 cryptswap

# Format the underlying partitions
mkfs.fat -F 32 -n efi ${DISK}1
mkswap /dev/mapper/cryptswap
mkfs.btrfs /dev/mapper/cryptroot
mount -o defaults,noatime,compress=lzo,autodefrag /dev/mapper/cryptroot ${MOUNTPOINT}

# Create volumes on the btrfs root
btrfs subvolume create ${MOUNTPOINT}/@rootnix
btrfs subvolume create ${MOUNTPOINT}/@boot
btrfs subvolume create ${MOUNTPOINT}/@home

# Remount with new volumes
umount ${MOUNTPOINT}
mount -o compress=lzo,subvol=@rootnix /dev/mapper/cryptroot ${MOUNTPOINT}
mkdir -p ${MOUNTPOINT}/boot ${MOUNTPOINT}/home
mount -o compress=lzo,subvol=@boot /dev/mapper/cryptroot ${MOUNTPOINT}/boot
mount -o compress=lzo,subvol=@home /dev/mapper/cryptroot ${MOUNTPOINT}/home
mkdir ${MOUNTPOINT}/boot/efi
mount ${DISK}1 ${MOUNTPOINT}/boot/efi
