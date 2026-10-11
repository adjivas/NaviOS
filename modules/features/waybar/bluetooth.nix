{
  den.aspects.waybar-bluetooth.homeManager = {
    config,
    pkgs,
    lib,
    ...
  }: {
    programs.waybar = {
      settings.bar = {
        bluetooth = {
          format = "󰂯";
          format-disabled = "󰂲";
          format-off = "󰂲";
          format-on = "󰂯";
          format-connected = "󰂱 ";
          format-connected-battery = "󰂱 ";

          on-click = "${lib.getExe config.gnome-control-center.package} bluetooth";
          on-click-right = "${lib.getExe' pkgs.util-linux "rfkill"} toggle bluetooth";

          # tooltip-format = "{num_connections} {status}";
          tooltip-format-connected = "{device_alias} ({device_battery_percentage}%)";
        };

        modules-right = [
          "bluetooth"
        ];
      };

      style = ''
        #bluetooth {
          min-width: 24px;
          padding-left: 5px;
        }

        #bluetooth.disabled {
          color: gray;
        }
      '';
    };
  };
}
