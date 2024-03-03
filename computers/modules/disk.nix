{ disk-name ? "/dev/sda" , ... } : {
  disko.devices = {
    disk = {
      vdb = {
        type = "disk";
        device = "/dev/sda";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "500M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "defaults" ];
              };
            };

            luks = {
              content = {
                type = "luks";
                name = "crypted";
                initrdUnlock = true;
                askPassword = true;

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

                settings. allowDiscards = true;
              };

              size = "100%";
            };
          };
        };
      };
    };

    nodev = {
      "/" = {
        fsType = "tmpfs";
        mountOptions = [ "size=10G" ];
      };
    };

    lvm_vg = {
      pool = {
        type = "lvm_vg";

        lvs = {
          swap = {
            size = "20G";
            content = {
              type = "swap";
              resumeDevice = true;
            };
          };

          nix = {
            size = "80G";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/nix";
              mountOptions = [ "defaults" ];
            };
          };

          persistent = {
            size = "100%FREE";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/persistent";
            };
          };
        };
      };
    };

  };
}
