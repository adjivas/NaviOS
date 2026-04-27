{ lib, config, ... }: {
  options = {
    cache.enable = lib.mkEnableOption "enable cache";
    cache.address = lib.mkOption {
      type = lib.types.str;
      default = "0.0.0.0";
    };
    cache.port = lib.mkOption {
      type = lib.types.int;
      default = 5000;
    };
    cache.key = lib.mkOption {
      type = lib.types.path;
    };
  };
  config = lib.mkIf config.cache.enable {
    services.nix-serve = {
      enable = true;
      secretKeyFile = config.cache.key;
      bindAddress = config.cache.address;
      port = config.cache.port;
    };
    networking.firewall.allowedTCPPorts = [ config.cache.port ];
  };
}
