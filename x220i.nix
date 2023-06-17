{ pkgs, lib, config, ... }: {
  imports = [ ./modules/boot/uefi/grub.nix ./modules/kde.nix ./modules/storage/backups.nix ];

  system.stateVersion = "23.11";
  nixpkgs.config.allowUnfree = true;
  time.timeZone = "Europe/Paris";

  hardware = {
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    enableAllFirmware = true;
    bluetooth.enable = true;

    opengl = {
      enable = true;
      extraPackages = with pkgs; [ vaapiIntel ];
    };
  };

  services = {
    fstrim.enable = true;
    fwupd.enable = true;
  };
}
