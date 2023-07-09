{ pkgs, lib, config, ... }: {
  imports = [ ./modules/boot/secureboot.nix ./modules/systems/hyprland.nix ./modules/backups.nix ];

  system.stateVersion = "23.11";
  nixpkgs.config.allowUnfree = true;
  time.timeZone = "Europe/Paris";

  boot = {
    kernelModules = [ "kvm-intel" ];

    initrd = {
      availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "usbhid" "sd_mod" ];
      kernelModules = [ "dm-snapshot" ];
    };
  };

  hardware = {
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
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
                 [2 60 63]
                 [3 63 66]
                 [4 66 70]
                 [5 70 72]
                 [6 72 75]
                 [7 75 80]
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

    undervolt = {
      enable = true;
      coreOffset = -95;
      uncoreOffset = -95;
      gpuOffset = -95; # Seems to have no effect
    };
  };

  # Workaround for thinkfan being buggy
  # This fix doesn't work with the hardended config
  # systemd.services.thinkfan.preStart = "/run/current-system/sw/bin/modprobe -r thinkpad_acpi && /run/current-system/sw/bin/modprobe thinkpad_acpi";
}
