{
  den.aspects.ejabberd.nixos = {
    config,
    pkgs,
    lib,
    ...
  }: {
    options.ejabberd = {
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.ejabberd;
      };

      config = lib.mkOption {
        type = lib.types.path;
        default = ./ejabberd.yml;
      };

      host = lib.mkOption {
        type = lib.types.str;
        default = "ejabberd.local";
      };

      address = lib.mkOption {
        type = lib.types.str;
        default = "127.0.0.1";
      };

      port = lib.mkOption {
        type = lib.types.port;
        default = 5222;
      };

      listenAddress = lib.mkOption {
        type = lib.types.str;
        default = "0.0.0.0";
      };

      authMethod = lib.mkOption {
        type = lib.types.str;
        default = "internal";
      };
    };

    config = {
      networking.hosts.${config.ejabberd.address} = [
        config.ejabberd.host
      ];

      services.ejabberd = {
        enable = true;
        package = config.ejabberd.package;

        configFile = pkgs.writeText "ejabberd.yml" ''
          hosts:
            - ${config.ejabberd.host}

          auth_method: ${config.ejabberd.authMethod}

          listen:
            - port: ${toString config.ejabberd.port}
              ip: "${config.ejabberd.listenAddress}"
              module: ejabberd_c2s

          ${builtins.readFile config.ejabberd.config}
        '';
      };
    };
  };
}
