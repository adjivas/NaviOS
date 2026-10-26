{
  den.aspects.waybar-network.homeManager = {
    config,
    pkgs,
    lib,
    ...
  }: {
    programs.waybar = {
      settings.bar = {
        network = {
          format = "{icon}";
          format-wifi = "  ({essid})";
          format-icons = ["󰤯 " "󰤟 " "󰤢 " "󰤥 " "󰤨 "];
          format-ethernet = "󰈀 ";
          format-disconnected = "󰖪 ";
          format-disabled = " ";
          tooltip-format = "{ifname} via {gwaddr}";
          tooltip-format-wifi = "{ifname} via {gwaddr}";
          max-length = 50;

          on-click = "${lib.getExe config.gnome-control-center.package} wifi";
          on-click-right = "${lib.getExe' pkgs.util-linux "rfkill"} toggle wifi";
        };

        modules-right = [
          "network"
        ];
      };

      style = ''
        #network {
          min-width: 24px;
          padding-left: 5px;
        }

        #network.disconnected,
        #network.disabled {
          color: red;
        }
      '';
    };
  };
}
