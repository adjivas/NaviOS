{
  den.aspects.waybar-wireplumber.homeManager = {
    pkgs,
    lib,
    ...
  }: {
    programs.waybar = {
      settings.bar = {
        wireplumber = {
          format = "{icon}";
          format-muted = "󰖁 ";
          format-icons = [
            " "
            " "
            " "
          ];
          max-volume = 150;
          tooltip-format = "Vol {volume}%";

          # Output Devices
          on-click = "${lib.getExe pkgs.pwvucontrol} --tab 4";
          on-click-right = "${lib.getExe' pkgs.wireplumber "wpctl"} set-mute @DEFAULT_AUDIO_SINK@ toggle";
        };

        "wireplumber#microphone" = {
          node-type = "Audio/Source";
          format = "";
          format-muted = " ";
          tooltip-format = "Mic {volume}%";

          # Input Devices
          on-click = "${lib.getExe pkgs.pwvucontrol} --tab 3";
          on-click-right = "${lib.getExe' pkgs.wireplumber "wpctl"} set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
        };

        modules-right = [
          "wireplumber#microphone"
          "wireplumber"
        ];
      };

      style = ''
        #wireplumber,
        #wireplumber.microphone {
          min-width: 24px;
          padding-left: 5px;
        }

        #wireplumber.muted {
          color: gray;
        }
      '';
    };
  };
}
