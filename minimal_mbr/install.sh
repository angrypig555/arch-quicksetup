#!/bin/bash
set -euo pipefail

echo "arch vm autoinstall script"
echo "only for amd64 BIOS vmware machines with the default config"
echo "if you want to change the timezone, feel free to modify the script"
echo "this script is fully automatic and assumes you have an internet connection as you already downloaded this"
echo "setup starting in 10 seconds"
sleep 10

SWAP="${DISK}1"
ROOT="${DISK}2"

echo "partitioning disk"
wipefs --all --force "$DISK"
sfdisk "$DISK"<< EOF
label: mbr
,2GB,82
,,83,*
EOF

echo "formatting disk"
mkfs.ext4 -F "$ROOT"
mkswap -f "$SWAP"

echo "mounting disk"
mount "$ROOT" /mnt
swapon "$SWAP"

echo "pacstrapping"
pacstrap -K /mnt base linux linux-firmware nano vim sudo networkmanager ufw openssh grub
echo "generating fstab"
genfstab -U /mnt >> /mnt/etc/fstab

echo "starting stage 2"
cp stage2.sh /mnt/root/
chmod +x /mnt/root/stage2.sh

arch-chroot -S /mnt /bin/bash -c "DISK='$DISK' ROOT='$ROOT' /root/stage2.sh"

echo "installation finished"
echo "goodbye!"
umount -R /mnt
reboot