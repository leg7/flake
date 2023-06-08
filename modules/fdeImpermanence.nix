# Impermanence for FDE + LVM with root on tmpfs
{ ... }: {
  boot.initrd.luks.devices.cryptLvm = {
    device = "/dev/disk/by-label/cryptLvm";
    allowDiscards = true;
  };

  swapDevices = [ { device = "/dev/pool/swap"; } ];

  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-label/ESP";
      fsType = "vfat";
    };

    "/" = {
      device = "tmpfs";
      fsType = "tmpfs";
      options = [ "defaults" "size=256M" "mode=755" ];
    };

    "/nix" = {
      device = "/dev/pool/nix";
      fsType = "f2fs";
      options = [ "compress_algorithm=zstd" "compress_chksum" "atgc" "gc_merge" "lazytime" ];
    };
  };

  environment = {
    variables.NIX_REMOTE = "daemon";

    persistence."/nix/persistent" = {
      hideMounts = true;

      directories = [
        "/home"
        "/var"
        "/etc/secureboot"
      ];

      files = [
        "/etc/keyd/default.conf"
        "/etc/machine-id"
        "/etc/ssh/ssh_host_ed25519_key.pub"
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_rsa_key.pub"
        "/etc/ssh/ssh_host_rsa_key"
      ];
    };
  };

  # Places /tmp in var so that we don't run out of space when compiling stuff
  systemd.services.nix-daemon = {
    environment.TMPDIR = "/var/cache/nix";
    serviceConfig.CacheDirectory = "nix";
  };
}
