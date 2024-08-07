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
    ivpn.enable = true;

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

  nixpkgs.config.allowUnfree = true;

  programs.steam.enable = true;
  programs.steam.gamescopeSession.enable = true;
  programs.gamemode.enable = true;
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
    home.stateVersion = config.system.stateVersion;

    home.packages = with pkgs; [
      wootility
      osu-lazer
      prismlauncher
      glfw-wayland-minecraft
      inxi
      mangohud
      openmw
      wineWowPackages.waylandFull
      # dev tools
      zig # This serves as CC
      ocaml ocamlPackages.merlin opam nodejs_22 # For neovim mason lsp install
      # keyboard
      appimage-run vial
      qmk
      # other
      # transmission libtransmission tremc
      libreoffice
      freetube
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
      firefox
      gnome.gnome-calendar
      gnome.adwaita-icon-theme
      libnotify
      unstable.halloy
      logseq
      # dependencies for hyprland screensharing
      grim slurp
      satty
      xwayland # for some reason hyprland won't pull in xwayland automatically anymore?
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
        configFile = builtins.readFile ./config/fnott/fnott.ini;
      };

      syncthing.enable = true;
    };

    programs = {
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

      fish = {
        interactiveShellInit = ''
        any-nix-shell fish --info-right | source

        set -U fish_greeting ""

        set -U fuzzy_exclude \( -name '.wine' -o -name '.steam' -o -name '.mozilla' -o -name 'qmk_firmware' -o -name 'Signal' -o -name '.nix-defexpr' -o -regex '.*\(c\|C\)ache.*' -o -name '.git' -o -name 'share' -o -name 'state' \) -prune -o

        fish_vi_key_bindings
        # This should be equivalent to fish_vi_cursor
        set fish_cursor_default block
        set fish_cursor_insert line
        set fish_cursor_replace_one underscore
        set fish_cursor_visual block

        for mode in default normal insert
          # I would just use open but right now it opens it in the browser too and segfaults.
          # I'll switch to it once I use home-manager in nixos and mimeapps work correctly
          bind -M $mode \cg "nemo ." # g for gui

          bind -M $mode \cr "printf '\n'; fuzzy-cd; commandline -f repaint" # r stand for directory in french
          bind -M $mode \ch "printf '\n'; fuzzy-history; commandline -f repaint"
          bind -M $mode \cf "printf '\n'; fuzzy-files; commandline -f repaint"
          bind -M $mode \cp "printf '\n'; fuzzy-path; commandline -f repaint"
        end

        bind -M insert \ca "accept-autosuggestion" # a for accept
        '';
        loginShellInit = ''
        if test -z "$DISPLAY" && test (tty) = /dev/tty1
          Hyprland-wrapper
        end
        '';

        functions = {
          upload = {
            description = "Upload files to 0x0.st";
            body = ''
            if test (count $argv) -eq 0
              return
            end

            for i in $argv
              if test -f $i
                set url (curl -sF "file=@$i" https://0x0.st)
                wl-copy $url
                printf "\n$i: $url copied to the clipboard\n"
              end
            end
            '';
          };

          we = {
            description = "Get the weather of desired city";
            body = "curl \"wttr.in/$argv[1]?3QF\"";
          };

          wa = {
            description = "Watch video from url";
            body = ''
            if test (count $argv) -gt 0
              mpv "$argv"
            else
              mpv "$(wl-paste)"
            end
            '';
          };

          li = {
            description = "Listen to audio from url";
            body = ''
            if test (count $argv) -gt 0
              mpv --vid=no --force-window=no "$argv"
            else
              mpv "$(wl-paste)"
            end
            '';
          };

          dla = {
            description = "Download audio from url";
            body = ''
            if test (count $argv) -gt 0
              yt-dlp -x --embed-subs --embed-thumbnail --embed-metadata --sponsorblock-remove all $argv
            else
              yt-dlp -x --embed-subs --embed-thumbnail --embed-metadata --sponsorblock-remove all (wl-paste)
            end
            '';
          };

          dlv = {
            description = "Download video from url";
            body = ''
            if test (count $argv) -gt 0
              yt-dlp --embed-subs --embed-thumbnail --embed-metadata --sponsorblock-remove all $argv
            else
              yt-dlp --embed-subs --embed-thumbnail --embed-metadata --sponsorblock-remove all (wl-paste)
            end
            '';
          };

          fix-perms = {
            description = "Fix file and folder permission recursively for all args";
            body = ''
            for path in $argv
              find $path \( -type d -perm 777 -exec chmod 755 {} \; \) -o \( -type f -perm 777 -exec chmod 644 {} \; \)
            end
            '';
          };

          fuzzy-cd = {
            description = "cd with your fuzzy finder";
            body = ''
            set dir (find -L . $fuzzy_exclude -type d -printf '%P\n' | fzf --preview='p {}' --preview-label='Directory content')/
            test -d "$dir" && c "$dir"
            '';
          };

          fuzzy-files = {
            description = "Open a flie with your fuzzy finder";
            body = ''
            if test (count $argv) -gt 0
              open $argv
            else
              set file (find -L . $fuzzy_exclude -type f -printf '%P\n' | fzf --preview='cat {}' --preview-label='File content')
              if test -n "$file"
                open $file
              end
            end
            '';
          };

          fuzzy-history = {
            description = "Copy a command from your shell history with your fuzzy finder";
            body = ''
            set element (tac $XDG_DATA_HOME/fish/fish_history | grep -a cmd | cut -c '8-' | sed -E 's/\\\{2}/\\\/g' | fzf)
            if test -n $element
              echo $element | wl-copy -n
            end
            '';
          };

          fuzzy-path = {
            description = "Copy a path with your fuzzy finder";
            body = ''
            set path $PWD/(find -L . $fuzzy_exclude \( -type f -o -type d \) -printf '%P\n' | fzf --preview='p {}' --preview-label='Directory content')
            printf $path | wl-copy
            '';
          };

          diff = {
            description = "diff with colors";
            wraps = "diff";
            body = ''
            command diff --color=auto $argv
            '';
          };

          grep = {
            description = "grep with colors";
            wraps = "grep";
            body = "command grep --color $argv";
          };

          less = {
            description = "less with colors";
            wraps = "less";
            body = "command less -R $argv";
          };

          p = {
            description = "Pretty print current directory";
            body = "ls -1hAsv --color=auto --group-directories-first $argv";
          };

          c = {
            description = "cd and print directory";
            wraps = "cd";
            body = ''
            cd $argv && p ./
            '';
          };

          m = {
            description = "make";
            wraps = "make";
            body = "command make $argv";
          };

          g = {
            description = "git";
            wraps = "git";
            body = "git $argv";
          };

          gl = {
            description = "Pretty git log";
            wraps = "git log";
            body = "git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)' $argv";
          };

          monero = {
            description = "Monero tui that respects XDG";
            body = "cd $XDG_DATA_HOME/monero && monero-wallet-cli $argv && killall monerod && cd -";
          };

          monerod = {
            description = "Monerod that respects XDG";
            body = "command monerod --data-dir $XDG_DATA_HOME/monero --prune-blockchain $argv";
          };

          nvim = {
            description = "Nvim that opens current dir if no files are given";
            body = ''
            if test -z $argv
              command nvim .
            else
              command nvim $argv
            end
            '';
          };

        };

        enable = true;
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
