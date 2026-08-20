{
  den.aspects.freecad.homeManager = {
    config,
    pkgs,
    lib,
    ...
  }: {
    options.freecad = {
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.freecad;
      };

      config = lib.mkOption {
        type = lib.types.path;
        default = ./user.cfg.xml;
      };

      extensions = lib.mkOption {
        type = lib.types.listOf lib.types.path;
        default = [];
        description = "FreeCAD extensions distributed as ZIP files";
      };
    };

    config = {
      home.packages = [
        config.freecad.package
      ];

      home.file.".config/FreeCAD/v1-1/user.cfg" = {
        source = config.freecad.config;
        force = true;
      };

      home.activation.freecadExtensions = lib.hm.dag.entryAfter ["writeBoundary"] ''
        extensionsDir="$HOME/.local/share/FreeCAD/v1-1/Mod"

        mkdir -p "$extensionsDir"

        for extension in ${lib.escapeShellArgs (map toString config.freecad.extensions)}; do
          ${lib.getExe pkgs.unzip} -o "$extension" -d "$extensionsDir"
        done
      '';
    };
  };
}
