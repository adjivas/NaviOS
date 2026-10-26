{
  den.aspects.lafayette.nixos = {
    config,
    pkgs,
    lib,
    ...
  }: {
    options.lafayette = {
      path = lib.mkOption {
        type = lib.types.path;
      };
    };

    config = let
      xkbRoot = pkgs.runCommand "root-xkb-config" {} ''
        mkdir -p $out

        cp -rL ${pkgs.xkeyboard_config}/share/X11/xkb/. $out/
        chmod -R u+w $out

        cat > $out/symbols/root <<'EOF'
        partial modifier_keys
        xkb_symbols "system_caps" {
          replace key <CAPS> {
            [ Super_L ]
          };

          modifier_map None { <CAPS> };
          modifier_map Mod4 { <CAPS> };
        };
        EOF
      '';

      lafayetteBuild = pkgs.runCommand "lafayette-xkb" {} ''
        set -eu

        ${pkgs.kalamine}/bin/kalamine build ${config.lafayette.path}

        for file in dist/qwerty-l.xkb_keymap dist/qwerty-l.xkb_symbols; do
          sed -i '/key <AC10>/s/dead_diaeresis/VoidSymbol/' "$file"
        done

        sed -i \
          '/include "inet(evdev)"/a\    include "root(system_caps)"' \
          dist/qwerty-l.xkb_keymap

        mkdir -p $out

        install -m 0644 dist/qwerty-l.xkb_keymap "$out/qwerty-l.xkb_keymap"
        install -m 0644 dist/qwerty-l.xkb_symbols "$out/qwerty-l.xkb_symbols"
      '';
    in {
      environment.systemPackages = with pkgs; [
        kalamine
        xkeyboard_config
        setxkbmap
      ];

      environment.sessionVariables.XKB_CONFIG_ROOT = "/etc/X11/xkb";

      environment.etc."X11/xkb".source = xkbRoot;

      environment.etc."lafayette/qwerty-l.xkb_keymap".source = "${lafayetteBuild}/qwerty-l.xkb_keymap";

      environment.etc."lafayette/qwerty-l.xkb_symbols".source = "${lafayetteBuild}/qwerty-l.xkb_symbols";

      environment.etc."lafayette/qwerty-l.toml".source = config.lafayette.path;
    };
  };
}
