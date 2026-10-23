{
  den.aspects.swaylock-niri.homeManager = {
    pkgs,
    lib,
    wrappers,
    config,
    ...
  }: {
    options.swaylock = {
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.swaylock-effects;
      };
    };

    config = let
      swaylock = wrappers {
        inherit pkgs;

        package = config.swaylock.package;

        args = [
          "--screenshots"
          "--effect-blur"
          "12x6"

          "--ring-color"
          "00ffffff"
          "--key-hl-color"
          "00ffffff"
          "--bs-hl-color"
          "00ffffff"

          "$@"
        ];
      };
      niri = lib.getExe config.niri.package;
    in {
      programs.swaylock = {
        enable = true;
        package = swaylock;
      };
      services.swayidle = {
        enable = true;

        events = let
          locker = pkgs.writeShellScript "swaylock-lock" ''
            if ! ${lib.getExe' pkgs.procps "pgrep"} -x swaylock >/dev/null; then
              ${swaylock} --daemonize
            fi
          '';
        in {
          before-sleep = "${locker}";
          lock = "${locker}";
        };

        timeouts = [
          {
            timeout = 10;

            command = "${pkgs.writeShellScript "swayidle-power-off" ''
              if ${lib.getExe' pkgs.procps "pgrep"} -x swaylock >/dev/null; then
                ${niri} msg action power-off-monitors
              fi
            ''}";

            resumeCommand = "${pkgs.writeShellScript "swayidle-power-on" ''
              if ${lib.getExe' pkgs.procps "pgrep"} -x swaylock >/dev/null; then
                ${niri} msg action power-on-monitors
              fi
            ''}";
          }
        ];
      };
      systemd.user.services.swayidle = {
        Unit = {
          After = ["niri.service" "graphical-session.target"];
          Wants = ["graphical-session.target"];
          ConditionEnvironment = lib.mkForce [];
          PartOf = ["niri.service"];
        };
        Service = {
          ExecStartPre = "${pkgs.coreutils}/bin/sleep 2";
          Restart = lib.mkForce "on-failure";
          RestartSec = "5";
        };
      };
    };
  };
}
