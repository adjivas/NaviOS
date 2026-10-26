{
  den.aspects.krita.homeManager = {
    config,
    pkgs,
    wrappers,
    lib,
    ...
  }: {
    options.krita = {
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.krita;
      };
    };

    config = let
      pythonEnv = pkgs.python3.withPackages (ps: [
        ps.pyqt6
      ]);

      krita = wrappers {
        inherit pkgs;

        package = config.krita.package;

        flags."--nosplash" = true;

        env.QT_QPA_PLATFORM = "wayland";

        preHook = ''
          export PYTHONPATH="${pythonEnv}/${pkgs.python3.sitePackages}''${PYTHONPATH:+:$PYTHONPATH}"
        '';
      };
    in {
      home.packages = [
        krita
      ];
    };
  };
}
