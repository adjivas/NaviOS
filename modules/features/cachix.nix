{
  den.aspects.cachix.homeManager = {
    lib,
    pkgs,
    config,
    ...
  }: {
    options.cachix = {
      dhallPath = lib.mkOption {
        type = lib.types.path;
        default = /home/adjivas/.config/cachix/cachix.dhall;
        description = "Path to the dhall file.";
      };
    };

    config = {
      home.packages = [
        (pkgs.writeShellScriptBin "cachix" ''
          set -euo pipefail

          dhall_path="${toString config.cachix.dhallPath}"

          json="$(${pkgs.dhall-json}/bin/dhall-to-json --file "$dhall_path")"

          export CACHIX_SIGNING_KEY="$(echo "$json" | ${pkgs.jq}/bin/jq -r '.binaryCaches[0].secretKey')"

          export CACHIX_AUTH_TOKEN="$(echo "$json" | ${pkgs.jq}/bin/jq -r '.authToken')"

          exec ${pkgs.cachix}/bin/cachix "$@"
        '')
      ];
    };
  };
}
