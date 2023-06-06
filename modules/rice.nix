# Wayland hyprland config
{ pkgs, ... }: {
  imports = [ ./base.nix ];

  users = {
    mutableUsers = false;

    users = {
      # Set a root password, consider using initialHashedPassword instead.
      #
      # To generate a hash to put in initialHashedPassword
      # you can do this:
      # $ nix-shell --run 'mkpasswd -m SHA-512 -s' -p mkpasswd
      root.initialPassword = "pass";

      user = {
        packages = with pkgs; [ # mainly stuff for the wayland compositor
          qmk
          waydroid
          transmission libtransmission tremc
          swaybg eww-wayland socat jq
          ncmpcpp pulsemixer pamixer easyeffects
          imv zathura mpv
          cowsay fortune
          ffmpeg yt-dlp-light
          firefox
          foot
          fnott libnotify
          wlsunset
          swaylock-effects
          cinnamon.nemo
          ydotool
          wl-clipboard
          newsboat
          wofi
          qrencode
          signal-desktop
          qalculate-gtk
          emacs
          gnome.gnome-calendar
          fontconfig
          osu-lazer-bin gamemode
          jdk
          libreoffice
          brightnessctl
        ];

        isNormalUser = true;
        home = "/home/user";
        initialPassword = "pass";
        description = "The main user account";
        shell = pkgs.fish;
        extraGroups = [ "wheel" ];
      };
    };
  };

  fonts.fonts = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    nerdfonts
  ];

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

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
  };

  # https://gitlab.freedesktop.org/pipewire/pipewire/-/issues/609
  systemd.services.mpd.environment = {
      XDG_RUNTIME_DIR = "/run/user/1000";
  };
}
