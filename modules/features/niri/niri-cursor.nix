{
  den.aspects.niri-cursor = {
    homeManager = {config, ...}: {
      xdg.configFile."niri/cursor.kdl".text = ''
        global-shader {
            enable
            path "${./cursor.frag}"
            redraw "continuous"
            cursor-radius 128
        }
      '';

      niri.includes = [
        "${config.xdg.configHome}/niri/cursor.kdl"
      ];
    };
  };
}
