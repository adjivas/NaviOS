{
  den.aspects.tincr.nixos = {
    config,
    lib,
    ...
  }: {
    options.tincr = {
      name = lib.mkOption {
        type = lib.types.str;
      };
      key = lib.mkOption {
        type = lib.types.path;
      };
      netAddress = lib.mkOption {
        type = lib.types.str;
        default = "10.77.0.1";
      };
      dnsAddress = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
      };
      connectTo = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
      };
      hosts = lib.mkOption {
        default = {};

        type = lib.types.attrsOf (lib.types.submodule {
          options = {
            subnet = lib.mkOption {
              type = lib.types.str;
            };
            pub = lib.mkOption {
              type = lib.types.str;
            };
            address = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
            };
            tcpOnly = lib.mkOption {
              type = lib.types.bool;
              default = false;
            };
          };
        });
      };
    };

    config = {
      services.tincr.networks.dreamland =
        {
          nodeName = config.tincr.name;
          addresses = ["${config.tincr.netAddress}/24"];
          ed25519PrivateKeyFile = config.tincr.key;

          connectTo = config.tincr.connectTo;

          hosts =
            lib.mapAttrs (_: host: ''
              Subnet = ${host.subnet}/32
              Ed25519PublicKey = ${host.pub}
              ${lib.optionalString host.tcpOnly "TCPOnly = yes"}
              ${lib.optionalString (host.address != null) "Address = ${host.address}"}
            '')
            config.tincr.hosts;

          openFirewall = true;
          socketActivation = false;
        }
        // lib.optionalAttrs (config.tincr.dnsAddress != null) {
          dns = {
            enable = true;
            suffix = config.tincr.name;
            address4 = config.tincr.dnsAddress;
          };
        };
    };
  };
}
