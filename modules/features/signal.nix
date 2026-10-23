{self, ...}: {
  den.aspects.signal.homeManager = {
    pkgs,
    lib,
    config,
    wrappers,
    ...
  }: {
    options.signal = {
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.signal-desktop;
      };
    };

    config = let
      signal = wrappers {
        inherit pkgs;

        package =
          pkgs.runCommand "signal-desktop-custom" {
            nativeBuildInputs = [
              pkgs.asar
              pkgs.resvg
            ];

            meta.mainProgram = "signal-desktop";
          } ''
            cp -a ${config.signal.package} $out
            chmod -R u+w $out

            substituteInPlace $out/bin/signal-desktop \
              --replace-fail "${config.signal.package}" "$out"

            asar extract $out/share/signal-desktop/app.asar app

            for size in 16 32 48 256; do
              resvg \
                --width "$size" \
                --height "$size" \
                ${self.outPath}/artwork/signal/signal-desktop.svg \
                "app/images/tray-icons/base/signal-tray-icon-''${size}x''${size}-base.png"
            done

            rm $out/share/signal-desktop/app.asar

            asar pack app $out/share/signal-desktop/app.asar
          '';

        args = [
          "--use-tray-icon"
        ];
      };
    in {
      home.packages = [
        signal
      ];

      xdg.desktopEntries.signal = {
        name = "Signal";
        genericName = "Messenger";
        comment = "Private messaging";
        icon = "${config.signal.package}/share/icons/hicolor/256x256/apps/signal-desktop.png";
        exec = lib.getExe signal;
        terminal = false;
        categories = ["Network" "InstantMessaging"];
      };
    };
  };
}
