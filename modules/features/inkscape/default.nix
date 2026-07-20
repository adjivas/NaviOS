{
  den.aspects.inkscape.homeManager = {
    config,
    pkgs,
    lib,
    ...
  }: {
    options.inkscape = {
      config = lib.mkOption {
        type = lib.types.path;
        default = ./preferences.xml;
        description = "Default config";
      };
    };
    config = {
      home.packages = with pkgs; [inkscape];
      home.file.".config/inkscape/preferences.xml".source = config.inkscape.config;
    };
  };
}
