{inputs, ...}: {
  den.aspects.timewall.homeManager = {
    pkgs,
    lib,
    config,
    ...
  }: {
    imports = [
      inputs.timewall.homeManagerModules.default
    ];

    options.timewall = {
      wallpaperPath = lib.mkOption {
        type = lib.types.path;
        example = ./Mojave.heic;
        description = "Path to the dynamic wallpaper used by Timewall.";
      };
    };

    config = {
      services.timewall = {
        enable = true;

        wallpaperPath = config.timewall.wallpaperPath;

        config = {
          geoclue = {
            enable = true;
            cache_fallback = true;
            prefer = false;
            timeout = 1000;
          };

          location = {
            lat = 48.86;
            lon = 2.35;
          };

          setter = {
            command = [
              (lib.getExe pkgs.awww)
              "img"
              "--namespace"
              "awww-background"
              "--transition-type"
              "fade"
              "--transition-duration"
              "2"
              "%f"
            ];

            quiet = true;
            overlap = 200;
          };

          daemon.update_interval_seconds = 300;
        };
      };
    };
  };
}
