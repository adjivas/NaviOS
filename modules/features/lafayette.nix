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
      lafayetteBuild =
        pkgs.runCommand "lafayette-xkb" {
          nativeBuildInputs = [pkgs.kalamine];
        } ''
          set -eu

          ${pkgs.kalamine}/bin/kalamine build ${config.lafayette.path}

          mkdir -p $out
          install -m 0644 "dist/qwerty-l.xkb_keymap"  "$out/qwerty-l.xkb_keymap"
          install -m 0644 "dist/qwerty-l.xkb_symbols" "$out/qwerty-l.xkb_symbols"
        '';
    in {
      environment.systemPackages = with pkgs; [kalamine xkeyboard_config setxkbmap];

      environment.sessionVariables.XKB_CONFIG_ROOT = "/etc/X11/xkb";

      environment.etc."X11/xkb".source = "${pkgs.xkeyboard_config}/share/X11/xkb";
      environment.etc."lafayette/qwerty-l.xkb_keymap".source = "${lafayetteBuild}/qwerty-l.xkb_keymap";
      environment.etc."lafayette/qwerty-l.xkb_symbols".source = "${lafayetteBuild}/qwerty-l.xkb_symbols";

      environment.etc."lafayette/qwerty-l.toml".source = config.lafayette.path;
    };
  };
}
