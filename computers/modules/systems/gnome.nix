{ pkgs, lib, ... }: {
  imports = [ ./base.nix ];

  # These settings cause firefox to crash or not open so we revert them
  boot.kernelPackages = lib.mkOverride 50 pkgs.linuxPackages;
  environment.memoryAllocator.provider = lib.mkOverride 50 "libc";

  security.lockKernelModules = lib.mkOverride 50 false;

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    nerdfonts
  ];

  users.users.user.packages = with pkgs; [
	firefox
  ];

  programs.dconf.enable = true;

  hardware.sane.enable = true;
  users.users.user.extraGroups = [ "scanner" "lp" ];

  services = {
    xserver = {
      enable = true;
      desktopManager.gnome.enable = true;

      displayManager = {
        gdm.enable = true;
        autoLogin.user = "user";
        defaultSession = "gnome";
      };
    };

    printing = {
      enable = true;
      drivers = with pkgs; [
        gutenprintBin
        hplip
      ];
    };

    avahi = {
      enable = true;
      nssmdns = true;
      openFirewall = true;
    };
  };

  environment.persistence."/persistent".directories = [ "/etc/NetworkManager/system-connections" ];
}
