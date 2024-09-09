# Minimal hardened base system with lan/wifi and shell utilites
# This config uses impermanence
{ pkgs, lib, config, ... }: {

  imports = [ ../webFilter.nix ];

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" "repl-flake" ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
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
      PAGER = "less";
      BROWSER = "firefox";
      EDITOR = "nvim";

      XDG_CACHE_HOME  = "$HOME/.local/cache";
      XDG_CONFIG_HOME = "$HOME/.config";
      XDG_DATA_HOME   = "$HOME/.local/share";
      XDG_STATE_HOME  = "$HOME/.local/state";
      PATH = [ "$HOME/.local/bin" ];

      HISTFILE              = "${XDG_STATE_HOME}/bash/history";
      PASSWORD_STORE_DIR    = "${XDG_DATA_HOME}/pass";
      MBSYNCRC              = "${XDG_CONFIG_HOME}/isync/mbsyncrc";
      GNUPGHOME             = "${XDG_DATA_HOME}/gnupg";
      NPM_CONFIG_USERCONFIG = "${XDG_CONFIG_HOME}/npm/npmrc";
      GHCUP_USE_XDG_DIRS    = "true";
      STARSHIP_CACHE        = "${XDG_CACHE_HOME}/starship";
      CUDA_CACHE_PATH       = "${XDG_CACHE_HOME}/nv";
      WINEPREFIX            = "${XDG_DATA_HOME}/wine";
      ASAN_OPTIONS          = "halt_on_error=0";
      FZF_DEFAULT_OPTS      = "--ansi --layout reverse --color fg:-1,fg+:-1,bg:-1,bg+:-1,hl:-1,hl+:-1,query:-1,gutter:-1";
    };

    systemPackages = with pkgs; [
      xdg-utils xdg-user-dirs xdg-ninja
      p7zip unzip
      wget
      tree
      bottom
      shellcheck
      zellij
    ];

    binsh = "${pkgs.dash}/bin/dash";
  };

  programs = {
    git.enable = true;

    starship.enable = true;

    fzf = {
      fuzzyCompletion = true;
      keybindings = true;
    };
  };

  home-manager.users.user = {
    home.stateVersion = config.system.stateVersion;
  };


  users = {
    mutableUsers = false;
    groups.users = {};

    users = {
      # Set a root password, consider using initialHashedPassword instead.
      #
      # To generate a hash to put in initialHashedPassword
      # you can do this:
      # $ nix-shell --run 'mkpasswd -m SHA-512 -s' -p mkpasswd
      root.initialPassword = "pass";

      user = {
        isNormalUser = true;
        group = "users";
        home = "${config.mainDisk.persistentDataPath}/home/user";
        initialPassword = "pass";
        shell = pkgs.nushell;
        description = "The main user account";
        extraGroups = [ "wheel" ];
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

    sudo.enable = false;
    doas = {
      enable = true;
      extraRules = [ { persist = true; keepEnv = true; groups = ["wheel"]; } ];
    };

    # Required to run chrome
    chromiumSuidSandbox.enable = true;
  };

  services.clamav = {
    daemon.enable = true;
    updater.enable = true;
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
