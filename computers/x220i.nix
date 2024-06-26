{ pkgs, lib, config, ... }: {
  imports = [ ./modules/boot/systemd.nix ./modules/systems/gnome.nix ];

  system.stateVersion = "24.05";
  nixpkgs.config.allowUnfree = true;
  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "fr_FR.UTF-8";
  console.keyMap = "fr";

  # Use cryptsetup luksUUID to find the uuid of the device
  # boot.initrd.luks.devices.cryptLvm.device = lib.mkOverride 50 "/dev/disk/by-uuid/";
  # boot.loader.grub.device = lib.mkOverride 50 "/dev/disk/by-uuid";

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
