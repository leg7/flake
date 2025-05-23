{ pkgs, lib, config, inputs, ... }: {
  imports = [ ../base/base.nix ];

  fonts = {
    enableDefaultPackages = true;

    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      # nerd-fonts.NerdFontsSymbolsOnly # This will be how to do it in release 25
      (nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; })
    ];

    fontconfig.defaultFonts = {
      serif = [ "Noto Serif" ];
      sansSerif = [ "Noto Sans" ];
      monospace = [ "Red Hat Mono" "Symbols Nerd Font" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };

  services = {
    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
      jack.enable = true;
      extraConfig.pipewire = {
        "10-clock-rate" = {
          "context.properties.default.clock" = {
            "rate" = 48000;
            "quantum" = 512;
          };
        };
      };
    };

    getty.autologinUser = "user";

    mpd = {
      enable = true;
      musicDirectory = "/home/user/audio";
      dataDir = "/home/user/.local/share/mpd";
      user = "user";
      group = "users";
      extraConfig = ''
      audio_output {
        type "pipewire"
        name "My PipeWire Output"
      }
      '';
    };
  };

  programs.river.enable = true;
  services.seatd.enable = true;
  programs.adb.enable = true; # For connecting android devices
  users.users.user.extraGroups = [ "seat" "adbusers" ];

  services.ratbagd.enable = true; # for Piper (configuring mice)

  # for gnome calendar to work
  programs.dconf.enable = true;
  services.gnome.evolution-data-server.enable = true;

  # Get fast kvm qemu virtual machines
  programs.virt-manager.enable = true;
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
      ovmf = {
        enable = true;
        packages = [(pkgs.OVMF.override {
          secureBoot = true;
          tpmSupport = true;
        }).fd];
      };
    };
  };

  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "user" ];

  programs.gnupg.agent.enable = true;

  programs = {
    steam = {
      enable = true;
      gamescopeSession.enable = true;
    };

    gamemode.enable = true;
    gamescope.enable = true;
  };

  nixpkgs.config.packageOverrides = pkgs: {
    steam = pkgs.steam.override {
      extraPkgs = pkgs: with pkgs; [
        pango
        libthai
        harfbuzz
      ];
    };

    heroic = pkgs.heroic.override {
      extraPkgs = pkgs: with pkgs; [
        gamescope
        gamemode
        mangohud
      ];
    };
  };

  documentation.dev.enable = true;

  programs.nix-ld.enable = true;

  home-manager.backupFileExtension = "backup5";
  home-manager.users.user = {
    home = {
      packages = with pkgs; [
        # Gaming
        wootility
        osu-lazer
        prismlauncher glfw-wayland-minecraft
        mangohud
        openmw
        wineWowPackages.waylandFull winetricks
        heroic
        # unstable.emulationstation-de # Currently broken

        # Dev tools, lsps (mason doesn't work on nixos and the lsps don't work if installed directly in a devShell)
        man-pages man-pages-posix
        pandoc
        # LSPs
        llvmPackages_19.clang-tools
        python312Packages.python-lsp-server
        haskell-language-server
        asm-lsp
        nixd
        lua-language-server
        jdt-language-server
        rust-analyzer
        nodePackages.bash-language-server
        emmet-ls
        android-file-transfer

        # Interactive programs
        neomutt mutt-wizard gnupg pinentry-all pass isync notmuch lynx abook

        gxplugins-lv2 guitarix
        gmetronome

        ncmpcpp mpc-cli
        helvum
        pulsemixer
        easyeffects

        imv
        nemo
        signal-desktop
        gnome-calendar
        halloy
        qbittorrent
        qalculate-gtk
        vial
        diskonaut
        neovide tree-sitter
        taskwarrior3 vit
        unstable.logseq
        piper

        # Wayland wm "deps"
        inputs.zen-browser.packages."${system}".twilight rivercarro
        yambar pamixer
        fuzzel
        appimage-run
        ffmpeg yt-dlp-light
        adwaita-icon-theme
        wl-clipboard
        lswt xorg.xlsclients
        brightnessctl wlsunset
        kanshi swayidle swaylock-effects wlr-randr
        wlogout
        libnotify
        qrencode
        swaybg
        grim slurp satty wl-color-picker # for screenshots
        xwayland
        jq # for scripts
      ];

      preferXdgDirectories = true;

      pointerCursor = {
        name = "Banana";
        size = 32;
        package = pkgs.banana-cursor;
        x11.enable = true;
        gtk.enable = true;
      };
    };

    gtk = {
      enable = true;
      cursorTheme = {
        name = "Banana";
        size = 32;
        package = pkgs.banana-cursor;
      };
    };

    xdg = {
      enable = true;

      cacheHome  = config.environment.sessionVariables.XDG_CACHE_HOME;
      configHome = config.environment.sessionVariables.XDG_CONFIG_HOME;
      dataHome   = config.environment.sessionVariables.XDG_DATA_HOME;
      stateHome  = config.environment.sessionVariables.XDG_STATE_HOME;

      configFile."all" = {
        source = ./xdg.configFile.all;
        recursive = true;
        target = "./";
      };

      dataFile."all" = {
        source = ./xdg.dataFile.all;
        recursive = true;
        target = "./";
      };

      # TODO: Add ~/.local/bin scripts

      # TODO
      # desktopEntries = {
      #
      # }

      mime.enable = true;
      mimeApps = {
        enable = true;
        defaultApplications = {
          "text/x-shellscript"       = ["text.desktop"];
          "x-scheme-handler/magnet"  = ["torrent.desktop"];
          "application/x-bittorrent" = ["torrent.desktop"];
          "x-scheme-handler/mailto"  = ["mail.desktop"];
          "text/plain"               = ["text.desktop"];
          "application/postscript"   = ["pdf.desktop"];
          "application/pdf"          = ["pdf.desktop"];
          "application/epub+zip"     = ["pdf.desktop"];
          "image/png"                = ["img.desktop"];
          "image/jpeg"               = ["img.desktop"];
          "image/gif"                = ["img.desktop"];
          "application/rss+xml"      = ["rss.desktop"];
          "video/x-matroska"         = ["video.desktop"];
          "video/mp4"                = ["video.desktop"];
          "x-scheme-handler/lbry"    = ["lbry.desktop"];
          "inode/directory"          = ["file.desktop"];
        };
      };

      portal = {
        enable = true;
        extraPortals = with pkgs; [ xdg-desktop-portal xdg-desktop-portal-wlr ];
        config.common.default = "*";
      };

      userDirs = {
        enable = true;
        createDirectories = true;

        desktop     = "${config.home-manager.users.user.home.homeDirectory}";
        documents   = "${config.home-manager.users.user.home.homeDirectory}/documents";
        download    = "${config.home-manager.users.user.home.homeDirectory}";
        music       = "${config.home-manager.users.user.home.homeDirectory}/audio/music";
        pictures    = "${config.home-manager.users.user.home.homeDirectory}/pics";
        publicShare = null;
        templates   = "${config.home-manager.users.user.home.homeDirectory}";
        videos      = "${config.home-manager.users.user.home.homeDirectory}";
      };
    };

    services = {
      fnott = {
        enable = true;
        settings = {
          main = {
            edge-margin-vertical = 5;
            edge-margin-horizontal = 5;
            max-icon-size = 64;
            selection-helper = "fuzzel";
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

      mpv = {
        enable = true;
        bindings = {
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
          hwdec = "auto";
          vo = "gpu-next";
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
            font = "monospace:size=13";
            dpi-aware = "no";
            pad = "3x2 center";
            initial-window-size-pixels = "700x500";
            font-size-adjustment = "1";
          };

          scrollback.lines = 10000;

          colors = {
            alpha = "0.91";
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
            font-increase = "Control+plus";
            font-decrease = "Control+minus";
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
