{
  den.aspects.gnome-control-center.homeManager = {
    pkgs,
    lib,
    config,
    wrappers,
    ...
  }: {
    options.gnome-control-center = {
      package = lib.mkOption {
        type = lib.types.package;
        readOnly = true;
        default = wrappers {
          inherit pkgs;

          package = pkgs.gnome-control-center;
          exePath = "${pkgs.gnome-control-center}/bin/gnome-control-center";
          binName = "gnome-control-center";

          env = {
            XDG_CURRENT_DESKTOP = "GNOME";
          };
        };
      };
    };

    config = {
      home.packages = [
        config.gnome-control-center.package
        pkgs.gnome-online-accounts
      ];

      xdg.desktopEntries.gnome-control-center = {
        name = "GNOME Control Center";
        genericName = "Settings";
        comment = "Configure the system";
        exec = lib.getExe config.gnome-control-center.package;
        terminal = false;
        categories = ["Settings" "GNOME"];
      };
    };
  };
}
