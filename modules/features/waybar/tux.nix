{self, ...}: {
  den.aspects.waybar-tux.homeManager = {
    config,
    lib,
    ...
  }: {
    programs.waybar = {
      settings.bar = {
        "image#linux" = {
          path = "${self.outPath}/artwork/waybar/tux.svg";
          size = 18;
          on-click = "${lib.getExe config.gnome-control-center.package} system about";
        };

        modules-left = [
          "image#linux"
        ];
      };

      style = ''
        #image.linux {
          margin-top: 2px;

          padding-left: 28px;
          padding-right: 28px;
        }
      '';
    };
  };
}
