{
  den.aspects.waybar-backlight.homeManager = {pkgs, ...}: {
    programs.waybar = {
      settings.bar = {
        backlight = {
          format = "{icon}";
          format-icons = [
            "󱩎 "
            "󱩏 "
            "󱩐 "
            "󱩑 "
            "󱩒 "
            "󱩓 "
            "󱩔 "
            "󱩕 "
            "󱩖 "
            "󱩖 "
            "󰛨 "
          ];

          on-scroll-up = "${pkgs.brightnessctl}/bin/brightnessctl set 5%+";
          on-scroll-down = "${pkgs.brightnessctl}/bin/brightnessctl --min-value=1 set 5%-";

          tooltip-format = "Lit {percent}%";
        };

        modules-right = [
          "backlight"
        ];
      };
      style = ''
        #backlight {
          min-width: 24px;
          padding-left: 5px;
        }
      '';
    };
  };
}
