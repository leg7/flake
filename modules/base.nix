# Minimal base system with lan/wifi and shell utilites
{ pkgs, ... }: {
  environment = {
    sessionVariables = rec {
      EDITOR = "vim";
      PAGER = "less";
      BROWSER = "firefox";

      XDG_CACHE_HOME  = "$HOME/.local/cache";
      XDG_CONFIG_HOME = "$HOME/.config";
      XDG_DATA_HOME   = "$HOME/.local/share";
      XDG_STATE_HOME  = "$HOME/.local/state";
      PATH = [ "$HOME/.local/bin" ];

      VIMINIT               = "set nocp | source $XDG_CONFIG_HOME/vim/vimrc";
      GNUPGHOME             = "$XDG_DATA_HOME/gnupg";
      WGETRC                = "$XDG_CONFIG_HOME/wget/wgetrc";
      GOPATH                = "$XDG_DATA_HOME/go";
      GOMODCACHE            = "$XDG_CACHE_HOME/go/mod";
      RUSTUP_HOME           = "$XDG_DATA_HOME/rustup";
      CARGO_HOME            = "$XDG_DATA_HOME/cargo";
      STACK_ROOT            = "$XDG_DATA_HOME/stack";
      NPM_CONFIG_USERCONFIG = "$XDG_CONFIG_HOME/npm/npmrc";
      NUGET_PACKAGES        = "$XDG_CACHE_HOME/NuGetPackages";
    };

    systemPackages = with pkgs; [
      xdg-utils xdg-user-dirs xdg-ninja
      p7zip
      keyd
      vim
      wget
      fzf
      tree
      git
      python39
      bottom
      brightnessctl
      shellcheck
    ];

    binsh = "${pkgs.dash}/bin/dash";
  };

  programs.fish.enable = true;

  security = {
    doas = {
      enable = true;
      extraRules = [ { persist = true; keepEnv = true; groups = ["wheel"]; } ];
    };

    sudo.enable = false;
  };

  # --- Networking ---

  systemd.network = {
    enable = true;

    networks."10-wired" = {
      matchConfig.Type = "ether";
      networkConfig.DHCP = "ipv4";
      dhcpV4Config = { UseDomains = true; };
      linkConfig.RequiredForOnline = "no";
    };
  };

  networking = {
    wireless.iwd = {
      enable = true;
      settings = {
        General.EnableNetworkConfiguration = true; # This replaces dhcpcd
        Network.NameResolvingService = "systemd";
      };
    };

    hostName = "eleum";
    enableIPv6 = false;
    dhcpcd.enable = false;
  };

  services.resolved = {
    enable = true;
    extraConfig = ''
        LLMNR=no
        ReadEtcHosts=no
        DNSSEC=no
        ResolveUnicastSingleLabel=yes
      '';
  };
}
