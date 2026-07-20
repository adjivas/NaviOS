{
  den.aspects.lan-mouse.nixos = {
    config,
    lib,
    ...
  }: {
    options.lan-mouse = {
      port = lib.mkOption {
        type = lib.types.port;
        default = 4242;
        description = "LAN Mouse port.";
      };
    };

    config = {
      networking.firewall.allowedTCPPorts = [config.lan-mouse.port];
      networking.firewall.allowedUDPPorts = [config.lan-mouse.port];
    };
  };
  den.aspects.lan-mouse.homeManager = {
    osConfig,
    config,
    lib,
    pkgs,
    ...
  }: {
    options.lan-mouse = {
      port = lib.mkOption {
        type = lib.types.port;
        default = osConfig.lan-mouse.port;
        description = "LAN Mouse port";
      };
      authorizedFingerprints = lib.mkOption {
        type = lib.types.path;
        description = "TOML fragment containing Lan Mouse authorized_fingerprints";
      };
      clients = lib.mkOption {
        type = lib.types.attrsOf lib.types.attrs;
        default = {};
        description = "Extra Lan Mouse clients.";
      };
    };
    config = let
      clientsToml = (pkgs.formats.toml {}).generate "lan-mouse-clients.toml" {
        clients =
          lib.mapAttrsToList
          (hostname: client: client // {inherit hostname;})
          config.lan-mouse.clients;
      };
    in {
      programs.lan-mouse = {
        enable = true;
        systemd = true;
      };

      systemd.user.services.write-lan-mouse-config = {
        Unit = {
          Description = "Write Lan Mouse config";
          Requires = ["agenix.service"];
          After = ["agenix.service"];
          Before = ["lan-mouse.service"];
        };
        Install = {
          WantedBy = ["default.target"];
        };

        Service = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = pkgs.writeShellScript "write-lan-mouse-config" ''
            set -euo pipefail

            config_dir="${config.xdg.configHome}/lan-mouse"
            config_file="$config_dir/config.toml"

            ${pkgs.coreutils}/bin/install -d -m 0700 "$config_dir"

            tmp="$(${pkgs.coreutils}/bin/mktemp)"

            ${pkgs.coreutils}/bin/printf 'port = ${toString config.lan-mouse.port}\n\n' > "$tmp"

            ${pkgs.coreutils}/bin/printf '[authorized_fingerprints]\n' >> "$tmp"
            ${pkgs.coreutils}/bin/printf '"%s" = "%s"\n\n' \
              "$(${pkgs.coreutils}/bin/cat ${config.lan-mouse.authorizedFingerprints})" \
              "${osConfig.networking.hostName}" >> "$tmp"

            ${pkgs.coreutils}/bin/cat "${clientsToml}" >> "$tmp"

            ${pkgs.coreutils}/bin/install -m 0600 "$tmp" "$config_file"
            ${pkgs.coreutils}/bin/rm -f "$tmp"
          '';
        };
      };
      systemd.user.services.lan-mouse.Unit = {
        Requires = ["write-lan-mouse-config.service"];
        After = ["write-lan-mouse-config.service"];
      };
    };
  };
}
