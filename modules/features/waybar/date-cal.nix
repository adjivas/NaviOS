{
  den.aspects.waybar-date-cal.homeManager = {
    pkgs,
    lib,
    config,
    ...
  }: let
    chroncal = config.chroncal.package;
  in {
    options.waybar.date-cal = {
      interval = lib.mkOption {
        type = lib.types.int;
        default = 60;
      };
      exec = lib.mkOption {
        type = lib.types.path;

        default = pkgs.writeShellScript "waybar-date" ''
          events="$(
            ${lib.getExe chroncal} event list \
              --from "$(${pkgs.coreutils}/bin/date +%F)" \
              --to "$(${pkgs.coreutils}/bin/date -d '+30 days' +%F)" \
              --output json \
              | ${lib.getExe pkgs.jq} -r \
                --arg today "$(${pkgs.coreutils}/bin/date +%F)" '
                  .[]
                  | . as $event
                  | (
                      ($event.start_time[:10] | strptime("%Y-%m-%d") | mktime)
                      - ($today | strptime("%Y-%m-%d") | mktime)
                    ) / 86400
                  | floor as $days
                  | select($days >= 0)
                  | if $days == 0 then
                      "Aujourd’hui \($event.title)"
                    elif $days == 1 then
                      "Demain \($event.title)"
                    else
                      "Dans \($days) jours \($event.title)"
                    end
                '
          )"

          ${lib.getExe pkgs.jq} -nc \
            --arg text "$(${pkgs.coreutils}/bin/date '+%d/%m(%a%b)')" \
            --arg tooltip "$events" \
            '{ text: $text, tooltip: $tooltip }'
        '';
      };
    };

    config = {
      programs.waybar = {
        settings.bar = {
          "custom/date" = {
            interval = config.waybar.date-cal.interval;
            return-type = "json";
            escape = true;
            exec = config.waybar.date-cal.exec;
          };

          modules-right = [
            "custom/date"
          ];
        };
        style = ''
          #custom-date {
            font-weight: bold;
            padding-right: 14px;
            padding-left: 5px;
          }
        '';
      };
    };
  };
}
