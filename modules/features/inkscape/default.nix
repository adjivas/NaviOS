{
  den.aspects.inkscape.homeManager = {
    config,
    pkgs,
    lib,
    ...
  }: {
    options.inkscape = {
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.inkscape;
      };
      config = lib.mkOption {
        type = lib.types.path;
        default = ./preferences.xml;
        description = "Default config";
      };
    };
    config = {
      home.packages = [config.inkscape.package];
      home.file.".config/inkscape/preferences.xml".source = config.inkscape.config;
    };
  };
}
