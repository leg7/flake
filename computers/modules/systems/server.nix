{ lib, pkgs, ... }: {
  imports = [ ./base.nix ];

  networking.firewall = {
      enable = true;
      allowedUDPPorts = [];
      allowedTCPPorts = [ 727 ];
  };
}
