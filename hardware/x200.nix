{ pkgs, ... }: {
  imports = [ ./modules/systems/hyprland.nix ];

  system.stateVersion = "24.11";
  time.timeZone = "Europe/Paris";

  hardware = {
    bluetooth.enable = true;
    opengl = {
      enable = true;
      extraPackages = [ pkgs.vaapiIntel ];
    };
  };

  services.fstrim.enable = true;
}
