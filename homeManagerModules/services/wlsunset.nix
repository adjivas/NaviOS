{ pkgs, lib, config, ... }: {
  options = {
    wlsunset.enable = lib.mkEnableOption "enable wlsunset";
  };
  config = lib.mkIf config.wlsunset.enable {
    services.wlsunset = {
      enable = true;
      systemdTarget = "sway-session.target";

      latitude = 48.858737;
      longitude = 2.182231;

      gamma = 1.0;
      temperature.day = 6500;
      temperature.night = 3000;
    };

    waybar.modules-right = lib.mkBefore [
      "custom/sunset"
    ];
    waybar.bar = let
      sunset-toggle = pkgs.writeShellScript "sunset-toggle" ''
        set -euo pipefail

        if ${pkgs.systemd}/bin/systemctl --user is-active --quiet "wlsunset.service"; then
          ${pkgs.systemd}/bin/systemctl --user stop "wlsunset.service"
          echo '{"text":"󰌶","tooltip":"wlsunset inactive","class":"off"}'
        else
          ${pkgs.systemd}/bin/systemctl --user start "wlsunset.service"
          echo '{"text":"󰌵","tooltip":"wlsunset active","class":"on"}'
        fi
      '';
      sunset-get = pkgs.writeShellScript "sunset-get" ''
        set -euo pipefail

        if ${pkgs.systemd}/bin/systemctl --user is-active --quiet "wlsunset.service"; then
          echo '{"text":"󰌵","tooltip":"wlsunset active","class":"on"}'
        else
          echo '{"text":"󰌶","tooltip":"wlsunset inactive","class":"off"}'
        fi
      '';
    in {
      "custom/sunset" = {
        interval = 10;
        tooltip = true;
        return-type = "json";
        format = "Sunset({text}) ";
        # format-icons = {
        #   on = "󰌵";
        #   off = "󰌶";
        # };
        exec = sunset-get;
        on-click = sunset-toggle;
      };
    };
  };
}
