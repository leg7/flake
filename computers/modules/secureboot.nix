{ lib, config, ... }:
with lib;
{
  options.secureboot = {
    enable = mkOption {
      type = types.bool;
      description = "Whether to enable secureboot or not";
    };
  };

  config = mkIf config.secureboot.enable {
    boot = {
      loader.systemd-boot.enable = lib.mkForce false;
      bootspec.enable = true;

      lanzaboote = {
        enable = true;
        pkiBundle = "/persistent/etc/secureboot";
      };
    };

    environment.persistence."/persistent".directories = [ "/etc/secureboot" ];
  };
}
