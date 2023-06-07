{ pkgs, lib, config, ... }: {
  imports = [ ./modules/secure-boot.nix ./modules/impermanence.nix ./modules/rice.nix ];

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  boot = {
    kernelModules = [ "kvm-intel" ];

    initrd = {
      availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "usbhid" "sd_mod" ];
      kernelModules = [ "dm-snapshot" ];

      luks.devices.cryptBackup = {
        device = "/dev/disk/by-label/cryptBackup";
        allowDiscards = true;
      };
    };
  };

  fileSystems."/nix/persistent/backup" = {
      device = "/dev/disk/by-label/backup";
      fsType = "f2fs";
      options = [ "compress_algorithm=zstd" "compress_chksum" "atgc" "gc_merge" "lazytime" ];
      neededForBoot = false;
  };

  system.stateVersion = "23.11";
  nixpkgs.config.allowUnfree = true;
  time.timeZone = "Europe/Paris";

  hardware = {
    enableAllFirmware = true;
    bluetooth.enable = true;
    opentabletdriver.enable = true;

    nvidia = {
      modesetting.enable = true;
      prime = {
        offload.enable = true;
        nvidiaBusId = "PCI:1:0:0";
        intelBusId = "PCI:0:2:0";
      };
    };

    opengl = {
      enable = true;
      extraPackages = with pkgs; [ vaapiIntel vaapiVdpau libvdpau-va-gl ];
    };
  };

  programs.hyprland = {
    nvidiaPatches = true;
  };

  services = {
    xserver.videoDrivers = [ "nvidia" ];
    fstrim.enable = true;
    fwupd.enable = true;

    # Rules to use wacom 480 with opentablet driver
    udev.extraRules = ''
    KERNEL=="uinput", SUBSYSTEM=="misc", TAG+="uaccess", OPTIONS+="static_node=uinput"
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="056a", ATTRS{idProduct}=="0302", MODE="0666"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="056a", ATTRS{idProduct}=="0302", MODE="0666"
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="056a", ATTRS{idProduct}=="030e", MODE="0666"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="056a", ATTRS{idProduct}=="030e", MODE="0666"
    '';

    thinkfan = {
      enable = true;
      sensors = [ { type = "tpacpi"; query = "/proc/acpi/ibm/thermal"; indices = [ 0 1 2 ]; } ];
      fans = [ { type = "tpacpi"; query = "/proc/acpi/ibm/fan"; } ];
      levels =  [[0 0 55]
                 [1 55 60]
                 [2 60 65]
                 [3 65 70]
                 [4 70 75]
                 [5 75 80]
                 ["level auto" 80 255]];
    };

    tlp = {
      enable = true;
      settings = {
        START_CHARGE_THRESH_BAT0=75;
        STOP_CHARGE_THRESH_BAT0=80;
        START_CHARGE_THRESH_BAT1=75;
        STOP_CHARGE_THRESH_BAT1=80;
        CPU_SCALING_GOVERNOR_ON_AC="performance";
        CPU_SCALING_GOVERNOR_ON_BAT="powersave";
        DEVICES_TO_DISABLE_ON_STARTUP="bluetooth";
        DEVICES_TO_DISABLE_ON_SHUTDOWN="bluetooth wifi";
        DEVICES_TO_DISABLE_ON_BAT_NOT_IN_USE="bluetooth";
      };
    };
  };

  # Workaround for thinkfan being buggy
  systemd.services.thinkfan.preStart = "/run/current-system/sw/bin/modprobe -r thinkpad_acpi && /run/current-system/sw/bin/modprobe thinkpad_acpi";
}
