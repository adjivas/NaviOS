{
  den.aspects.wayvnc.homeManager = {
    lib,
    pkgs,
    config,
    ...
  }: {
    options.wayvnc = {
      host = lib.mkOption {
        type = lib.types.str;
        default = "127.0.0.1";
        description = "Address wayvnc binds to.";
      };
      uid = lib.mkOption {
        type = lib.types.int;
        default = 1000;
        description = "UID used to build XDG_RUNTIME_DIR.";
      };
      port = lib.mkOption {
        type = lib.types.port;
        default = 5900;
        description = "Port wayvnc listens on.";
      };

      waylandDisplay = lib.mkOption {
        type = lib.types.str;
        default = "wayland-0";
        description = "Wayland display name.";
      };
    };

    config = {
      systemd.user.services.wayvnc = {
        Unit = {
          Description = "Local VNC server for the Wayland graphical session";
          After = ["graphical-session.target"];
          PartOf = ["graphical-session.target"];
        };
        Install = {
          WantedBy = ["default.target"];
        };

        Service = {
          Type = "simple";
          Restart = "on-failure";
          RestartSec = "5s";

          Environment = [
            "HOME=${config.home.homeDirectory}"
            "XDG_CONFIG_HOME=${config.xdg.configHome}"
            "XDG_RUNTIME_DIR=/run/user/${toString config.wayvnc.uid}"
            "WAYLAND_DISPLAY=${config.wayvnc.waylandDisplay}"
          ];

          ExecStart = "${pkgs.wayvnc}/bin/wayvnc ${config.wayvnc.host} ${toString config.wayvnc.port}";
        };
      };
    };
  };
}
