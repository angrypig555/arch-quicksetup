#!/bin/bash

echo "arch vm autoinstall script"
echo "only for amd64 UEFI vmware machines with the default config"
echo "if you want to change the timezone or disk, feel free to modify the script"
echo "this script is fully automatic and assumes you have an internet connection as you already downloaded this"
echo "setup starting in 10 seconds"
sleep 10
# IF YOU CHANGE THIS YOU ALSO NEED TO CHANGE THE DISK IN stage2.sh WHERE THE BOOTLOADER CONFIG IS GENERATED
DISK="/dev/sda"
ESP="/dev/sda1"
SWAP="/dev/sda2"
ROOT="/dev/sda3"

echo "partitioning disk"
sfdisk "$DISK"<< EOF
label: gpt
,1GB,C12A7328-F81F-11D2-BA4B-00A0C93EC93B
,2GB,0657FD6D-A4AB-43C4-84E5-0933C84B4F4F
,,4F68BCE3-E8CD-4DB1-96E7-FBCAF984B709
EOF

echo "formatting disk"
mkfs.ext4 "$ROOT"
mkswap "$SWAP"
mkfs.fat -F 32 "$ESP"

echo "mounting disk"
mount "$ROOT" /mnt
mount --mkdir "$ESP" /mnt/boot
swapon "$SWAP"

echo "pacstrapping"
pacstrap --noconfirm -K /mnt base linux linux-firmware nano vim sudo networkmanager ufw openssh
echo "generating fstab"
genfstab -U /mnt >> /mnt/etc/fstab

echo "starting stage 2"
cp stage2.sh /mnt/root/
chmod +x /mnt/root/stage2.sh

arch-chroot /mnt /bin/bash /root/stage2.sh

echo "installation finished"
echo "goodbye!"
umount -R /mnt
reboot