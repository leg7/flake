{ lib, ... }: {
  boot = {
    loader.systemd-boot.enable = lib.mkForce false;
    bootspec.enable = true;

    lanzaboote = {
      enable = true;
      pkiBundle = "/etc/secureboot";
    };
  };

  environment.persistence."/nix/persistent".directories = [ "/etc/secureboot" ];
}
