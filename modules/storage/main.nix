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
      options = [ "defaults" "mode=755" ];
    };

    "/nix" = {
      device = "/dev/pool/nix";
      fsType = "f2fs";
      options = [ "compress_algorithm=zstd" "compress_chksum" "atgc" "gc_merge" "lazytime" ];
    };
  };

  environment = {
    persistence."/nix/persistent" = {
      hideMounts = true;

      directories = [
        "/home"
        "/var"
        "/etc/secureboot"
        "/etc/opt/ivpn/mutable"
      ];

      files = [
        "/etc/machine-id"
        "/etc/ssh/ssh_host_ed25519_key.pub"
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_rsa_key.pub"
        "/etc/ssh/ssh_host_rsa_key"
      ];
    };
  };
}
