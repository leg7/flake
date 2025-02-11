# An extra encrypted luks volume to keep backups that will be decrypted at boot
{ pkgs, config, ... }: {
  boot.initrd.luks.devices.cryptBackup = {
    device = "/dev/disk/by-label/cryptBackup";
    allowDiscards = true;
  };

  fileSystems."${config.mainDisk.persistentDataPath}/backup" = {
    device = "/dev/disk/by-label/backup";
    fsType = "ext4";
    options = [ "defaults" ];
  };

  # Make sure your disk is big enough to store the backups
  systemd = {
    services."backup" = {

      script = ''
      backupDir=${config.mainDisk.persistentDataPath}/backup
      home=${config.mainDisk.persistentDataPath}/home/user

      ${pkgs.util-linux}/bin/mount -m "$backupDir"
      ${pkgs.findutils}/bin/find "$backupDir" -mtime +5 -delete
      ${pkgs.gnutar}/bin/tar cvf "$backupDir"/"$(date +"%F_%H-%M-%S")".tar $home/books $home/documents $home/pics $home/vids $home/audio
      ${pkgs.util-linux}/bin/umount "$backupDir"
      '';

      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
    };

    timers."backup" = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
        unit = "backup.service";
        AccuracySec = "10m";
      };
    };
  };
}
