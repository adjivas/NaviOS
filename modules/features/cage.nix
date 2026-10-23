{
  den.aspects.cage.homeManager = {
    lib,
    pkgs,
    config,
    ...
  }: {
    options.cage = {
      path = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [];
      };
      uid = lib.mkOption {
        type = lib.types.int;
        default = 1000;
        description = "UID used to build XDG_RUNTIME_DIR.";
      };
      environment = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          "WLR_DRM_DEVICES=/dev/dri/card0"
          "LIBGL_DEBUG=verbose"
          "MESA_DEBUG=1"
        ];
        description = "Additional environment variables passed to Cage.";
      };
      startScript = lib.mkOption {
        type = lib.types.path;
        default = "${pkgs.mesa-demos}/bin/gears";
        description = "Executable script launched inside Cage.";
      };

      stopScript = lib.mkOption {
        type = lib.types.path;
        default = pkgs.writeShellScript "cage-stop" "";
        description = "Executable script executed when Cage stops.";
      };
    };
    config = {
      systemd.user.services.cage = {
        Unit = {
          Description = "Cage session";
          After = ["graphical-session-pre.target"];
          BindsTo = ["graphical-session.target"];
        };
        Install = {
          WantedBy = ["default.target"];
        };

        Service = {
          Type = "simple";
          TimeoutStartSec = "5min";

          KillMode = "control-group";
          KillSignal = "SIGTERM";
          FinalKillSignal = "SIGKILL";
          SendSIGKILL = true;

          Environment =
            [
              "PATH=${lib.makeBinPath config.cage.path}"
              "HOME=${config.home.homeDirectory}"
              "XDG_RUNTIME_DIR=/run/user/${toString config.cage.uid}"
              "XDG_CONFIG_HOME=${config.xdg.configHome}"
              "XDG_CACHE_HOME=${config.xdg.cacheHome}"
              "XDG_DATA_HOME=${config.xdg.dataHome}"
            ]
            ++ config.cage.environment;

          ExecStart = "${pkgs.cage}/bin/cage -- ${config.cage.startScript}";
          ExecStop = "${config.cage.stopScript}";
        };
      };
    };
  };
}
