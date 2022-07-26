{ config, pkgs, ... }:
{
  imports =
    [ 
      ./hardware-configuration.nix
    ];

  boot.initrd.kernelModules = [
  "dm-snapshot"
  "dm-raid"
  "dm-cache-default"
  ];

services.lvm.boot.thin.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

   networking.hostName = "TROST-DISTRICT";
   networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

   time.timeZone = "Europe/Amsterdam";
   services.xserver.enable = true;
  
   services.xserver.layout = "us";
   sound.enable = true;
   hardware.pulseaudio.enable = true;

   users.users.admin = {
     isNormalUser = true;
     extraGroups = [ "wheel" ]; 
     packages = with pkgs; [
	   discord
	   gimp
	   element-desktop
	   transmission
     ];
   };

  services.xserver.windowManager.i3.enable = true;
  
   environment.systemPackages = with pkgs; [
     chromium
     neovim
     wget
     polybar
	 iconpack-jade
     lightdm_gtk_greeter
	 lxqt.pcmanfm-qt
	 xfce.xfce4-settings
	 adwaita-qt
	 yarn
	 git
	 zsh
	 oh-my-zsh
	 zsh-powerlevel10k
	 meslo-lgs-nf
	 rxvt-unicode
	 evince
	 p7zip
	 unrar
	 rofi
	 xarchiver
	 python310
   ];

programs.chromium = {
  enable = true;
  extensions = [
    "omdakjcmkglenbhjadbccaookpfjihpa"
	"lmjnegcaeklhafolokijcfjliaokphfk"
	"eimadpbcbfnmbkopoojfekhnkhdbieeh"
  ];
};

   programs.mtr.enable = true;

   programs.gnupg.agent = {
     enable = true;
     enableSSHSupport = true;
   };

  services.openssh.enable = true;
  programs.ssh.setXAuthLocation = true;
  programs.ssh.forwardX11 = true;

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "22.05"; # Did you read the comment?
}
