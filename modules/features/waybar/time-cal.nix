{
  den.aspects.waybar-time-cal.homeManager = {
    pkgs,
    lib,
    config,
    ...
  }: let
    chroncal = config.chroncal.package;
  in {
    options.waybar.time-cal = {
      interval = lib.mkOption {
        type = lib.types.int;
        default = 5;
      };
      exec = lib.mkOption {
        type = lib.types.path;

        default = pkgs.writeShellScript "waybar-time" ''
          time="$(${pkgs.coreutils}/bin/date '+%R:%S')"
          today="$(${pkgs.coreutils}/bin/date '+%F')"

          events="$(
            ${lib.getExe chroncal} event list --output json \
              | ${lib.getExe pkgs.jq} -r --arg today "$today" '
                .[]
                | select(.start_time[:10] == $today)
                | .title
              '
          )"

          if [ -n "$events" ]; then
            ${lib.getExe pkgs.jq} -nc --arg text "$time" --arg tooltip "$events" \
              '{ text: $text, tooltip: $tooltip, class: "events" }'
          else
            ${lib.getExe pkgs.jq} -nc --arg text "$time" '{ text: $text }'
          fi
        '';
      };
    };

    config = {
      programs.waybar = {
        settings.bar = {
          "custom/time" = {
            interval = config.waybar.time-cal.interval;
            return-type = "json";
            escape = true;
            exec = config.waybar.time-cal.exec;
            on-click = lib.getExe pkgs.gnome-clocks;
          };

          modules-center = [
            "custom/time"
          ];
        };
        style = ''
          #custom-time {
            font-weight: bold;
          }
          #custom-time.events {
            background-image: linear-gradient(cyan, cyan);
            background-size: 4.5em 2px;
            background-position: center bottom;
            background-repeat: no-repeat;
            background-origin: content-box;
          }
        '';
      };
    };
  };
}
