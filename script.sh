export TERM=xterm-256color 
sudo wipefs -af /dev/sda
sudo cfdisk /dev/sda

sudo cryptsetup luksFormat /dev/sda2
sudo cryptsetup luksOpen /dev/sda2 enc-pv
sudo pvcreate /dev/mapper/enc-pv
sudo vgcreate vg /dev/mapper/enc-pv
sudo lvcreate -l '100%FREE' -n root vg

sudo mkfs.fat /dev/sda1
sudo mkfs.ext4 -L root /dev/vg/root

sudo mount /dev/vg/root /mnt
sudo mkdir /mnt/boot
sudo mount /dev/sda1 /mnt/boot

sudo nixos-generate-config --root /mnt
