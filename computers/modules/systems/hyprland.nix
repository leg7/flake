# Wayland hyprland config
{ pkgs, lib, ... }: {
  imports = [ ./base.nix ];

  # These settings cause firefox to crash or not open so we revert them
  boot.kernelPackages = lib.mkOverride 50 pkgs.linuxPackages;
  environment.memoryAllocator.provider = lib.mkOverride 50 "libc";

  security.lockKernelModules = lib.mkOverride 50 false;

  users.users.user.packages = with pkgs; [
    steam
    osu-lazer
    prismlauncher
    libGLU
    freeglut
    jdk17
    jre17_minimal
    glfw-wayland-minecraft
    gamescope
    gamemode
    inxi
    mangohud
    wineWowPackages.waylandFull
    openmw
    zeroad
    libva-utils
    glxinfo
    # dev tools
    virtualbox
    nasm
    raylib
    cargo
    nodejs
    python311Full
    ghc haskell-language-server cabal-install
    qt5Full qtcreator
    gcc_multi gnumake cmake gdb gf valgrind
    clang-tools pkgsi686Linux.clang cling
    ocaml ocamlPackages.merlin opam
    swiPrologWithGui
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
