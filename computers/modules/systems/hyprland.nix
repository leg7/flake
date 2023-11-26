# Wayland hyprland config
{ pkgs, lib, ... }: {
  imports = [ ./base.nix ];

  # These settings cause firefox to crash or not open so we revert them
  boot.kernelPackages = lib.mkOverride 50 pkgs.linuxPackages;
  environment.memoryAllocator.provider = lib.mkOverride 50 "libc";

  security.lockKernelModules = lib.mkOverride 50 false;

  users.users.user.packages = with pkgs; [
    # dev tools
    cargo
    nodejs
    python311Full
    haskell.compiler.ghc947 haskell-language-server cabal-install
    qtcreator
    gnumake cmake clang-tools clang gcc glibc
    ocaml ocamlPackages.merlin opam
    # keyboard
    appimage-run vial
    qmk
    # other
    transmission libtransmission tremc
    swaybg eww-wayland socat jq
    ncmpcpp pulsemixer pamixer easyeffects
    imv zathura mpv
    cowsay fortune
    ffmpeg yt-dlp-light
    foot
    fnott libnotify
    wlsunset
    cinnamon.nemo
    ydotool
    wl-clipboard
    newsboat
    wofi
    qrencode
    qalculate-gtk
    brightnessctl
    signal-desktop
    firefox
    gnome.gnome-calendar
    gnome.adwaita-icon-theme
  ];

  fonts = {
    enableDefaultPackages = true;

    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      nerdfonts
    ];

    fontconfig.defaultFonts = {
      serif = [ "Noto Serif" ];
      sansSerif = [ "Noto Sans" ];
      monospace = [ "Monoid Nerd Font Mono" "Symbols Nerd Font" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # for gnome calendar to work
  programs.dconf.enable = true;
  services.gnome.evolution-data-server.enable = true;

  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "user" ];

  services = {
    ivpn.enable = true;
    getty.autologinUser = "user";

    syncthing = {
      enable = true;
      user = "user";
      dataDir = "/home/user";
    };

    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };

    mpd = {
      enable = true;
      user = "user";
      group = "users";
      musicDirectory = "/home/user/audio";
      dataDir = "/home/user/.local/share/mpd";
      extraConfig = ''
          audio_output {
            type "pipewire"
            name "My PipeWire Output"
          }
        '';
    };

    # -- Programmer dvorak layout
    keyd = {
      enable = true;
      keyboards.conventional = {
        ids = [ "03eb:ff01" "0001:0001" ];
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

    emacs = {
      enable = true;
      package = pkgs.emacs29-pgtk;
    };
  };

  # https://gitlab.freedesktop.org/pipewire/pipewire/-/issues/609
  systemd.services.mpd.environment = {
    XDG_RUNTIME_DIR = "/run/user/1000";
  };

  # Turn this service off because it's just been failing on every rebuild for 6 months
  systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;
  systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;
}
