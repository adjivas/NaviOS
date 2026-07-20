{
  den.aspects.firefox-syncserver.nixos = {
    config,
    pkgs,
    lib,
    ...
  }: {
    options.firefox-syncserver = {
      secrets = lib.mkOption {
        type = lib.types.path;
        description = "Path to the Firefox Sync secrets file.";
      };

      port = lib.mkOption {
        type = lib.types.port;
        default = 443;
        description = "HTTPS port exposed by nginx for Firefox Sync.";
      };

      backendPort = lib.mkOption {
        type = lib.types.port;
        default = 5001;
        description = "Internal HTTP port used by firefox-syncserver.";
      };

      cert = lib.mkOption {
        type = lib.types.path;
        description = "Path to the TLS certificate used by nginx for Firefox Sync.";
      };

      key = lib.mkOption {
        type = lib.types.path;
        description = "Path to the TLS private key used by nginx for Firefox Sync.";
      };
    };

    config = {
      networking.hosts."127.0.0.1" = ["sync.dreamland"];

      services.nginx = {
        enable = true;

        virtualHosts."sync.dreamland" = {
          onlySSL = true;

          sslCertificate = config.firefox-syncserver.cert;
          sslCertificateKey = config.firefox-syncserver.key;

          locations."/" = {
            proxyPass = "http://127.0.0.1:${toString config.firefox-syncserver.backendPort}";
            recommendedProxySettings = true;
          };
        };
      };

      services.mysql.package = pkgs.mariadb;

      services.firefox-syncserver = {
        enable = true;
        secrets = config.firefox-syncserver.secrets;

        settings = {
          host = "127.0.0.1";
          port = config.firefox-syncserver.backendPort;
        };

        singleNode = {
          enable = true;
          hostname = "sync.dreamland";
          url = "https://sync.dreamland";
          capacity = 1;
        };
      };

      systemd.services.firefox-syncserver.serviceConfig.StateDirectory = "firefox-syncserver";
    };
  };
}
