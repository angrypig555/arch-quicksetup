#!/bin/bash
echo "arch-quicksetup stage 2"
echo "enabling networking"
systemctl enable NetworkManager.service

echo "setting timezone"
ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime
echo "setting system clock"
hwclock --systohc
echo "setting locale"
echo "LANG=en_GB.UTF-8" > /etc/locale.conf
echo "en_GB.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
echo "setting hostname"
echo "arch-vm" > /etc/hostname
echo "root password is root"
echo  "root:root" | chpasswd
useradd -m -G wheel user
echo "created priviliged user without a password"
echo "installing systemd-boot"
bootctl install
echo "creating boot entries and configs"
cat << EOF > /boot/loader/loader.conf
default arch.conf
timeout 0
editor no
EOF
# IF YOU CHANGED THE DISK VARIABLE IN THE FIRST SCRIPT YOU ALSO NEED TO CHANGE IT HERE
ROOT_UUID=$(blkid -s UUID -o value /dev/sda3)
cat << EOF > /boot/loader/entries/arch.conf
title Arch Linux
linux /vmlinuz-linux
initrd /initramfs-linux.img
options root=UUID=${ROOT_UUID} rw
EOF
cat << EOF > /etc/motd
If you want to disable this, delete /etc/motd
!!! CHANGE THE ROOT PASSWORD IMMIDIAETLY !!!
The root password is a default and is easily guessable.
Also don't forget to set a password for the user account as you can't login yet.
EOF
echo "enabling firewall"
ufw default deny incoming
ufw default allow outgoing
ufw allow SSH
sed -i 's/ENABLED=no/ENABLED=yes/' /etc/ufw/ufw.conf
systemctl enable ufw.service
echo "enabling ssh"
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
systemctl enable sshd.service
echo "stage 2 complete, exiting..."
exit