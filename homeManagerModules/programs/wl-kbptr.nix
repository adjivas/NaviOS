{ lib, config, pkgs, ... }: {
  options = {
    wl-kbptr.enable = lib.mkEnableOption "enable wl-kbptr";
  };
  config = lib.mkIf config.wl-kbptr.enable {
    home.packages = let
      wl-kbptr = (pkgs.wl-kbptr.overrideAttrs (old: {
        src = pkgs.fetchFromGitHub {
          owner = "moverest";
          repo  = "wl-kbptr";
          rev   = "1c6c9275a49f6def4c37707e741da47f5098be7c";
          hash  = "sha256-UEVPeqD1Oj3cK2Hq2eLpGy6Jdjd9i0tQNXdiDWAUIM0=";
        };
        postPatch = (old.postPatch or "") + ''
          sed -i '182,189d' src/main.c

          files=$(grep -rl "CAIRO_FONT_WEIGHT_NORMAL" src || true)
          if [ -n "$files" ]; then
            for f in $files; do
              substituteInPlace "$f" --replace "CAIRO_FONT_WEIGHT_NORMAL" "CAIRO_FONT_WEIGHT_BOLD"
            done
          fi
        '';

        nativeBuildInputs = (old.nativeBuildInputs or []) ++ (with pkgs; [
          meson ninja pkg-config
        ]);
        buildInputs = (old.buildInputs or []) ++ [
          pkgs.opencv
        ];
        mesonFlags = (old.mesonFlags or []) ++ [
          "-Dopencv=enabled"
        ];
      }));
    in [
      (pkgs.writeShellApplication {
        name = "wl-kbptr-sway";
        runtimeInputs = [ pkgs.jq pkgs.sway ];
        text = ''
          set -euo pipefail

          active_area=$(${pkgs.sway}/bin/swaymsg -t get_tree | ${pkgs.jq}/bin/jq --raw-output '.. | (.nodes? + .floating_nodes? // empty)[] | select(.focused) | .rect | "\(.width)x\(.height)+\(.x)+\(.y)"')

          exec ${wl-kbptr}/bin/wl-kbptr --restrict "$active_area" "''$@"
        '';
      })
    ];

    xdg.configFile."wl-kbptr/config".text = lib.generators.toINI { } {
      general = {
        home_row_keys = "";
        modes = "floating,click";
      };
      mode_floating = {
        source = "detect";
        label_color = "#000";
        label_select_color = "#0000ff";

        selectable_bg_color = "#00ffffaa";
        selectable_border_color = "#00ffff";
      };
    };
  };
}
