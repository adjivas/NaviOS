{inputs, ...}: {
  den.aspects.chroncal.homeManager = {
    config,
    lib,
    pkgs,
    ...
  }: {
    options.chroncal = {
      package = lib.mkOption {
        type = lib.types.package;
        default = inputs.chroncal.packages.${pkgs.stdenv.hostPlatform.system}.chroncal;
      };

      accounts = lib.mkOption {
        default = {};

        type = lib.types.attrsOf (lib.types.submodule {
          options = {
            server = lib.mkOption {
              type = lib.types.str;
            };

            username = lib.mkOption {
              type = lib.types.str;
              default = config.home.username;
            };

            passwordFile = lib.mkOption {
              type = lib.types.str;
            };

            allowInsecure = lib.mkOption {
              type = lib.types.bool;
              default = false;
            };
          };
        });
      };
    };

    config = {
      home.packages = [
        config.chroncal.package
      ];

      systemd.user.services.chroncal-accounts = lib.mkIf (config.chroncal.accounts != {}) {
        Unit = {
          Wants = ["network-online.target"];
          After = [
            "network-online.target"
            "graphical-session.target"
          ];
        };

        Service = {
          Type = "oneshot";

          Environment = [
            "DBUS_SESSION_BUS_ADDRESS=unix:path=%t/chroncal-no-dbus" # Added to skip the gnome-keyring
            "HOME=${config.home.homeDirectory}"
            "XDG_CONFIG_HOME=${config.xdg.configHome}"
            "XDG_DATA_HOME=${config.xdg.dataHome}"
          ];
          ExecStart = pkgs.writeShellScript "chroncal-accounts" (
            lib.concatStringsSep "\n" (
              lib.mapAttrsToList (
                name: account: ''
                  if ! ${lib.getExe config.chroncal.package} account get ${lib.escapeShellArg name} >/dev/null 2>&1; then
                    ${lib.getExe config.chroncal.package} account add \
                      ${lib.escapeShellArg name} \
                      --server ${lib.escapeShellArg account.server} \
                      --username ${lib.escapeShellArg account.username} \
                      --auth basic \
                      --password-cmd ${
                    lib.escapeShellArg "${lib.getExe' pkgs.coreutils "cat"} ${account.passwordFile}"
                  } \
                      ${lib.optionalString account.allowInsecure "--allow-insecure"}
                  fi
                ''
              )
              config.chroncal.accounts
            )
          );
        };

        Install.WantedBy = ["graphical-session.target"];
      };
    };
  };
}
