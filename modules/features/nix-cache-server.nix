{
  den.aspects.nix-cache-server.nixos = {
    config,
    lib,
    ...
  }: {
    options.nix.cache.server = {
      address = lib.mkOption {
        type = lib.types.str;
        default = "0.0.0.0";
      };
      port = lib.mkOption {
        type = lib.types.int;
        default = 5000;
      };
      priority = lib.mkOption {
        type = lib.types.int;
        default = 10; # Low is priority level
      };
      key = lib.mkOption {
        type = lib.types.path;
      };
    };
    config = {
      services.nix-serve = {
        enable = true;
        secretKeyFile = config.nix.cache.server.key;
        bindAddress = config.nix.cache.server.address;
        port = config.nix.cache.server.port;
        extraParams = "--priority${toString config.nix.cache.server.priority}";
      };
      networking.firewall.allowedTCPPorts = [config.nix.cache.server.port];
    };
  };
}
