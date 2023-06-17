{ pkgs, lib, ... }: {
  imports = [ ./base.nix ];

  # These settings cause firefox to crash or not open so we revert them
  boot.kernelPackages = lib.mkOverride 50 pkgs.linuxPackages;
  environment.memoryAllocator.provider = lib.mkOverride 50 "libc";

  fonts.fonts = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    nerdfonts
  ];

  programs.firejail.wrappedBinaries.firefox = {
      executable = "${pkgs.lib.getBin pkgs.firefox}/bin/firefox";
      profile = "${pkgs.firejail}/etc/firejail/firefox.profile";
      extraArgs = [ "--private=~/.local/share/firefox" ];
  };

  programs.dconf.enable = true;

  services = {
    xserver = {
      enable = true;
      desktopManager.plasma5.enable = true;

      displayManager = {
        sddm.enable = true;
        autoLogin.user = "user";
        defaultSession = "plasmawayland";
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
}