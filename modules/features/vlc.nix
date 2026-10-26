{inputs, ...}: {
  den.aspects.vlc.homeManager = {
    config,
    pkgs,
    lib,
    ...
  }: {
    options.vlc.runtimeInputs = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
    };

    config = {
      home.packages = [
        (inputs.wrappers.lib.wrapPackage {
          inherit pkgs;

          package = pkgs.vlc;

          runtimeInputs = config.vlc.runtimeInputs;

          env.LUA_PATH =
            (lib.concatMapStringsSep ";"
              pkgs.luaPackages.getLuaPath
              [
                pkgs.luaPackages.cjson
              ])
            + ";";
        })
      ];

      xdg.configFile."vlc/vlcrc".text = lib.generators.toINI {} {
        qt.qt-fs-controller = 0;
        qt.qt-notification = 0;
        qt.qt-privacy-ask = 0;
        qt.qt-video-autoresize = 0;
        core.metadata-network-access = 0;
      };
    };
  };
}
