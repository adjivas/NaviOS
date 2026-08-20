{
  den.aspects.gnome-control-center.homeManager = {
    pkgs,
    lib,
    wrappers,
    ...
  }: {
    options.gnome-control-center = {
      user = lib.mkOption {
        type = lib.types.str;
      };
    };
    config = let
      gnome-control-center = wrappers {
        inherit pkgs;

        package = pkgs.gnome-control-center;
        exePath = "${pkgs.gnome-control-center}/bin/gnome-control-center";
        binName = "gnome-control-center";

        env = {
          XDG_CURRENT_DESKTOP = "GNOME";
        };
      };
    in {
      home.packages = [
        gnome-control-center
        pkgs.gnome-online-accounts
      ];

      xdg.desktopEntries.gnome-control-center = {
        name = "GNOME Control Center";
        genericName = "Settings";
        comment = "Configure the system";
        exec = "${gnome-control-center}/bin/gnome-control-center";
        terminal = false;
        categories = ["Settings" "GNOME"];
      };
    };
  };
}
