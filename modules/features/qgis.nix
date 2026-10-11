{
  den.aspects.qgis.homeManager = {
    pkgs,
    lib,
    wrappers,
    config,
    ...
  }: {
    options.qgis = {
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.qgis;
      };
    };
    config = let
      qgis = wrappers {
        inherit pkgs;

        package = config.qgis.package;
        exePath = lib.getExe' config.qgis.package "qgis";

        flags."--nologo" = true;

        env.DISPLAY = "dummy";
      };
    in {
      home.packages = [
        qgis
      ];
    };
  };
}
