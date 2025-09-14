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
    neovim
    zulu24
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
        "ntfy.${domain}"
        "radicale.${domain}"
        "mail.${domain}"
      ];
    };
  };

  mailserver = {
    enable = true;
    fqdn = "mail.${domain}";
    domains = [ "${domain}" ];

    # A list of all login accounts. To create the password hashes, use
    # nix-shell -p mkpasswd --run 'mkpasswd -sm bcrypt'
    loginAccounts = {
      "contact@${domain}" = {
        hashedPassword = "$2b$05$XLPfw9lueUXBgVZTdlBe9u/H3Nf1D3LspJGevCUwK75W9WTYGTF3S";
      };
    };

    # Use Let's Encrypt certificates. Note that this needs to set up a stripped
    # down nginx and opens port 80.
    certificateScheme = "acme-nginx";
  };

  # --- Mollysocket
  sops.secrets.mollysocket = {
    format = "dotenv";
    sopsFile = ./sops.secrets.mollysocket.sopsFile.env;
    restartUnits = [ "mollysocket.service" ];
  };
  services.mollysocket = {
    enable = true;
    settings = {
      allowed_uuids = [ "5663c899-15fe-428e-9ae0-cf903490f3bb" ];
      allowed_endpoints = [ "https://ntfy.${domain}" ];
    };
    environmentFile = config.sops.secrets.mollysocket.path;
  };

  # --- Ntfy
  sops.secrets.ntfy-sh-web-push-private-key = {
    sopsFile = ./sops.secrets.ntfy-sh-web-push-private-key.sopsFile.txt;
    restartUnits = [ "ntfy-sh.service" ];
  };
  services.ntfy-sh = {
    enable = true;
    settings = {
      base-url = "https://ntfy.leonardgomez.com";
      cache-duration = "72h";
      auth-default-access = "deny-all";
      behind-proxy = true;
      web-push-public-key = "BMc6iA6SrsI5sC0u4zHx8l9vVmRbQM-2NPF7QD8cwF6H4hs_HpfA0U8xvXjh7zacH04epzaL0iAe39XEZWTIHrY";
      web-push-private-key = config.sops.secrets.ntfy-sh-web-push-private-key;
      web-push-file = "/var/lib/ntfy-sh/webpush.db"; # or similar
      web-push-email-address = "leonard.gomez@protonmail.com";
    };
  };

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

    minecraft-servers = {
      enable = true;
      managementSystem.systemd-socket.enable = true;
      eula = true;
      openFirewall = true;

      servers = {
        vanilla = {
          enable = true;
          package = pkgs.fabricServers.fabric-1_21_6;
          jvmOpts = "-Xms2048M -Xmx2048M -XX:+UseG1GC -XX:ParallelGCThreads=4";

          serverProperties = {
            server-port = 43000;
            difficulty = 3;
            gamemode = 0;
            max-players = 10;
            motd = "${domain} minecraft server";
            white-list = true;
            enable-rcon = false;
            enforce-secure-profile = false;

            sync-chunk-writes = false;
            max-chained-neighbor-updates = 10000;
          };

          whitelist = {
            Finxert = "88637aa6-6d7c-49b0-b6b0-d72dde73b45f";
            davidpv1201 = "c6becb79-e11a-45a8-8ae4-2a190d0c1605";
            chauvy = "87a47880-bf37-4fa0-a4ad-c94ed2059561";
            ac0oustik = "f9560c8c-850c-4a47-b658-84fee5b32c64";
            zogo29 = "d6b95a11-82f4-406b-9f0a-e0661f1b5403";
            Papchy = "c0a50c7f-bac9-4c42-8717-ed5dfa3cfe68";
            TheO0o_ = "969e4664-8493-4938-9cae-fb9846654d8f";
          };

          symlinks = {
            "ops.json" = {
              value = [
                {
                  uuid = "88637aa6-6d7c-49b0-b6b0-d72dde73b45f";
                  name = "Finxert";
                  level = 4;
                  bypassesPlayerLimit = true;
                }
              ];
            };

            mods = with pkgs; linkFarmFromDrvs "mods" (builtins.attrValues {
              FabricAPI = fetchurl {
                url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/F5TVHWcE/fabric-api-0.128.2%2B1.21.6.jar";
                sha512 = "b6d0ec0aec40069cb1fa2159c126d027d7f95e3f6260a3e88ebe9c47f3cb716d1170af8e2e4ff3d4108ce5eeaea70002a889547578374d4d6dfa45755e99431e";
              };
              Lithium = fetchurl {
                url = "https://cdn.modrinth.com/data/gvQqBUqZ/versions/XWGBHYcB/lithium-fabric-0.17.0%2Bmc1.21.6.jar";
                sha512 = "a8d6a8b69ae2b10dd0cf8f8149260d5bdbd2583147462bad03380014edd857852972b967d97df69728333d8836b1e9db8997712ea26365ddb8a05b8c845c6534";
              };
              VMP = fetchurl {
                url = "https://cdn.modrinth.com/data/wnEe9KBa/versions/aWatA9pi/vmp-fabric-mc1.21.6-0.2.0%2Bbeta.7.200-all.jar";
                sha512 = "185e9ea7f7ded136cd781845a2d422fbdeb6daa04bad605b9f59c001e0b90bad6f2a1ed4ff78bcdabd0bd13f2be09c636783ee4205101f2a919ade9e64bcde98";
              };
              C2ME = fetchurl {
                url = "https://cdn.modrinth.com/data/VSNURh3q/versions/y6wodInu/c2me-fabric-mc1.21.6-0.3.4%2Balpha.0.42.jar";
                sha512 = "3d53b1dd84a036b5fb91f15a0bc538e6f2a4ac207c4749ab1ab874972178bc2cc20f1fe1c2f8c08e9eef0a66b4f6b2de22314d94d0498abcf025219dfc69d756";
              };
              FerriteCore = fetchurl {
                url = "https://cdn.modrinth.com/data/uXXizFIs/versions/CtMpt7Jr/ferritecore-8.0.0-fabric.jar";
                sha512 = "131b82d1d366f0966435bfcb38c362d604d68ecf30c106d31a6261bfc868ca3a82425bb3faebaa2e5ea17d8eed5c92843810eb2df4790f2f8b1e6c1bdc9b7745";
              };
              Krypton = fetchurl {
                url = "https://cdn.modrinth.com/data/fQEb0iXm/versions/neW85eWt/krypton-0.2.9.jar";
                sha512 = "2e2304b1b17ecf95783aee92e26e54c9bfad325c7dfcd14deebf9891266eb2933db00ff77885caa083faa96f09c551eb56f93cf73b357789cb31edad4939ffeb";
              };
              Noisium = fetchurl {
                url = "https://cdn.modrinth.com/data/KuNKN7d2/versions/V9mMIy0f/noisium-fabric-2.7.0%2Bmc1.21.6.jar";
                sha512 = "80cc286f3a51b2d12304ef6a44f84c11d67cedec1a02fbaf59e2e816d9b5f0abd17cc6b5a0ca5880935e9dadfea3b951b790ee1e54300c009bc419c1c7451785";
              };
              RecipeCooldown = fetchurl {
                url = "https://cdn.modrinth.com/data/7LEWYKTV/versions/oe5KEgWu/RecipeCooldown-1.0.0.jar";
                sha512 = "84d52e7dbb2aa780b1ba0ec436a58135b1af53f5612bdfeaafb701df10f91df09fad15c7b2dc23552a0a362bc38fd65765f6e82737a45faa163b8dbe89fe7101";
              };
              Chunky = fetchurl {
                url = "https://cdn.modrinth.com/data/fALzjamp/versions/inWDi2cf/Chunky-Fabric-1.4.40.jar";
                sha512 = "9e0386d032641a124fd953a688a48066df7f4ec1186f7f0f8b0a56d49dced220e2d6938ed56e9d8ead78bb80ddb941bc7873f583add8e565bdacdf62e13adc28";
              };
              ViewDistanceFix = fetchurl {
                url = "https://cdn.modrinth.com/data/nxrXbh5K/versions/35oxUh8B/viewdistancefix-fabric-1.21.6-1.0.2.jar";
                sha512 = "b6977555623055337c91f7eb2867427c2e22ed608037be9c791e0641737c5afac1a2effb798ae62409a165e579c64a5dcb3493248b68cf5ec503bddddb683773";
              };
              DisablePortalChecks = fetchurl {
                url = "https://cdn.modrinth.com/data/uOzKOGGt/versions/zW17oIr0/disableportalchecks-1.0.0.jar";
                sha512 = "ee92ad1d229081643bace5a043b9b33111daeb92bb06642e0c2a680a436961102a58f1606a82b2910461a4711c56bf7753abc1737c986a868899387d5357249e";
              };
            });
          };
        };
      };
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

    taskchampion-sync-server = {
      enable = true;
      allowClientIds = [
        "ab537ada-34dc-4138-992a-57c2a0d0207d" # Personal
      ];
    };

    nginx = {
      enable = true;
      package = pkgs.nginxStable.override { openssl = pkgs.libressl; };
      recommendedProxySettings = true;
      recommendedTlsSettings = true;

      virtualHosts."www.${domain}" = {
        addSSL = true;
        enableACME = true;
        root = "/var/www/${domain}";
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

      virtualHosts."ntfy.${domain}" = {
        addSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://${toString config.services.ntfy-sh.settings.listen-http}";
          proxyWebsockets = true;
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

      virtualHosts."taskchampion.${domain}" = {
        addSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.taskchampion-sync-server.port}";
        };
      };
    };
  };
}
