{
  den.aspects.novnc.homeManager = {
    lib,
    pkgs,
    config,
    ...
  }: {
    options.novnc = {
      host = lib.mkOption {
        type = lib.types.str;
        default = "127.0.0.1";
        description = "Address novnc binds to.";
      };
      port = lib.mkOption {
        type = lib.types.port;
        default = 6080;
        description = "Port wayvnc listens on.";
      };
      cert = lib.mkOption {
        type = lib.types.path;
        default = "/var/lib/microvm-certs/microvm.crt";
        description = "TLS certificate used by novnc.";
      };
      key = lib.mkOption {
        type = lib.types.path;
        default = "/var/lib/microvm-certs/microvm.key";
        description = "TLS private key used by novnc.";
      };
    };
    config = {
      systemd.user.services.novnc = {
        Unit = {
          Description = "noVNC web frontend for local wayvnc";
          After = [
            "graphical-session.target"
            "wayvnc.service"
          ];
          PartOf = ["graphical-session.target"];
          Wants = ["wayvnc.service"];
          Requires = ["wayvnc.service"];
        };
        Install = {
          WantedBy = ["default.target"];
        };
        Service = {
          Type = "simple";
          Restart = "always";
          RestartSec = 2;
          ExecStart = ''
            ${pkgs.python313Packages.websockify}/bin/websockify \
              --web ${pkgs.novnc}/share/webapps/novnc \
              --cert ${config.novnc.cert} \
              --key ${config.novnc.key} \
              --ssl-only \
              ${config.novnc.host}:${toString config.novnc.port} \
              ${config.wayvnc.host}:${toString config.wayvnc.port}
          '';
        };
      };
    };
  };
}
