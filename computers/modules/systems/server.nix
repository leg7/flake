{ lib, pkgs, config, ... }: {
  imports = [ ./base.nix ];

  networking.wireless.iwd.enable = lib.mkForce false;
  hardware.bluetooth.enable = lib.mkForce false;

  networking.firewall = {
      enable = true;
      allowedUDPPorts = [];
      allowedTCPPorts = [ 727 80 443 ];
  };

  environment.systemPackages = with pkgs; [
    zola
  ];

  security.acme = {
    acceptTerms = true;
    defaults.email = "leonard.gomez@protonmail.com";
    defaults.webroot = "/var/lib/acme/acme-challenge";
    certs = {
      "leonardgomez.xyz".extraDomainNames = [ "www.leonardgomez.xyz" "git.leonardgomez.xyz" "kavita.leonardgomez.xyz" ];
    };
  };

  services = {
    # kavita.enable = true;
    # TODO: Use nix secrets
    # kavita.tokenKeyFile = ./kavita.tokenKeyFile;

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

      # virtualHosts."kavita.leonardgomez.xyz" = {
      #   addSSL = true;
      #   enableACME = true;
      #   locations."/" = {
      #     proxyPass = "127.0.0.1:5000";
      #   };
      # };

    };
  };
}
