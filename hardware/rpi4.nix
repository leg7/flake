{ config, lib, pkgs, ... }: {
  imports = [
    ../modules/mainDisk.nix
    ../modules/secureboot.nix
    ../systems/server/server.nix
  ];

  boot = {
    loader = {
      generic-extlinux-compatible.enable = lib.mkForce false;
      efi.canTouchEfiVariables = true; # needed to install uefi
    };
    kernelPackages = pkgs.linuxPackages_latest; # needed to boot

    kernelParams = [ "ip=dhcp" ];
    initrd = {
      availableKernelModules = [ "genet" ];
      systemd.users.root.shell = "/bin/cryptsetup-askpass";
      network = {
        enable = true;
        ssh = {
          enable = true;
          port = 727;
          authorizedKeys = config.users.users.user.openssh.authorizedKeys.keys;
          hostKeys = [ "/etc/ssh/ssh_host_rsa_key" ];
        };
      };
    };
  };
  secureboot.enable = true;

  mainDisk = {
    name = "/dev/mmcblk1";
    sizes = {
      nix = "15G";
      swap = "6G";
    };
  };

  users.users.user.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAGW96bkirUSW7oZXCJzgfg7P/FD5NBBtk+ze3CdA7Jm user@eleum"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN8eHHByOR7nSKrNAQ1JGdDo6FjbHl1mqx6gPQFrHVQE user@heide"
  ];

  system.stateVersion = "24.11";
  time.timeZone = "Europe/Paris";
  nixpkgs.config.allowUnfree = true;

  hardware.enableAllFirmware = true;
  networking.hostName = "majula";

  services.fstrim.enable = true;
}

