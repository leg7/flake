{ lib, config, ... }:
with lib;
let
  cfg = config.mainDisk;
  hostname = config.networking.hostName;
in {
  options.mainDisk = {
    name = mkOption {
      type = types.str;
      example = "/dev/sda";
      description = "The drive you want to format and partition as your main disk or the computer";
    };

    sizes = {
      nix = mkOption {
        type = types.str;
        example = "10G";
        description = "The size of the lvm volume used to save the nix store";
      };

      swap = mkOption {
        type = types.str;
        example = "6G";
        description = "The size of your swap partition (should be 150% of your ram)";
      };
    };

    persistentDataPath = mkOption {
      type = types.str;
      example = "/persistent";
      default = "/persistent";
      description = "The path where user persitent data partition will be mounted (note do not mount in /nix)";
    };
  };

  config = {
    disko.devices = {
      disk = {
        vdb = {
          type = "disk";
          device = cfg.name;

          content = {
            type = "gpt";

            partitions = {
              ESP = {
                label = "${hostname}_ESP";
                name = "${hostname}_ESP";
                size = "512M";
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                  mountOptions = [ "defaults" ];
                };
              };

              luks = {
                label = "${hostname}_mainDisk_luks";
                size = "100%";

                content = {
                  type = "luks";
                  name = "${hostname}_mainDisk_luks";
                  initrdUnlock = true;
                  askPassword = true;

                  # TODO: Check if bcrypt hash is supported
                  extraFormatArgs = [
                    "--type luks2"
                    "-i 5000"
                    "--pbkdf argon2id"
                    "--pbkdf-memory 4000000"
                    "--hash sha512"
                  ];

                  content = {
                    type = "lvm_pv";
                    vg = "pool";
                  };

                  settings.allowDiscards = true;
                };
              };
            };
          };
        };
      };

      # TODO: Use snapshots instead to be able to see what files were added since boot
      # and also to not waste so much ram
      nodev."/" = {
          fsType = "tmpfs";
          mountOptions = [ "defaults" "size=10G" "mode=755" ];
      };

      lvm_vg = {
        pool = {
          lvs = {
            swap = {
              content = {
                type = "swap";
                resumeDevice = true;
              };

              size = "${cfg.sizes.swap}";
            };

            nix = {
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/nix";
                mountOptions = [ "defaults" ];
              };

              size = "${cfg.sizes.nix}";
            };

            persistent = {
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = cfg.persistentDataPath;
              };

              size = "100%FREE";
            };
          };

          type = "lvm_vg";
        };
      };

    };

    fileSystems = {
      "/".neededForBoot = true;
      "/nix".neededForBoot = true;
      "${cfg.persistentDataPath}".neededForBoot = true;
    };

    boot.supportedFilesystems = [ "ext4" ];
    boot.initrd.kernelModules = [ "dm-snapshot" ];
  };
}
