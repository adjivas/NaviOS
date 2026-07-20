{
  den.aspects.sm64ex.homeManager = {
    config,
    pkgs,
    lib,
    ...
  }: {
    options.sm64ex = {
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.sm64coopdx;
      };
      baserom = lib.mkOption {
        type = lib.types.path;
        readOnly = true;
        default = config.home.file."baserom.us.z64".path;
      };
      settings = lib.mkOption {
        type = lib.types.path;
        default = ./sm64config.txt;
      };
    };
    config = {
      programs.sm64ex = {
        enable = true;
        package = config.sm64ex.package;
        baserom = config.sm64ex.baserom;
      };

      xdg.dataFile."sm64coopdx/sm64config.txt".source = config.sm64ex.settings;
    };
  };
}
