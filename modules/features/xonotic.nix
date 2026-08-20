{
  den.aspects.xonotic.homeManager = {
    config,
    pkgs,
    lib,
    ...
  }: {
    options.xonotic = {
      net_address = lib.mkOption {
        default = "0.0.0.0";
        type = lib.types.str;
        description = "username";
      };
      port = lib.mkOption {
        default = 26000;
        type = lib.types.port;
        description = "username";
      };
    };
    config = {
      # https://xonotic.org/tools/cacs
      home.packages = [
        (pkgs.writeShellScriptBin "xonotic" ''
          set -euo pipefail

          exec ${pkgs.xonotic}/bin/xonotic-sdl \
            +cl_allow_uid2name 0 \
            +cl_allow_uidtracking 0 \
            +connect ${config.xonotic.net_address}:${toString config.xonotic.port} \
            +defer 6 "say hey listen; togglemenu;"
        '')
      ];
    };
  };
}
