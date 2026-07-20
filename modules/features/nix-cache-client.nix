{
  den.aspects.nix-cache-client.nixos = {
    config,
    lib,
    ...
  }: {
    options.nix.cache.client = {
      substituters = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          "https://cache.nixos.org"
        ];
        description = "Base Nix substituters.";
      };
      extraSubstituters = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "Additional Nix substituters.";
      };
      trustedPublicKeys = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        ];
        description = "Base trusted public keys for Nix substituters.";
      };
      extraTrustedPublicKeys = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "Additional trusted public keys.";
      };
    };
    config = {
      nix.settings = {
        connect-timeout = 1;
        download-attempts = 1;
        # Cache
        substituters =
          config.nix.cache.client.extraSubstituters
          ++ config.nix.cache.client.substituters;
        trusted-public-keys =
          config.nix.cache.client.trustedPublicKeys
          ++ config.nix.cache.client.extraTrustedPublicKeys;
      };
    };
  };
}
