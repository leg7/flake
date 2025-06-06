# Minimal hardened base system with lan/wifi and shell utilites
# This config uses impermanence
{ pkgs, lib, config, ... }: {

  imports = [ ../../modules/webFilter.nix ];

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
    trustedUsers = [ "root" "@wheel" ];
  };

  documentation.dev.enable = true;

  environment = {
    persistence."${config.mainDisk.persistentDataPath}" = {
      hideMounts = true;

      directories = [
        "/home"
        "/var"
        "/etc/opt/ivpn/mutable"
      ];

      files = [
        "/etc/machine-id"
        "/etc/ssh/ssh_host_ed25519_key.pub"
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_rsa_key.pub"
        "/etc/ssh/ssh_host_rsa_key"
      ];
    };

    sessionVariables = rec {
      # CLI env
      PAGER = "less";
      EDITOR = "nvim";

      ASAN_OPTIONS          = "halt_on_error=0";
      FZF_DEFAULT_OPTS      = "--ansi --layout reverse --color fg:-1,fg+:-1,bg:-1,bg+:-1,hl:-1,hl+:-1,query:-1,gutter:-1";
      STARSHIP_LOG          = "error"; # workaround for nixos incorrectly generating the starship config and starship warning about it (24.11)

      # Make programs use xdg dirs by default
      XDG_CACHE_HOME  = config.users.users.user.home + "/.local/cache";
      XDG_CONFIG_HOME = config.users.users.user.home + "/.config";
      XDG_DATA_HOME   = config.users.users.user.home + "/.local/share";
      XDG_STATE_HOME  = config.users.users.user.home + "/.local/state";
      PATH = [ (config.users.users.user.home + "/.local/bin") "${XDG_DATA_HOME}/npm/bin" ];

      ZDOTDIR               = "${XDG_CONFIG_HOME}/zsh";
      PASSWORD_STORE_DIR    = "${XDG_DATA_HOME}/pass";
      MBSYNCRC              = "${XDG_CONFIG_HOME}/isync/mbsyncrc";
      GNUPGHOME             = "${XDG_DATA_HOME}/gnupg";
      NPM_CONFIG_USERCONFIG = "${XDG_CONFIG_HOME}/npm/npmrc";
      GHCUP_USE_XDG_DIRS    = "true";
      STARSHIP_CACHE        = "${XDG_CACHE_HOME}/starship";
      CUDA_CACHE_PATH       = "${XDG_CACHE_HOME}/nv";
      WINEPREFIX            = "${XDG_DATA_HOME}/wine";
      CARGO_HOME            = "${XDG_DATA_HOME}/cargo";
      ANDROID_USER_HOME     = "${XDG_DATA_HOME}/android";
      GRADLE_USER_HOME      = "${XDG_DATA_HOME}/gradle";
      LEIN_HOME             = "${XDG_DATA_HOME}/lein";
      _JAVA_OPTIONS         = "-Djava.util.prefs.userRoot=${XDG_CONFIG_HOME}/java";

      # DE env
      _JAVA_AWT_WM_NONREPARENTING = 1;
      BROWSER = "zen";
    };

    systemPackages = with pkgs; [
      fd
      tealdeer
      xdg-utils xdg-user-dirs xdg-ninja
      p7zip unzip
      wget
      tree
      bottom
      shellcheck
      starship
      file
      nix-tree
      clang
    ];

    binsh = "${pkgs.dash}/bin/dash";
  };

  programs = {
    zsh = {
      enable = true;
      enableGlobalCompInit = true;
      enableCompletion = true;
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;

      shellAliases = {
        l = "ls -lhv --group-directories-first";
        ll = "ls -lAhv --group-directories-first";
        nr = "sudo nixos-rebuild switch --flake '.#eleum' --accept-flake-config";
        nt = "sudo nixos-rebuild test --flake '.#eleum' --accept-flake-config";
        g = "git";
        gd = "git diff";
        gds = "git diff --staged";
        gc = "git commit";
        gca = "git commit --amend";
        gs = "git status";
        gl = "git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)' --all";
      };

      histSize = 10000;
      histFile = "${config.environment.sessionVariables.XDG_STATE_HOME}/zsh/history";

      interactiveShellInit = ''
        bindkey -v
        bindkey -v '^?' backward-delete-char

        fcd()
        {
          source fuzzy-change-directory
          zle reset-prompt
        }
        zle -N fcd
        bindkey '^w' fcd

        fuzzy-copy-path_widget() fuzzy-copy-path
        zle -N fuzzy-copy-path_widget
        bindkey '^p' fuzzy-copy-path_widget

        fuzzy-xdg-open_widget() fuzzy-xdg-open
        zle -N fuzzy-xdg-open_widget
        bindkey '^f' fuzzy-xdg-open_widget

        fuzzy-copy-history_widget() fuzzy-copy-history
        zle -N fuzzy-copy-history_widget
        bindkey '^h' fuzzy-copy-history_widget
      '';

      loginShellInit = ''
        if [ "$TTY" = "/dev/tty1" ]; then
                river
        fi
      '';
    };

    starship.enable = true;

    git.enable = true;

    fzf = {
      fuzzyCompletion = true;
      keybindings = true;
    };
  };

  home-manager.users.user.home.stateVersion = config.system.stateVersion;

  users = {
    mutableUsers = false;
    groups.users = {};
    defaultUserShell = pkgs.zsh;

    users = {
      root.hashedPassword = "$2b$05$gMb04I4jVLgvFhM9G2Ny9emHGxhjQX1f/.0xsaLKJW1E.xijzPyLW";

      user = {
        isNormalUser = true;
        group = "users";
        home = "${config.mainDisk.persistentDataPath}/home/user";
        useDefaultShell = true;
        hashedPassword = "$2b$05$VhAP0kczmeqw1yXlQmvCk.5cDzmB6rnq/oFVudupkvHqrYdrGNaay";
        description = "The main user account";
        extraGroups = [ "wheel" "kvm" "libvirtd" ];
      };
    };
  };

  systemd.network.enable = true;
  networking = {
    dhcpcd.enable = false;
    useNetworkd = true;

    # I haven't reseached IPv6 security & privacy implications so I disable it
    enableIPv6 = false;

    firewall = {
      enable = true;
      allowedTCPPorts = [];
      allowedUDPPorts = [];
    };

    wireless.iwd = {
      enable = true;
      settings = {
        General = {
          EnableNetworkConfiguration = true; # Use systemd instead of dhcpcd
          AddressRandomization = "network";
        };
        Network.NameResolvingService = "systemd";
      };
    };
  };

  services = {
    upower.enable = true;

    timesyncd.enable = true;

    resolved = {
      enable = true;
      # I have to set this because I'm in a uni dorm and the wifi connection portal won't open
      extraConfig = ''
          LLMNR=no
          ReadEtcHosts=yes
          DNSSEC=no
          ResolveUnicastSingleLabel=yes
        '';
    };

    openssh = {
     enable = true;
     ports = [ 727 ];
     allowSFTP = false;
     settings = {
       PasswordAuthentication = false;
       KbdInteractiveAuthentication = false;
       challengeResponseAuthentication = false;
     };
     extraConfig = ''
       AllowTcpForwarding yes
       X11Forwarding no
       AllowAgentForwarding no
       AllowStreamLocalForwarding no
       AuthenticationMethods publickey
     '';
    };
  };

  console = {
    earlySetup = true;
    packages = [ pkgs.spleen ];
    font = "spleen-12x24";
  };

  # -------- some hardening taken from the hardened profile --------

  environment.memoryAllocator.provider = lib.mkDefault "graphene-hardened";

  nix.settings.allowed-users = [ "@wheel" ];
  security = {
    lockKernelModules = lib.mkDefault true; # This is anoying for dynamic systems like a laptop you dock, turn it off if some of your devices don't connect
    protectKernelImage = true;
    forcePageTableIsolation = true;

    # This is required by podman to run containers in rootless mode.
    unprivilegedUsernsClone = config.virtualisation.containers.enable;

    virtualisation.flushL1DataCache = "always";

    apparmor = {
      enable = true;
      killUnconfinedConfinables = true;
    };

    sudo = {
      enable = true;
      extraConfig = ''
      Defaults timestamp_timeout=60
      '';
    };

    # Required to run chrome
    chromiumSuidSandbox.enable = true;
  };

  boot = {
    kernelPackages = lib.mkOverride 950 pkgs.linuxPackages_hardened;

    kernelParams = [
      # Slab/slub sanity checks, redzoning, and poisoning
      "slub_debug=FZP"

      # Overwrite free'd memory
      "page_poison=1"

      # Enable page allocator randomization
      "page_alloc.shuffle=1"

      # Go into s3 sleep, not actually hardening
      "mem_sleep_default=deep"
    ];

    blacklistedKernelModules = [
      # Obscure network protocols
      "ax25"
      "netrom"
      "rose"

      # Old or rare or insufficiently audited filesystems
      "adfs"
      "affs"
      "bfs"
      "befs"
      "cramfs"
      "efs"
      "erofs"
      "exofs"
      "freevxfs"
      "hfs"
      "hpfs"
      "jfs"
      "minix"
      "nilfs2"
      "omfs"
      "qnx4"
      "qnx6"
      "sysv"
      "ufs"
    ];

    kernel.sysctl = {
      # Restrict ptrace() usage to processes with a pre-defined relationship
      # (e.g., parent/child)
      "kernel.yama.ptrace_scope" = lib.mkOverride 500 1;

      # Hide kptrs even for processes with CAP_SYSLOG
      "kernel.kptr_restrict" = lib.mkOverride 500 2;

      # Disable bpf() JIT (to eliminate spray attacks)
      "net.core.bpf_jit_enable" = false;

      # Disable ftrace debugging
      "kernel.ftrace_enabled" = false;

      # Enable strict reverse path filtering (that is, do not attempt to route
      # packets that "obviously" do not belong to the iface's network; dropped
      # packets are logged as martians).
      "net.ipv4.conf.all.log_martians" = true;
      "net.ipv4.conf.all.rp_filter" = "1";
      "net.ipv4.conf.default.log_martians" = true;
      "net.ipv4.conf.default.rp_filter" = "1";

      # Ignore broadcast ICMP (mitigate SMURF)
      "net.ipv4.icmp_echo_ignore_broadcasts" = true;

      # Ignore incoming ICMP redirects (note: default is needed to ensure that the
      # setting is applied to interfaces added after the sysctls are set)
      "net.ipv4.conf.all.accept_redirects" = false;
      "net.ipv4.conf.all.secure_redirects" = false;
      "net.ipv4.conf.default.accept_redirects" = false;
      "net.ipv4.conf.default.secure_redirects" = false;
      "net.ipv6.conf.all.accept_redirects" = false;
      "net.ipv6.conf.default.accept_redirects" = false;

      # Ignore outgoing ICMP redirects (this is ipv4 only)
      "net.ipv4.conf.all.send_redirects" = false;
      "net.ipv4.conf.default.send_redirects" = false;
    };
  };
}
