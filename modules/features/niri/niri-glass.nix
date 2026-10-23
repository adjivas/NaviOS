{
  den.aspects.niri-glass = {
    homeManager = {config, ...}: {
      xdg.configFile."niri/glass.kdl".text = ''
        window-rule {
            match app-id=".*"

            exclude app-id="org.freecad.FreeCAD"
            exclude app-id="kicad"
            exclude app-id="org.inkscape.Inkscape"
            exclude app-id="blender"
            exclude app-id="gimp"
            exclude app-id="org.kde.krita"
            exclude app-id="org.qgis."

            opacity 0.8

            background-effect {
                blur true
                xray true

                liquid-glass {
                    mode "kwin-glass"

                    liquidity 1.0
                    fringing 1.0

                    refraction-strength 2.0
                    refraction-offset-strength 2.0
                    refraction-bevel-intensity 2.0
                    saturation 0.9

                    vibrancy 0.2
                    adaptive-dim 0.25
                    adaptive-boost 0.25
                }
            }
        }
      '';

      niri.includes = [
        "${config.xdg.configHome}/niri/glass.kdl"
      ];
    };
  };
}
