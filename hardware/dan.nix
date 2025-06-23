{ pkgs, lib, config, ... }: {
  imports = [
    ../modules/secureboot.nix
    ../modules/mainDisk.nix
    ../systems/river/river.nix
  ];

  mainDisk = {
    name = "/dev/nvme0n1";
    sizes = {
      swap = "20G";
      nix = "100G";
    };
  };

  secureboot.enable = true;

  networking = {
    hostName = "heide";
    hosts = {
      "82.66.68.221" = [ "majula" ];
    };
  };

  system.stateVersion = "24.11";
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.rocmSupport = true;
  time.timeZone = "Europe/Paris";

  boot = {
    kernelModules = [ "amdgpu" ];

    initrd = {
      availableKernelModules = [ "usbhid" "xhci_pci" "nvme" "usb_storage" "sd_mod" ];
      kernelModules = [ "dm-snapshot" ];
    };
  };


  # for opentablet driver
  nixpkgs.config.permittedInsecurePackages = [
    "dotnet-runtime-6.0.36"
    "dotnet-sdk-wrapped-6.0.428"
    "dotnet-sdk-6.0.428"
  ];

  hardware = {
    cpu.amd.updateMicrocode = true;
    amdgpu.amdvlk.enable = true;
    enableAllFirmware = true;
    bluetooth.enable = true;
    opentabletdriver.enable = true;

    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        rocmPackages.clr.icd
        clinfo
      ];
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
    ollama.enable = true;
    nextjs-ollama-llm-ui.enable = true;

    xserver.videoDrivers = [ "amdgpu" ];
    fstrim.enable = true;
    fwupd.enable = true;

    udev = {
      extraRules = ''
      # Wacom 480
      KERNEL=="uinput", SUBSYSTEM=="misc", TAG+="uaccess", OPTIONS+="static_node=uinput"
      SUBSYSTEM=="hidraw", ATTRS{idVendor}=="056a", ATTRS{idProduct}=="0302", MODE="0666"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="056a", ATTRS{idProduct}=="0302", MODE="0666"
      SUBSYSTEM=="hidraw", ATTRS{idVendor}=="056a", ATTRS{idProduct}=="030e", MODE="0666"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="056a", ATTRS{idProduct}=="030e", MODE="0666"
      # Chocofi
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{serial}=="*vial:f64c2b3c*", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
      # Wooting One Legacy
      SUBSYSTEM=="hidraw", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="ff01", TAG+="uaccess"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="ff01", TAG+="uaccess"
      # Wooting One update mode
      SUBSYSTEM=="hidraw", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="2402", TAG+="uaccess"
      '';
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
