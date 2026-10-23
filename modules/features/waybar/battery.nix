{
  den.aspects.waybar-battery.homeManager = {
    config,
    lib,
    ...
  }: {
    options.waybar.battery = {
      warning = lib.mkOption {
        type = lib.types.int;
        default = 30;
      };

      critical = lib.mkOption {
        type = lib.types.int;
        default = 15;
      };

      fullAt = lib.mkOption {
        type = lib.types.int;
        default = 80;
      };
    };

    config = {
      programs.waybar = {
        settings.bar = {
          "battery#discharging" = {
            states = {
              warning = config.waybar.battery.warning;
              critical = config.waybar.battery.critical;
            };

            full-at = config.waybar.battery.fullAt;

            format = "{icon}";
            format-charging = "";
            format-plugged = "";
            format-full = "{icon}";

            format-icons = [
              "󰂎"
              "󰁺"
              "󰁻"
              "󰁼"
              "󰁽"
              "󰁾"
              "󰁿"
              "󰂀"
              "󰂁"
              "󰂂"
              "󰁹"
            ];

            interval = 60;
            on-click = "killall -SIGUSR2 waybar";
            tooltip-format = "Bat {capacity}% ({time} remaining)\nClick to reload Waybar";
          };

          "battery#charging" = {
            full-at = config.waybar.battery.fullAt;

            format = "";
            format-discharging = "";
            format-charging = "{icon}";
            format-plugged = "{icon}";
            format-full = "{icon}";

            format-icons = [
              "󰢟 "
              "󰢜 "
              "󰂆 "
              "󰂇 "
              "󰂈 "
              "󰢝 "
              "󰂉 "
              "󰢞 "
              "󰂊 "
              "󰂋 "
              "󰂅 "
            ];

            interval = 60;
            on-click = "killall -SIGUSR2 waybar";
            tooltip-format = "Bat {capacity}%";
          };

          modules-right = [
            "battery#discharging"
            "battery#charging"
          ];
        };

        style = ''
          #battery {
            min-width: 24px;
            padding-left: 5px;
          }

          #battery.discharging {
            color: #00ff00;
          }

          #battery.warning {
            color: orange;
          }

          #battery.critical {
            color: red;
          }
        '';
      };
    };
  };
}
