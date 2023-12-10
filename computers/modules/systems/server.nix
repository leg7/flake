{ lib, pkgs, ... }: {
  imports = [ ./base.nix ];

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 727 ];
  };
}
