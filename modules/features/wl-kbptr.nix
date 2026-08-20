{
  den.aspects.wl-kbptr.nixos = {
    config = {
      programs.ydotool = {
        enable = true;
        group = "input";
      };
    };
  };
  den.aspects.wl-kbptr.homeManager = {
    pkgs,
    lib,
    ...
  }: {
    config = {
      home.packages = let
        wl-kbptr = pkgs.wl-kbptr.overrideAttrs (old: {
          src = pkgs.fetchFromGitHub {
            owner = "moverest";
            repo = "wl-kbptr";
            rev = "f9e8e4379cd1f7c34ddb61346cad82e70e7a3546";
            hash = "sha256-bvVohwEpPHJEPQeDyTlDAkyFLEaGtwA+8Zqycz8dolw=";
          };
          postPatch =
            (old.postPatch or "")
            + ''
              sed -i '182,189d' src/main.c

              files=$(grep -rl "CAIRO_FONT_WEIGHT_NORMAL" src || true)
              if [ -n "$files" ]; then
                for f in $files; do
                  substituteInPlace "$f" --replace "CAIRO_FONT_WEIGHT_NORMAL" "CAIRO_FONT_WEIGHT_BOLD"
                done
              fi
            '';

          nativeBuildInputs =
            (old.nativeBuildInputs or [])
            ++ (with pkgs; [
              meson
              ninja
              pkg-config
            ]);
          buildInputs =
            (old.buildInputs or [])
            ++ [
              pkgs.opencv
            ];
          mesonFlags =
            (old.mesonFlags or [])
            ++ [
              "-Dopencv=enabled"
            ];
        });
      in [
        (pkgs.writeShellApplication {
          name = "wl-kbptr-ydotool-sway";
          text = ''
            set -euo pipefail

            active_area=$(${pkgs.sway}/bin/swaymsg -t get_tree | ${pkgs.jq}/bin/jq --raw-output '.. | (.nodes? + .floating_nodes? // empty)[] | select(.focused) | .rect | "\(.width)x\(.height)+\(.x)+\(.y)"')

            exec wl-kbptr-ydotool --restrict "$active_area" "''$@"
          '';
        })
        (pkgs.writeShellApplication {
          name = "wl-kbptr-ydotool";

          text = ''
            set -euo pipefail

            if ${pkgs.procps}/bin/pgrep -f "${wl-kbptr}/bin/wl-kbptr" >/dev/null; then
              exit 1
            fi
            read -r w h x y < <(
              ${wl-kbptr}/bin/wl-kbptr \
                --only-print \
                --config=/dev/null \
                -o home_row_keys=arstneioghb \
                -o modes=floating \
                -o mode_floating.source=detect \
                "$@" |
              ${pkgs.gawk}/bin/awk '{print $1}' |
              ${pkgs.gnused}/bin/sed -E 's/^([0-9]+)x([0-9]+)\+([0-9]+)\+([0-9]+)$/\1 \2 \3 \4/'
            )

            ${pkgs.ydotool}/bin/ydotool mousemove -a -x "$((x + w / 2))" -y "$((y + h / 2))"
            ${pkgs.ydotool}/bin/ydotool click 0xC0
          '';
        })
      ];

      xdg.configFile."wl-kbptr/config".text = lib.generators.toINI {} {
        general = {
          home_row_keys = "";
          modes = "floating";
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
  };
}
