{ pkgs, lib, config, ... }: {
  imports = [ ../base.nix ];

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
      monospace = [ "Iosevka Nerd Font Mono" "Symbols Nerd Font" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };

  services = {
    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };

    getty.autologinUser = "user";
  };

  # for gnome calendar to work
  programs.dconf.enable = true;
  services.gnome.evolution-data-server.enable = true;

  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "user" ];

  programs.gnupg.agent.enable = true;

  nixpkgs.config.allowUnfree = true;
  programs = {
    steam = {
      enable = true;
      gamescopeSession.enable = true;
    };
    gamemode.enable = true;
  };
  nixpkgs.config.packageOverrides = pkgs: {
    steam = pkgs.steam.override {
      extraPkgs = pkgs: with pkgs; [
        pango
        libthai
        harfbuzz
      ];
    };
  };

  home-manager.users.user = {
    home.packages = with pkgs; [
      wootility
      osu-lazer
      prismlauncher glfw-wayland-minecraft
      mangohud
      openmw
      wineWowPackages.waylandFull winetricks
      # dev tools, lsps (mason doesn't work on nixos and the lsps don't work if installed directly in a devShell)
      clang clang-tools
      nixd
      lua-language-server
      jdt-language-server
      rust-analyzer
      emmet-ls
      zig # This serves as CC
      ocaml ocamlPackages.merlin opam nodejs_22 # For neovim mason lsp install
      # haskellPackages.hls
      asm-lsp
      # keyboard
      appimage-run
      vial
      qmk
      # other
      libreoffice
      swaybg socat jq
      ncmpcpp pavucontrol helvum pulsemixer pamixer easyeffects
      imv
      ffmpeg yt-dlp-light
      wlsunset
      cinnamon.nemo
      ydotool wl-clipboard
      newsboat
      wofi
      qrencode
      qalculate-gtk
      brightnessctl
      signal-desktop
      gnome.gnome-calendar
      gnome.adwaita-icon-theme
      libnotify
      unstable.halloy
      logseq
      qbittorrent
      # dependencies for hyprland screensharing
      grim slurp
      satty
      xwayland # for some reason hyprland won't pull in xwayland automatically anymore?
      neomutt mutt-wizard gnupg pinentry-all pass isync notmuch lynx abook
    ];

    wayland.windowManager.hyprland = {
      enable = true;
      extraConfig = builtins.readFile ./config/hypr/hyprland.conf;
    };

    services = {
      mpd = {
        enable = true;
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

      fnott = {
        enable = true;
        settings = {
          main = {
            edge-margin-vertical = 5;
            edge-margin-horizontal = 5;
            max-icon-size = 64;
            selection-helper = "wofi";
            background = "101623ff";
            border-color = "a6c18bff";
            border-size = 2;
            title-font = "monospace:pixelsize=14";
            title-color = "fff2f0ff";
            title-format = "";
            summary-font = "monospace:pixelsize=14";
            summary-color = "fff2f0ff";
            summary-format = "<b>%s</b>\n";
            body-font = "monospace:pixelsize=14";
            body-color = "fff2f0ff";
            body-format = "%b";
            max-timeout = "20";
            default-timeout = "10";
            play-sound = "pw-play \${filename}";
            sound-file = "/home/leo/.local/share/alerts/default";
          };
          low = {
            border-color = "88a4ddff";
          };
          normal = {
            border-color = "a6c18bff";
          };
          critical = {
            border-color = "ff4766ff";
            border-size = "3";
          };
        };
      };

      syncthing.enable = true;
    };

    programs = {
      firefox = {
        enable = true;
        policies = {
          DownloadDirectory = "\${home}";
          AppAutoUpdate = false;
          AutofillAddressEnabled = false;
          AutofillCreditCardEnabled = false;
          Behavior = "reject-tracker-and-partition-foreign";
          SanitizeOnShutdown = {
            Cache = true;
            Cookies = true;
            History = true;
            Sessions = true;
            SiteSettings = true;
            OfflineApps = true;
          };
          DisableFirefoxAccounts = true;
          DisableFirefoxStudies = true;
          DisableFormHistory = true;
          DisableMasterPasswordCreation = true;
          DisablePocket = true;
          DisableTelemetry = true;
          EnableTrackingProtection = true;
          OfferToSaveLogins = false;
          PasswordManagerEnabled = false;
        };
      };

      java = {
        enable = true;
        package = pkgs.jdk21;
      };

      obs-studio = {
        enable = true;
        plugins = with pkgs.obs-studio-plugins; [
          wlrobs
          obs-gstreamer
          obs-vaapi
          obs-nvfbc
          obs-vkcapture
        ];
      };

      newsboat = {
        # TODO: Use module correctly
        enable = true;
        extraConfig = builtins.readFile ./config/newsboat/config;
      };

      zathura = {
        enable = true;

        options = {
          sandbox = "none";
          statusbar-h-padding = 0;
          statusbar-v-padding = 0;
          page-padding = 1;
          selection-clipboard = "clipboard";
          recolor-lightcolor = "#262626";
          recolor-darkcolor = "#b2b3b3";
          database = "sqlite";
        };

        mappings = {
          u = "scroll half-up";
          d = "scroll half-down";
          D = "toggle_page_mode";
          r = "reload";
          R = "rotate";
          K = "zoom in";
          J = "zoom out";
          i = "recolor";
          p = "print";
          g = "goto top";
        };
      };

      wofi = {
        settings = {
          width = "30%";

          key_up = "Control_R-p";
          key_down = "Control_R-n";
          key_right = "Control_L-l";
          key_left = "Control_L-h";

          parse_search = "true";
        };

        style = builtins.readFile ./config/wofi/style.css;
      };

      emacs = {
       enable = true;
       extraConfig = builtins.readFile ./config/emacs/init.el;
      };

      eww = {
        enable = true;
        configDir = ./config/eww;
      };

      mpv = {
        enable = true;
        bindings = {
          l = "seek 5";
          h = "seek -5";
          j = "seek -60";
          k = "seek 60";
          S = "cycle sub";
        };
        config = {
          volume = "100";

          msg-color= true; # color log messages on terminal
          term-osd-bar= true; # displays a progress bar on the terminal

          save-position-on-quit = "yes";
          cache = "yes";
          demuxer-max-bytes = "1800M";
          demuxer-max-back-bytes = "1200M";
          really-quiet = true;

          sub-auto = "fuzzy";
          sub-bold = "yes";
          hwdec = "vaapi";
          audio-channels = "stereo";
        };
      };

      foot = {
        enable = true;
        server.enable = true;
        settings = {
          main = {
            app-id = "foot";
            title = "foot";
            locked-title = "no";
            font = "monospace:size=12";
            dpi-aware = "no";
            pad = "3x2 center";
            # font-bold=<bold variant of regular font>
            # font-italic=<italic variant of regular font>
            # font-bold-italic=<bold+italic variant of regular font>
            # font-size-adjustment=0.5
            # line-height=<font metrics>
            # letter-spacing=0
            # horizontal-letter-offset=0
            # vertical-letter-offset=0
            # underline-offset=<font metrics>
            # underline-thickness=<font underline thickness>
            # box-drawings-uses-font-glyphs=no

            # initial-window-size-pixels=700x500  # Or,
            # initial-window-size-chars=<COLSxROWS>
            # initial-window-mode=windowed
            # resize-delay-ms=0

            # notify=notify-send -a ${app-id} -i ${app-id} ${title} ${body}
          };

          scrollback.lines = 10000;

          colors = {
            alpha = "0.95";
            background = "101623";
            foreground = "FF99BB";
            # black, red, green, yellow, blue, magenta, cyan, white
            regular0 = "101623";
            regular1 = "FF4766";
            regular2 = "a6c18b";
            regular3 = "fb8950";
            regular4 = "88a4dd";

            regular5 = "e83430";
            regular6 = "88a4dd";

            regular7 = "ff99bb";

            # Bright colors (color palette 8-15)
            bright0 = "304469";
            bright1 = "FF7A91";
            bright2 = "BFD2AC";
            bright3 = "FCAB82";
            bright4 = "AFC2E9";

            bright5 = "ED615E";
            bright6 = "AFC2E9";

            bright7 = "FFCCDD";

            selection-foreground = "ff99bb";
            selection-background = "202D46";
            # jump-labels = "<regular0> <regular3>          # black-on-yellow";
            # scrollback-indicator = "<regular0> <bright4>  # black-on-bright-blue";
            # search-box-no-match = "<regular0> <regular1>  # black-on-red";
            # search-box-match = "<regular0> <regular3>     # black-on-yellow";
            urls = "8be9fd";
          };

          key-bindings = {
            scrollback-up-half-page = "Mod1+u";
            scrollback-down-half-page = "Mod1+d";
            font-increase = "Control+Shift+k";
            font-decrease = "Control+Shift+j";
            show-urls-persistent = "Control+Shift+f";
          };
          tweak.grapheme-width-method = "double-width";
        };
      };

      neovim = {
        enable = true;
        defaultEditor = true;
        extraLuaConfig = builtins.readFile ./config/nvim/init.lua;
      };

      git = {
        enable = true;
        userEmail = "dev@leonardgomez.xyz";
        userName = "leg7";
        extraConfig.init.defaultBranch = "main";
        extraConfig.push.autoSetupRemote = "true";
      };
    };

  };

  # https://gitlab.freedesktop.org/pipewire/pipewire/-/issues/609
  systemd.services.mpd.environment = {
    XDG_RUNTIME_DIR = "/run/user/1000";
  };

  # Turn this service off because it's just been failing on every rebuild for 6 months
  systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;
  systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;

  # These settings cause firefox to crash or not open so we revert them
  boot.kernelPackages = lib.mkOverride 50 pkgs.linuxPackages;
  environment.memoryAllocator.provider = lib.mkOverride 50 "libc";

  # This is to hotplug devices
  security.lockKernelModules = lib.mkOverride 50 false;
}
