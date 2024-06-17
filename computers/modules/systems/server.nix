{ lib, pkgs, ... }: {
  imports = [ ./base.nix ];

  networking.wireless.iwd.enable = lib.mkForce false;
  hardware.bluetooth.enable = lib.mkForce false;

  networking.firewall = {
      enable = true;
      allowedUDPPorts = [];
      allowedTCPPorts = [ 727 ];
  };
}
