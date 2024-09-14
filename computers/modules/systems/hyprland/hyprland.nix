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
      zig # This serves as CC
      ocaml ocamlPackages.merlin opam nodejs_22 # For neovim mason lsp install
      # keyboard
      appimage-run
      vial
      qmk
      # other
      # transmission libtransmission tremc
      libreoffice
      swaybg socat jq
      ncmpcpp pavucontrol helvum pulsemixer pamixer easyeffects
      imv
      ffmpeg yt-dlp-light
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
      gnome.gnome-calendar
      gnome.adwaita-icon-theme
      libnotify
      unstable.halloy
      logseq
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
        configFile = ./config/fnott/fnott.ini;
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
            background = "1D2330";
            foreground = "ff99bb";

            # black, red, green, yellow, blue, magenta, cyan, white
            regular0 = "1f2228";
            regular1 = "ff4766";
            regular2 = "a6c18b";
            regular3 = "fb8950";
            regular4 = "88a4dd";

            regular5 = "e83430";
            regular6 = "88a4dd";

            regular7 = "ff99bb";

            # Bright colors (color palette 8-15)
            bright0 = "1f2228";
            bright1 = "ff4766";
            bright2 = "a6c18b";
            bright3 = "fb8950";
            bright4 = "88a4dd";

            bright5 = "e83430";
            bright6 = "88a4dd";

            bright7 = "ff99bb";

            selection-foreground = "ff99bb";
            selection-background = "303A50";
            # jump-labels=<regular0> <regular3>          # black-on-yellow
            # scrollback-indicator=<regular0> <bright4>  # black-on-bright-blue
            # search-box-no-match=<regular0> <regular1>  # black-on-red
            # search-box-match=<regular0> <regular3>     # black-on-yellow
            urls = "8be9fd";
          };

          key-bindings = {
            # scrollback-up-page=Shift+Page_Up
            # scrollback-down-page=Shift+Page_Down
            scrollback-up-half-page = "Mod1+u";
            scrollback-down-half-page = "Mod1+d";
            scrollback-up-line = "Control+k";
            scrollback-down-line = "Control+j";
            # scrollback-home=Control+g
            # clipboard-copy=Control+Shift+c XF86Copy
            # clipboard-paste=Control+Shift+v XF86Paste
            # primary-paste=Shift+Insert
            search-start = "Control+slash";
            font-increase = "Control+Shift+k";
            font-decrease = "Control+Shift+j";
            # font-reset=Control+o
            spawn-terminal = "none";
            # minimize=none
            # maximize=none
            # fullscreen=none
            # pipe-visible=[sh -c "xurls | fuzzel | xargs -r firefox"] none
            # pipe-scrollback=[sh -c "xurls | fuzzel | xargs -r firefox"] none
            # pipe-selected=[xargs -r firefox] none
            # show-urls-launch=Control+f
            #show-urls-copy=Control+o
            show-urls-persistent = "Control+Shift+f";
            # prompt-prev=Control+Shift+z
            # prompt-next=Control+Shift+x
            # unicode-input=none
            # noop=none
          };

          search-bindings = {
            # cancel=Control+g Control+c Escape
            # commit=Return
            find-next = "Control+n";
            find-prev = "Control+Shift+n";
            # cursor-left=Left Control+b
            # cursor-left-word=Control+Left Mod1+b
            # cursor-right=Right Control+f
            # cursor-right-word=Control+Right Mod1+f
            # cursor-home=Home Control+a
            # cursor-end=End Control+e
            # delete-prev=BackSpace
            # delete-prev-word=Mod1+BackSpace Control+BackSpace
            # delete-next=Delete
            # delete-next-word=Mod1+d Control+Delete
            # extend-to-word-boundary=Control+w
            # extend-to-next-whitespace=Control+Shift+w
            # clipboard-paste=Control+v Control+Shift+v Control+y XF86Paste
            # primary-paste=Shift+Insert
            # unicode-input=none
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
