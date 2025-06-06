{ lib, pkgs, config, ... }:
let domain = "leonardgomez.com";
in {
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
      "${domain}".extraDomainNames = [
        "${domain}"
        "www.${domain}"
        "git.${domain}"
        "vaultwarden.${domain}"
        "mollysocket.${domain}"
        "radicale.${domain}"
        "mail.${domain}"
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
        motd = "${domain} minecraft server";
        white-list = true;
        enable-rcon = false;
        enforce-secure-profile = false;
      };

      jvmOpts = "-Xms1G -Xmx1G";

      whitelist = {
        Finxert = "88637aa6-6d7c-49b0-b6b0-d72dde73b45f";
        davidpv1201 = "c6becb79-e11a-45a8-8ae4-2a190d0c1605";
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
      # This has to be hashed or I can't push it to git
      # environmentFile =
    };

    # figure out what files are not being persisted on reboot
    vaultwarden = {
      enable = true;
      config = {
        DOMAIN = "https://vaultwarden.${domain}";
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


      virtualHosts."www.${domain}" = {
        addSSL = true;
        enableACME = true;
        root = "/var/www/www.${domain}/public";
      };

      virtualHosts."${domain}" = {
        addSSL = true;
        enableACME = true;
        globalRedirect = "www.${domain}";
      };

      virtualHosts."vaultwarden.${domain}" = {
        addSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.vaultwarden.config.ROCKET_PORT}";
        };
      };

      virtualHosts."mollysocket.${domain}" = {
        addSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.mollysocket.settings.port}";
        };
      };

      virtualHosts."radicale.${domain}" = {
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
