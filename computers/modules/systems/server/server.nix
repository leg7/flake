{ lib, pkgs, config, ... }: {
  imports = [ ../base/base.nix ];

  networking.wireless.iwd.enable = lib.mkForce false;
  hardware.bluetooth.enable = lib.mkForce false;

  networking.firewall = {
      enable = true;
      allowedUDPPorts = [];
      allowedTCPPorts = [ 727 80 443 ]; # ssh, http, https
  };

  environment.systemPackages = with pkgs; [
    zola
    neovim
  ];

  environment.persistence."${config.mainDisk.persistentDataPath}".files = [
    "/etc/radicale/users"
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
        "mollysocket.leonardgomez.xyz"
        "radicale.leonardgomez.xyz"
        "mail.leonardgomez.xyz"
      ];
    };
  };

  # services.stalwart-mail = {
  #   enable = true;
  #   package = pkgs.stalwart-mail;
  #   settings = {
  #     certificate."leonardgomez" = {
  #       cert = "%{file:/var/lib/acme/mail.leonardgomez.xyz/fullchain.pem}%";
  #       private-key = "%{file:/var/lib/acme/mail.leonardgomez.xyz/key.pem}%";
  #     };
  #
  #     server = {
  #       hostname = "mail.leonardgomez.xyz";
  #       tls = {
  #         certificate = "leonardgomez";
  #         enable = true;
  #         implicit = false;
  #       };
  #       listener = {
  #         "smtp-submission" = {
  #           bind = [ "[::]:587" ];
  #           protocol = "smtp";
  #         };
  #         "imap" = {
  #           bind = [ "[::]:143" ];
  #           protocol = "imap";
  #         };
  #       };
  #     };
  #
  #     session = {
  #       rcpt.directory = "in-memory";
  #       auth = {
  #         mechanisms = [ "PLAIN" ];
  #         directory = "in-memory";
  #       };
  #     };
  #
  #     jmap.directory = "in-memory";
  #     queue.outbound.next-hop = [ "local" ];
  #     directory."in-memory" = {
  #       type = "memory";
  #       users = [
  #         {
  #           name = "contact";
  #           secret = "foobar";
  #           email = [ "contact@leonardgomez.xyz" ];
  #         }
  #       ];
  #     };
  #   };
  # };

  services = {
    # kavita.enable = true;
    # TODO: Use nix secrets
    # kavita.tokenKeyFile = ./kavita.tokenKeyFile;

    radicale = {
      enable = true;
      settings = {
        server = {
          hosts = [ "127.0.0.1:5232" ];
        };
        auth = {
          type = "htpasswd";
          htpasswd_filename = "/etc/radicale/users";
          htpasswd_encryption = "bcrypt";
        };
        storage = {
          filesystem_folder = "/var/lib/radicale/collections";
        };
      };
    };

    minecraft-server = {
      enable = true;
      eula = true;
      openFirewall = true;
      declarative = true;

      serverProperties = {
        server-port = 43000;
        difficulty = 3;
        gamemode = 0;
        max-players = 10;
        motd = "leonardgomez.xyz minecraft server";
        white-list = true;
        enable-rcon = false;
      };

      jvmOpts = "-Xms1G -Xmx1G";

      whitelist = {
        Finxert = "88637aa6-6d7c-49b0-b6b0-d72dde73b45f";
        davidv1201 = "0178944f-665a-41c4-ae52-131e5a86bd6a";
        chauvy = "87a47880-bf37-4fa0-a4ad-c94ed2059561";
        ac0oustik = "f9560c8c-850c-4a47-b658-84fee5b32c64";
      };
    };

    mollysocket = {
      enable = true;
      settings = {
        allowed_uuids = [ "5663c899-15fe-428e-9ae0-cf903490f3bb" ];
        allowed_endpoints = [ "https://ntfy.sh" ];
      };
    };

    # figure out what files are not being persisted on reboot
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

      virtualHosts."mollysocket.leonardgomez.xyz" = {
        addSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.mollysocket.settings.port}";
        };
      };

      virtualHosts."radicale.leonardgomez.xyz" = {
        addSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:5232";
          extraConfig = ''
            proxy_set_header  X-Script-Name /;
            proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_pass_header Authorization;
          '';
        };
      };

    };
  };
}
