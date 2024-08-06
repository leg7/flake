{ pkgs, lib, config, ... }: {
  imports = [
    ./modules/secureboot.nix
    ./modules/systems/hyprland/hyprland.nix
    ./modules/mainDisk.nix
    ./modules/backups.nix
  ];

  mainDisk = {
    name = "/dev/nvme0n1";
    sizes = {
      swap = "20G";
      nix = "90G";
    };
  };

  secureboot.enable = true;

  networking = {
    hostName = "eleum";
    hosts = {
      "82.66.68.221" = [ "majula" ];
    };
  };

  system.stateVersion = "24.05";
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.nvidia.acceptLicense = true;
  time.timeZone = "Europe/Paris";

  boot = {
    kernelModules = [ "nvidia" ];
    blacklistedKernelModules = [ "nouveau" "i915" ];

    initrd = {
      availableKernelModules = [ "usbhid" "xhci_pci" "nvme" "usb_storage" "sd_mod" ];
      kernelModules = [ "nvidia" "dm-snapshot" ];
    };
  };

  hardware = {
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    enableAllFirmware = true;
    bluetooth.enable = true;
    opentabletdriver.enable = true;

    nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      modesetting.enable = true;
      nvidiaSettings = true;
      prime = {
        sync.enable = true;
        nvidiaBusId = "PCI:1:0:0";
        intelBusId = "PCI:0:2:0";
      };
    };

    opengl = {
      driSupport = true;
      driSupport32Bit = true;
      enable = true;
      extraPackages = with pkgs; [ intel-media-driver ];
    };
  };

  # this is required to be able to use ethernet thourgh thunderbolt and though the rj45 port
  systemd.network = {
    networks."10-wired" = {
      matchConfig.Type = "ether";
      networkConfig.DHCP = "ipv4";
      dhcpV4Config = { UseDomains = true; };
      linkConfig.RequiredForOnline = "no";
    };
  };

  services = {
    xserver.videoDrivers = [ "nvidia" ];
    fstrim.enable = true;
    fwupd.enable = true;

    # Rules to use wacom 480 with opentablet driver & vial kb firmware
    udev.extraRules = ''
    # wacom 480
    KERNEL=="uinput", SUBSYSTEM=="misc", TAG+="uaccess", OPTIONS+="static_node=uinput"
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="056a", ATTRS{idProduct}=="0302", MODE="0666"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="056a", ATTRS{idProduct}=="0302", MODE="0666"
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="056a", ATTRS{idProduct}=="030e", MODE="0666"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="056a", ATTRS{idProduct}=="030e", MODE="0666"
    # Chocofi
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{serial}=="*vial:f64c2b3c*", MODE="0660", GROUP="$USER_GID", TAG+="uaccess", TAG+="udev-acl"
    # Wooting One Legacy
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="ff01", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="ff01", TAG+="uaccess"
    # Wooting One update mode
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="2402", TAG+="uaccess"
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
      coreOffset = -90;
      uncoreOffset = -90;
      gpuOffset = -90; # Seems to have no effect
    };

    # -- Programmer dvorak layout
    keyd = {
      enable = true;
      keyboards.conventional = {
        ids = [ "31e3:1100" "0001:0001" ];
        settings = {
          main = {
            capslock = "escape";
            escape = "capslock";

            "`" = "$";
            "1" = "&";
            "2" = "[";
            "3" = "{";
            "4" = "}";
            "5" = "(";
            "6" = "=";
            "7" = "*";
            "8" = ")";
            "9" = "+";
            "0" = "]";
            "-" = "!";
            equal = "#";

            q = ";";
            w = ",";
            e = ".";
            r = "p";
            t = "y";
            y = "f";
            u = "g";
            i = "c";
            o = "r";
            p = "l";
            "[" = "/";
            "]" = "@";

            a = "a";
            s = "o";
            d = "e";
            f = "u";
            g = "i";
            h = "d";
            j = "h";
            k = "t";
            l = "n";
            ";" = "s";
            "'" = "-";

            z = "'";
            x = "q";
            c = "j";
            v = "k";
            b = "x";
            n = "b";
            m = "m";
            "," = "w";
            "." = "v";
            "/" = "z";

          };
          shift = {
            "`" = "~";
            "1" = "1";
            "2" = "2";
            "3" = "3";
            "4" = "4";
            "5" = "5";
            "6" = "6";
            "7" = "7";
            "8" = "8";
            "9" = "9";
            "0" = "0";
            "-" = "%";
            equal = "`";

            "]" = "^";
          };
        };
      };
    };

  };
}
