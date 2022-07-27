#!/bin/zsh

#CHANGE THE SHELL IF NECESSARY!!!

#VARIABLES
hostname='TROST-DISTRICT'
myname='admin'
disk="/dev/sda"

#INITIALIZATION
timedatectl set-ntp true
pacman -Sy
pacman -S archlinux-keyring --noconfirm
wipefs /dev/sda

#PARTITION SETUP
parted "$disk" --script mktable gpt
parted "$disk" --script mklabel gpt
parted "$disk" --script mkpart CloverEFI fat32 1MiB 201MiB
parted "$disk" --script mkpart 'macOS Monterey Rice' ext4 201MiB 100%
parted "$disk" --script set 2 lvm on
espeak-ng 'LUKS password prompt'
cryptsetup luksFormat /dev/sda2
espeak-ng 'LUKS password prompt'
cryptsetup open /dev/sda2 cryptlvm
pvcreate /dev/mapper/cryptlvm
vgcreate vg1 /dev/mapper/cryptlvm
lvcreate -l 100%FREE vg1 -n root
mkfs.fat -F32 /dev/sda1
mkfs.ext4 /dev/vg1/root
mount /dev/vg1/root /mnt
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot

#INSTALLATION
pacstrap /mnt base linux linux-firmware intel-ucode lvm2 --noconfirm
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
arch-chroot /mnt hwclock --systohc
sed -i 's/#en_US.UTF-8/en_US.UTF-8/g' /mnt/etc/locale.gen &&
arch-chroot /mnt echo $vmhostname >> /mnt/etc/hostname &&
arch-chroot /mnt echo "127.0.0.1       localhost" >> /mnt/etc/hosts &&
arch-chroot /mnt echo "::1             localhost" >> /mnt/etc/hosts &&
arch-chroot /mnt echo "127.0.1.1       $vmhostname.localdomain   $vmhostname" >> /mnt/etc/hosts &&
arch-chroot /mnt pacman -Sy &&
arch-chroot /mnt pacman -S wget sudo nano openssh grub efibootmgr networkmanager network-manager-applet wireless_tools wpa_supplicant dialog os-prober mtools dosfstools base-devel linux-headers git xdg-utils xdg-user-dirs --noconfirm
