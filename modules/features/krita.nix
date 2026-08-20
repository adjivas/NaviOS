{
  den.aspects.krita.homeManager = {
    config,
    pkgs,
    lib,
    ...
  }: {
    options.krita = {
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.krita-unwrapped;
      };
    };

    config = let
      pythonEnv = pkgs.python3.withPackages (ps: [
        ps.pyqt6
      ]);

      kritaWrapped = pkgs.writeShellScriptBin "krita" ''
        export PYTHONPATH="${pythonEnv}/${pkgs.python3.sitePackages}''${PYTHONPATH:+:$PYTHONPATH}"

        exec ${config.krita.package}/bin/krita --nosplash "$@"
      '';
    in {
      home.packages = [
        kritaWrapped
      ];

      xdg.desktopEntries."org.kde.krita" = {
        name = "Krita";
        genericName = "Digital Painting";
        comment = "Digital Painting";
        exec = "krita %F";
        icon = "krita";
        terminal = false;

        categories = [
          "Graphics"
          "2DGraphics"
          "RasterGraphics"
          "Qt"
        ];

        mimeType = [
          "application/x-krita"
          "image/png"
          "image/jpeg"
          "image/tiff"
          "image/webp"
          "image/svg+xml"
        ];
      };
    };
  };
}
