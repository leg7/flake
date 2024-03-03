{ lib, ... }: {
  boot = {
    loader.systemd-boot.enable = lib.mkForce false;
    bootspec.enable = true;

    lanzaboote = {
      enable = true;
      pkiBundle = "/persist/etc/secureboot";
    };
  };

  environment.persistence."/persistent".directories = [ "/etc/secureboot" ];
}
