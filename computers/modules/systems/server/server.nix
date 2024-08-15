{ lib, pkgs, config, ... }: {
  imports = [ ../base.nix ];

  networking.wireless.iwd.enable = lib.mkForce false;
  hardware.bluetooth.enable = lib.mkForce false;

  networking.firewall = {
      enable = true;
      allowedUDPPorts = [];
      allowedTCPPorts = [ 727 80 443 ]; # ssh, http, https
  };

  environment.systemPackages = with pkgs; [
    zola
  ];

  security.acme = {
    acceptTerms = true;
    defaults.email = "leonard.gomez@protonmail.com";
    defaults.webroot = "/var/lib/acme/acme-challenge";
    certs = {
      "leonardgomez.xyz".extraDomainNames = [
        "leonardgomez.xyz"
        "www.leonardgomez.xyz"
        "git.leonardgomez.xyz"
        "vaultwarden.leonardgomez.xyz"
      ];
    };
  };

  services = {
    # kavita.enable = true;
    # TODO: Use nix secrets
    # kavita.tokenKeyFile = ./kavita.tokenKeyFile;

    minecraft-server = {
      enable = true;
      eula = true;
      openFirewall = true;
      declarative = true;

      serverProperties = {
        server-port = 43000;
        difficulty = 3;
        gamemode = 1;
        max-players = 3;
        motd = "leonardgomez.xyz minecraft server";
        white-list = false;
        enable-rcon = false;
      };

      jvmOpts = "-Xms1G -Xmx1G";

      whitelist = {
        Finxert = "88637aa6-6d7c-49b0-b6b0-d72dde73b45f";
        davidv1201 = "0178944f-665a-41c4-ae52-131e5a86bd6a";
      };
    };

    # accessible through nginx reverse proxy
    vaultwarden = {
      enable = true;
      config = {
        DOMAIN = "https://vaultwarden.leonardgomez.xyz";
        SIGNUPS_ALLOWED = false;
        ROCKET_ADDRESS = "127.0.0.1";
        ROCKET_PORT = 8222;
        ROCKET_LOG = "critical";
      };
      environmentFile = ./services.vaultwarden.environmentFile;
    };

    nginx = {
      enable = true;
      package = pkgs.nginxStable.override { openssl = pkgs.libressl; };
      recommendedProxySettings = true;
      recommendedTlsSettings = true;

      virtualHosts."www.leonardgomez.xyz" = {
        addSSL = true;
        enableACME = true;
        root = "/var/www/www.leonardgomez.xyz/public";
      };

      virtualHosts."leonardgomez.xyz" = {
        addSSL = true;
        enableACME = true;
        globalRedirect = "www.leonardgomez.xyz";
      };

      virtualHosts."vaultwarden.leonardgomez.xyz" = {
        addSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.vaultwarden.config.ROCKET_PORT}";
        };
      };

    };
  };
}
