#!/bin/zsh

# FOR INSTANT RUNNING:
# zsh -c "$(curl -fsSL https://raw.githubusercontent.com/pumpkin-pi3/nixos-configs/main/arch_install_basic.sh)"

# BE SURE THE INSTALLATION ENVIRONMENT'S VOLUME ISN'T TOO LOW:
amixer set Master 10+

#CHANGE THE SHELL IF NECESSARY!!!

#VARIABLES
hostname='ARCH-DIANA'
myname='admin'
disk="/dev/sda"
wallpaper_url="https://raw.githubusercontent.com/pumpkin-pi3/nixos-configs/main/wallpaper.jpg"
wallpaper_path="/usr/share/wallpapers/wallpaper_default.jpg"
#THIS MUST BE A NON-CHROOT PATH!!!

#MAGIC WORD
echo "Type your magic word:"
read mgwd

#INITIALIZATION
#timedatectl set-ntp true
#PGP keys can become unusable if time is set incorrectly
pacman -Sy archlinux-keyring --noconfirm
pacman -Sy
wipefs -af /dev/sda

#PARTITION SETUP
parted $disk --script mktable gpt
parted $disk --script mklabel gpt
parted $disk --script mkpart CloverEFI fat32 1MiB 201MiB
parted $disk --script mkpart 'macOS-Monterey-Rice' ext4 201MiB 100%
parted $disk --script set 1 esp on
mkfs.fat -F32 /dev/sda1
mkfs.ext4 /dev/sda2
mount /dev/sda2 /mnt
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot

#INSTALLATION
pacstrap /mnt base linux linux-firmware intel-ucode --noconfirm
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
arch-chroot /mnt hwclock --systohc
sed -i 's/#en_US.UTF-8/en_US.UTF-8/g' /mnt/etc/locale.gen
arch-chroot /mnt localectl set-locale en_US.UTF-8
arch-chroot /mnt echo $hostname >> /mnt/etc/hostname
arch-chroot /mnt echo "127.0.0.1       localhost" >> /mnt/etc/hosts
arch-chroot /mnt echo "::1             localhost" >> /mnt/etc/hosts
arch-chroot /mnt echo "127.0.1.1       $hostname.localdomain   $hostname" >> /mnt/etc/hosts
arch-chroot /mnt pacman -Sy
arch-chroot /mnt pacman -S wget sudo neovim openssh grub efibootmgr networkmanager network-manager-applet wireless_tools wpa_supplicant dialog os-prober mtools dosfstools base-devel linux-headers git xdg-utils xdg-user-dirs xorg imagemagick i3-gaps ffmpegthumbs lightdm lightdm-slick-greeter noto-fonts noto-fonts-cjk chromium virtualbox-guest-utils --noconfirm
arch-chroot /mnt mkinitcpio -p linux
arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
duidu=$(arch-chroot /mnt blkid -s UUID -o value /dev/sda2)
sed -i "s?GRUB_GFXMODE=auto?GRUB_GFXMODE=1920x1080x32?g" /mnt/etc/default/grub
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
arch-chroot /mnt systemctl enable NetworkManager
arch-chroot /mnt systemctl enable sshd
arch-chroot /mnt useradd -mG wheel $myname
arch-chroot /mnt usermod --password $(echo $mgwd | openssl passwd -1 -stdin) root
arch-chroot /mnt usermod --password $(echo $mgwd | openssl passwd -1 -stdin) $myname
sed -i 's?# %wheel ALL?%wheel ALL?' /mnt/etc/sudoers
arch-chroot /mnt pacman -Syu --noconfirm
arch-chroot /mnt sudo systemctl enable lightdm
arch-chroot /mnt sed -i "s?#greeter-session=example-gtk-gnome?greeter-session=lightdm-slick-greeter?g" /etc/lightdm/lightdm.conf
arch-chroot /mnt sed -i "s?#logind-check-graphical=false?logind-check-graphical=true?g" /etc/lightdm/lightdm.conf
arch-chroot /mnt mkdir /usr/share/wallpapers/
arch-chroot /mnt wget "$wallpaper_url" -O "$wallpaper_path"
echo "[Greeter]" >> "/mnt/etc/lightdm/slick-greeter.conf"
echo "background=$wallpaper_path" >> "/mnt/etc/lightdm/slick-greeter.conf"

#INSTALLING YAY
arch-chroot /mnt git clone https://aur.archlinux.org/yay.git
arch-chroot /mnt mv yay /opt
arch-chroot /mnt su -c "sudo chown -R $myname:$myname /opt/yay" -s /bin/sh $myname &&
arch-chroot /mnt su -c "cd /opt/yay && makepkg -fsri --noconfirm" -s /bin/sh $myname &&
arch-chroot /mnt rm -r /opt/yay

#ZSH INSTALLER
arch-chroot /mnt su -c 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended' -s /bin/sh $myname
arch-chroot /mnt su -c "yay -S ttf-meslo-nerd-font-powerlevel10k --noconfirm" -s /bin/sh $myname
arch-chroot /mnt su -c "sudo chsh $myname -s /usr/bin/zsh" -s /bin/sh $myname
arch-chroot /mnt su -c 'sh -c "$(wget -O- https://raw.githubusercontent.com/pumpkin-pi3/kde-config/main/settingup_ohmyzsh_and_p10k.sh)"' -s /bin/sh $myname
arch-chroot /mnt fc-cache -f -v
arch-chroot /mnt locale-gen

#REMOVE UNNECESSARY PACKAGES
arch-chroot /mnt pacman -R emacs --noconfirm

#INSTALLATION END NOTIFY
espeak-ng 'Installation is finished'
