{self, ...}: {
  den.aspects.waybar-tray.homeManager = {
    programs.waybar = {
      settings.bar = {
        modules-right = ["tray"];
        tray = {
          icon-size = 16;
          spacing = 14;

          icons = {
            vlc = "${self.outPath}/artwork/waybar/vlc.svg";
            gajim = "${self.outPath}/artwork/waybar/gajim.svg";
          };
        };
      };
      style = ''
        #custom-time {
          font-weight: bold;
          padding-right: 14px;
          padding-left: 5px;
        }

        #tray {
          padding: 0 8px;
        }
      '';
    };
  };
}
