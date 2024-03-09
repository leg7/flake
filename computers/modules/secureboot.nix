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
        pkiBundle = "${config.mainDisk.persistentDataPath}/etc/secureboot";
      };
    };

    environment.persistence."${config.mainDisk.persistentDataPath}".directories = [ "/etc/secureboot" ];
  };
}
