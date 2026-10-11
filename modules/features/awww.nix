{
  den.batteries.awww = {
    namespace ? "awww-background",
    wallpaper,
  }: {
    target ? "graphical-session.target",
    display ? "wayland-1",
  }: {user, ...}: let
    sessionName = builtins.head (builtins.match "([^.]+).*" target);
    name = "${namespace}-${user.userName}-${display}-${sessionName}";
  in {
    inherit name;

    homeManager = {
      pkgs,
      lib,
      ...
    }: {
      systemd.user.tmpfiles.rules = [
        "d %C/awww 0700 - - -"
      ];

      systemd.user.services.${name} = {
        Unit = {
          Description = "AWWW daemon (${namespace}, ${sessionName})";
          After = [target];
          PartOf = [target];
        };

        Service = {
          Environment = [
            "WAYLAND_DISPLAY=${display}"
          ];

          ExecStart = "${lib.getExe' pkgs.awww "awww-daemon"} --namespace ${
            lib.escapeShellArg namespace
          }";

          Restart = "on-failure";
        };

        Install.WantedBy = [target];
      };

      systemd.user.paths."${name}-wallpaper" = {
        Unit = {
          Description = "Wait for AWWW socket (${namespace}, ${sessionName})";
          PartOf = [target];
        };

        Path = {
          PathExists = "%t/${display}-awww-daemon.${namespace}.sock";
          Unit = "${name}-wallpaper.service";
        };

        Install.WantedBy = [target];
      };

      systemd.user.services."${name}-wallpaper" = {
        Unit = {
          Description = "AWWW wallpaper (${namespace}, ${sessionName})";
          Requires = ["${name}.service"];
          After = ["${name}.service"];
          PartOf = [target];
        };

        Service = {
          Type = "oneshot";
          RemainAfterExit = true;

          Environment = [
            "WAYLAND_DISPLAY=${display}"
          ];

          ExecStart = "${lib.getExe pkgs.awww} img ${
            lib.escapeShellArg (toString wallpaper)
          } --namespace ${
            lib.escapeShellArg namespace
          } --resize crop";
        };
      };
    };
  };
}
