{ lib, ... }: {
  boot = {
    loader.systemd-boot.enable = lib.mkForce false;
    bootspec.enable = true;

    lanzaboote = {
      enable = true;
      pkiBundle = "/persistent/etc/secureboot";
    };
  };

  environment.persistence."/persistent".directories = [ "/etc/secureboot" ];
}
