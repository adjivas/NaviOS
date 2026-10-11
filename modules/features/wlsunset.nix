{
  den.batteries.wlsunset = {
    latitude ? 48.858737,
    longitude ? 2.182231,
    gamma ? 1.0,
    dayTemperature ? 6500,
    nightTemperature ? 3000,
    output ? null,
    sunrise ? null,
    sunset ? null,
    duration ? null,
  }: {
    target ? "graphical-session.target",
    display ? "wayland-1",
  }: {user, ...}: let
    sessionName = builtins.head (builtins.split "\\." target);
    name = "wlsunset-${user.userName}-${display}-${sessionName}";
  in {
    inherit name;

    homeManager = {
      lib,
      pkgs,
      ...
    }: let
      args = lib.cli.toCommandLineShellGNU {} {
        t = nightTemperature;
        T = dayTemperature;
        g = gamma;
        l = latitude;
        L = longitude;
        S = sunrise;
        s = sunset;
        d = duration;
        o = output;
      };
    in {
      home.packages = [pkgs.wlsunset];

      systemd.user.services = {
        ${name} = {
          Unit = {
            Description = "Day/night gamma adjustments for ${sessionName}.";
            After = [target];
            PartOf = [target];
            ConditionEnvironment = "WAYLAND_DISPLAY=${display}";
            StartLimitIntervalSec = 0;
          };

          Service.ExecStart = "${lib.getExe pkgs.wlsunset} ${args}";

          Install.WantedBy = [target];
        };
      };
    };
  };
}
