{
  den.aspects.niri-anyrun.homeManager = {
    config,
    pkgs,
    lib,
    ...
  }: {
    niri.launcher = pkgs.writeShellApplication {
      name = "niri-anyrun";

      runtimeInputs = [
        config.anyrun.package
        config.niri.package
        pkgs.jq
        pkgs.wl-clipboard
        pkgs.wtype
      ];

      text = ''
        WINDOW_ID="$(niri msg --json focused-window | jq -r '.id')"
        BEFORE="$(wl-paste 2>/dev/null || true)"

        anyrun

        AFTER="$(wl-paste 2>/dev/null || true)"

        if [ "$AFTER" != "$BEFORE" ]; then
          niri msg action focus-window --id "$WINDOW_ID"
          wtype "$AFTER"
        fi
      '';
    };

    xdg.configFile."niri/glass.kdl".text = lib.mkAfter ''
      layer-rule {
          match namespace="^anyrun$"

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
}
