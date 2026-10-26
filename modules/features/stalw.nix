{
  den.aspects.stalwart.nixos = {
    config,
    pkgs,
    lib,
    ...
  }: {
    options.stalwart = {
      url = lib.mkOption {
        type = lib.types.str;
      };
      credentialsFile = lib.mkOption {
        type = lib.types.path;
      };
      plan = lib.mkOption {
        type = lib.types.listOf lib.types.attrs;
        default = [./stalwart-plan.ndjson];
      };
    };
    config = {
      systemd.services.stalwart-bootstrap = {
        description = "Stalwart configuration bootstrap";

        wantedBy = ["multi-user.target"];

        after = ["network-online.target"];
        wants = ["network-online.target"];

        serviceConfig = {
          Type = "oneshot";

          EnvironmentFile = config.stalwart.credentialsFile;
          Environment = "STALWART_URL=${config.stalwart.url}";

          ExecStart = pkgs.writeShellScript "stalwart-bootstrap" ''
            set -e

            ${lib.concatMapStringsSep "\n" (plan: ''
                ${pkgs.stalwart-cli}/bin/stalwart-cli apply --file ${plan}
              '')
              config.stalwart.plans}
          '';

          RemainAfterExit = true;
        };
      };
    };
  };
}
