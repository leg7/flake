{ config, lib, pkgs, ... }: {
  imports = [
    ./modules/mainDisk.nix
    ./modules/secureboot.nix
    ./modules/systems/server.nix
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
          authorizedKeys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIwo3QjEcW8fsvqIwPi53Riuum1G/6h06E3kmVcTfHV4 user@eleum" ];
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
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIwo3QjEcW8fsvqIwPi53Riuum1G/6h06E3kmVcTfHV4 user@eleum"
  ];

  system.stateVersion = "24.05";
  time.timeZone = "Europe/Paris";
  nixpkgs.config.allowUnfree = true;

  hardware.enableAllFirmware = true;
  networking.hostName = "majula";

  services.fstrim.enable = true;
}

