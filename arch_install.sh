#!/bin/zsh

# FOR INSTANT RUNNING:
# zsh -c "$(curl -fsSL https://raw.githubusercontent.com/pumpkin-pi3/nixos-configs/main/arch_install.sh)"

# BE SURE THE INSTALLATION ENVIRONMENT'S VOLUME ISN'T TOO LOW:
amixer set Master 10+

#CHANGE THE SHELL IF NECESSARY!!!

#VARIABLES
hostname='TROST-DISTRICT'
myname='admin'
disk="/dev/sda"
wallpaper_url="https://raw.githubusercontent.com/pumpkin-pi3/nixos-configs/main/wallpaper.jpg"
wallpaper_path="/usr/share/wallpapers/wallpaper_default.jpg"
fehpic="https://raw.githubusercontent.com/pumpkin-pi3/nixos-configs/main/feh_pic.jpg"
#THIS MUST BE A NON-CHROOT PATH!!!

#MAGIC WORD
espeak-ng "Type your magic word"
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
parted $disk --script set 2 lvm on
echo -n $mgwd | cryptsetup luksFormat --type luks1 /dev/sda2 -
echo -n $mgwd | cryptsetup open /dev/sda2 cryptlvm -
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
sed -i 's/#en_US.UTF-8/en_US.UTF-8/g' /mnt/etc/locale.gen
arch-chroot /mnt localectl set-locale en_US.UTF-8
arch-chroot /mnt echo $hostname >> /mnt/etc/hostname
arch-chroot /mnt echo "127.0.0.1       localhost" >> /mnt/etc/hosts
arch-chroot /mnt echo "::1             localhost" >> /mnt/etc/hosts
arch-chroot /mnt echo "127.0.1.1       $hostname.localdomain   $hostname" >> /mnt/etc/hosts
arch-chroot /mnt pacman -Sy
arch-chroot /mnt pacman -S wget sudo neovim openssh grub efibootmgr networkmanager network-manager-applet wireless_tools wpa_supplicant dialog os-prober mtools dosfstools base-devel linux-headers git xdg-utils xdg-user-dirs xorg imagemagick i3-gaps ffmpegthumbs lightdm lightdm-slick-greeter noto-fonts noto-fonts-cjk chromium virtualbox-guest-utils gimp rofi polybar zsh htop newsboat discord rxvt-unicode feh scrot polkit polkit-kde-agent ttf-fantasque-sans-mono ttf-iosevka-nerd p7zip element-desktop pcmanfm-qt polkit polkit-kde-agent kdegraphics-thumbnailers kvantum qt5ct mpv fcitx5 lxappearance  dolphin fcitx5-configtool unrar okular gwenview ark kimageformats perl-image-exiftool python-pip inkscape ktorrent qt5-imageformats --noconfirm
sed -i -e '/HOOKS=(/s/filesystems/encrypt lvm2 filesystems/' /mnt/etc/mkinitcpio.conf
arch-chroot /mnt mkinitcpio -p linux
arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
duidu=$(arch-chroot /mnt blkid -s UUID -o value /dev/sda2)
sed -i "s?GRUB_CMDLINE_LINUX=\"?GRUB_CMDLINE_LINUX=\"cryptdevice=UUID=$duidu\:cryptlvm root=/dev/vg1/root?g" /mnt/etc/default/grub
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
curl "$fehpic" >> /mnt/home/$myname/.feh_pic.jpg

#INSTALLING YAY
arch-chroot /mnt git clone https://aur.archlinux.org/yay.git
arch-chroot /mnt mv yay /opt
arch-chroot /mnt su -c "sudo chown -R $myname:$myname /opt/yay" -s /bin/sh $myname &&
arch-chroot /mnt su -c "cd /opt/yay && makepkg -fsri --noconfirm" -s /bin/sh $myname &&
arch-chroot /mnt rm -r /opt/yay

#INSTALLING AUR PACKAGES
arch-chroot /mnt su -c "yay -S nomachine --noconfirm" -s /bin/sh $myname 
arch-chroot /mnt su -c "yay -S ttf-apple-emoji --noconfirm" -s /bin/sh $myname
arch-chroot /mnt su -c "yay -S ttf-meslo-nerd-font-powerlevel10k --noconfirm" -s /bin/sh $myname
arch-chroot /mnt su -c "yay -S win11-icon-theme-git --noconfirm" -s /bin/sh $myname
arch-chroot /mnt su -c "yay -S mcomix --noconfirm" -s /bin/sh $myname
arch-chroot /mnt su -c "yay -S peaclock --noconfirm" -s /bin/sh $myname
arch-chroot /mnt su -c "yay -S ttf-comfortaa --noconfirm" -s /bin/sh $myname
arch-chroot /mnt su -c "yay -S pfetch --noconfirm" -s /bin/sh $myname
arch-chroot /mnt su -c "yay -S betterlockscreen --noconfirm" -s /bin/sh $myname
arch-chroot /mnt su -c "yay -S ttf-material-design-iconic-font --noconfirm" -s /bin/sh $myname
arch-chroot /mnt su -c "yay -S fcitx5-mozc-ut-full --noconfirm" -s /bin/sh $myname
arch-chroot /mnt su -c "sudo update-mime-database /usr/share/mime" -s /bin/sh $myname

