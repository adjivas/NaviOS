{
  den.aspects.waybar-sunset.homeManager = {pkgs, ...}: {
    programs.waybar = {
      settings.bar = {
        "custom/sunset" = {
          exec = pkgs.writeShellScript "waybar-sunset" ''
            if ${pkgs.systemd}/bin/systemctl --user is-active --quiet "wlsunset-$SESSION_ID.service"; then
              printf '{"text":"󱩍 ","class":"on"}\n'
            else
              printf '{"text":"󰹐 ","class":"off"}\n'
            fi
          '';

          on-click = pkgs.writeShellScript "waybar-sunset-toggle" ''
            service="wlsunset-$SESSION_ID.service"

            if ${pkgs.systemd}/bin/systemctl --user is-active --quiet "$service"; then
              ${pkgs.systemd}/bin/systemctl --user stop "$service"
            else
              ${pkgs.systemd}/bin/systemctl --user start "$service"
            fi
          '';

          return-type = "json";
          interval = 2;
          tooltip = false;
        };

        modules-right = [
          "custom/sunset"
        ];
      };

      style = ''
        #custom-sunset.on {
          color: black;
        }

        #custom-sunset.off {
          color: gray;
        }
      '';
    };
  };
}
