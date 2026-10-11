{
  den.aspects.niri-rofi.homeManager = {
    config,
    pkgs,
    lib,
    ...
  }: {
    config = {
      niri.launcher = pkgs.writeShellApplication {
        name = "niri-rofi";

        runtimeInputs = [
          config.rofi.package
        ];

        text = ''
          exec env WINDOW_ID="$WINDOW_ID" ${lib.getExe config.niri.launcher}
        '';
      };

      xdg.configFile."niri/glass.kdl".text = lib.mkAfter ''
        layer-rule {
            match namespace="^rofi$"

            geometry-corner-radius 18
            opacity 0.92

            background-effect {
                blur true
                xray true

                noise 0.025
                saturation 0.70

                liquid-glass {
                    mode "kwin-glass"

                    refraction-bevel-intensity 10.0
                    refraction-offset-strength 8.0
                    edge-thickness 0.15

                    liquidity 1.0
                    fringing 1.0

                    glow-weight 0.12
                    edge-lighting 0.5

                    saturation 1.1
                    vibrancy 0.10

                    adaptive-dim 0.05
                    adaptive-boost 0.40
                }
            }
        }
      '';
    };
  };
}