#ZSH INSTALLER
arch-chroot /mnt su -c 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended' -s /bin/sh $myname
arch-chroot /mnt su -c "yay -S ttf-meslo-nerd-font-powerlevel10k --noconfirm" -s /bin/sh $myname
arch-chroot /mnt su -c "sudo chsh $myname -s /usr/bin/zsh" -s /bin/sh $myname
arch-chroot /mnt su -c 'sh -c "$(wget -O- https://raw.githubusercontent.com/pumpkin-pi3/kde-config/main/settingup_ohmyzsh_and_p10k.sh)"' -s /bin/sh $myname
arch-chroot /mnt fc-cache -f -v
arch-chroot /mnt locale-gen

#NEOVIM PLUGINS
arch-chroot /mnt mkdir /home/$myname/.config/nvim/
arch-chroot /mnt curl 'https://raw.githubusercontent.com/pumpkin-pi3/nixos-configs/main/init.vim' >> /mnt/home/$myname/.config/nvim/init.vim
arch-chroot /mnt su -c 'sh -c "$(wget -O- https://raw.githubusercontent.com/pumpkin-pi3/nixos-configs/main/nvim-install-plugged.sh)"' -s /bin/sh $myname
arch-chroot /mnt su -c 'nvim -c "PlugInstall" -cwqa' -s /bin/sh $myname

#I3 CONFIGS, POLYBAR AND ROFI
arch-chroot /mnt su -c "mkdir /home/$myname/.config" -s /bin/sh $myname
arch-chroot /mnt su -c "mkdir /home/$myname/.config/i3" -s /bin/sh $myname
arch-chroot /mnt su -c "curl 'https://raw.githubusercontent.com/pumpkin-pi3/nixos-configs/main/config' >> /home/$myname/.config/i3/config" -s /bin/sh $myname
arch-chroot /mnt su -c "curl 'https://raw.githubusercontent.com/pumpkin-pi3/nixos-configs/main/.Xresources' >> /home/$myname/.Xresources" -s /bin/sh $myname
arch-chroot /mnt su -c "mkdir /home/$myname/.i3" -s /bin/sh $myname
arch-chroot /mnt su -c "curl 'https://raw.githubusercontent.com/pumpkin-pi3/nixos-configs/main/workspace-1.json' >> /home/$myname/.i3/workspace-1.json" -s /bin/sh $myname
arch-chroot /mnt su -c "curl 'https://raw.githubusercontent.com/pumpkin-pi3/nixos-configs/main/workspace-2.json' >> /home/$myname/.i3/workspace-2.json" -s /bin/sh $myname
arch-chroot /mnt su -c "curl 'https://raw.githubusercontent.com/pumpkin-pi3/nixos-configs/main/start_term.sh' >> /home/$myname/.i3/start_term.sh" -s /bin/sh $myname
arch-chroot /mnt su -c "chmod +x /home/$myname/.i3/start_term.sh" -s /bin/sh $myname
arch-chroot /mnt su -c "cd /home/$myname/.config && sudo wget 'https://github.com/pumpkin-pi3/nixos-configs/raw/main/plbr-rofi.7z' && sudo 7z x plbr-rofi.7z" -s /bin/sh $myname
arch-chroot /mnt su -c "curl 'https://raw.githubusercontent.com/pumpkin-pi3/nixos-configs/main/.zshrc' >> /home/$myname/.zshrc" -s /bin/sh $myname
arch-chroot /mnt su -c "curl 'https://raw.githubusercontent.com/pumpkin-pi3/nixos-configs/main/.p10k.zsh' >> /home/$myname/.p10k.zsh" -s /bin/sh $myname

#PAM ENVIRONMENT
arch-chroot /mnt su -c "echo 'QT_QPA_PLATFORMTHEME=qt5ct' >> /home/$myname/.pam_environment" -s /bin/sh $myname
arch-chroot /mnt su -c "echo 'GTK_THEME=Adwaita:dark' >> /home/$myname/.pam_environment" -s /bin/sh $myname
arch-chroot /mnt su -c "echo 'GTK_IM_MODULE=fcitx' >> /home/$myname/.pam_environment" -s /bin/sh $myname
arch-chroot /mnt su -c "echo 'QT_IM_MODULE=fcitx' >> /home/$myname/.pam_environment" -s /bin/sh $myname
arch-chroot /mnt su -c "echo 'XMODIFIERS=@im=fcitx' >> /home/$myname/.pam_environment" -s /bin/sh $myname

#KDEGLOBALS FOR DOLPHIN TO USE URXVTC INSTEAD OF KONSOLE
arch-chroot /mnt su -c "echo '[General]' >> /home/$myname/.config/kdeglobals" -s /bin/sh $myname
arch-chroot /mnt su -c "echo 'TerminalApplication=urxvtc' >> /home/$myname/.config/kdeglobals" -s /bin/sh $myname

#REMOVE UNNECESSARY PACKAGES
arch-chroot /mnt pacman -R emacs --noconfirm

#INSTALLATION END NOTIFY
espeak-ng 'Installation is finished'
