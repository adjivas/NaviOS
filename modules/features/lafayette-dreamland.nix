{den, ...}: {
  den.aspects.lafayette-dreamland = {
    includes = [
      den.aspects.lafayette
    ];

    nixos = {pkgs, ...}: {
      lafayette.path = pkgs.writeText "lafayette-dreamland.toml" ''
        name = "Qwerty-Lafayette"
        name8 = "Qwerty-L"
        locale = "fr"
        variant = "lafayette"
        author = "Fabien Cazenave (:kazé), dreamland"
        description = "French (Qwerty-Lafayette Dream-Land)"
        url = "https://github.com/fabi1cazenave/qwerty-lafayette"
        geometry = "ERGO"
        version = "0.9.2"

        base = ''''
        ╭╌╌╌╌╌┰─────┬─────┬─────┬─────┬─────┰─────┬─────┬─────┬─────┬─────┰╌╌╌╌╌┬╌╌╌╌╌╮
        ┆ ~   ┃ !   │ @   │ #   │ $   │ %   ┃ ^   │ &   │ *   │ (   │ )   ┃ _   ┆ + ± ┆
        ┆ `   ┃ 1   │ 2   │ 3   │ 4   │ 5 ‰ ┃ 6   │ 7   │ 8   │ 9   │ 0 ° ┃ - — ┆ = ≠ ┆
        ╰╌╌╌╌╌╂─────┼─────┼─────┼─────┼─────╂─────┼─────┼─────┼─────┼─────╂╌╌╌╌╌┼╌╌╌╌╌┤
        ·     ┃ Q   │ W   │ E   │ R   │ T   ┃ Y   │ U   │ I   │ O   │ P   ┃ {   ┆ }   ┆
        ·     ┃   æ │   é │   è │     │     ┃     │   ù │   ï │   œ │     ┃ [   ┆ ]   ┆
        ·     ┠─────┼─────┼─────┼─────┼─────╂─────┼─────┼─────┼─────┼─────╂╌╌╌╌╌┼╌╌╌╌╌┤
        ·     ┃ A   │ S   │ D   │ F   │ G   ┃ H   │ J   │ K   │ L   │**   ┃ "   ┆ |   ┆
        ·     ┃   à │     │   ê │     │     ┃   ŷ │   û │   î │   ô │  *¨ ┃ '   ┆ \   ┆
        ╭╌╌╌╌╌╂─────┼─────┼─────┼─────┼─────╂─────┼─────┼─────┼─────┼─────╂╌╌╌╌╌┴╌╌╌╌╌╯
        ┆ >   ┃ Z ≤ │ X ≥ │ C   │ V   │ B   ┃ N   │ M   │ ;   │ :   │ ?   ┃           ·
        ┆ <   ┃   < │   > │   ç │     │     ┃     │     │ ,   │ .   │ /   ┃           ·
        ╰╌╌╌╌╌┸─────┴─────┴─────┴─────┴─────┸─────┴─────┴─────┴─────┴─────┚ · · · · · ·
        ''''

        [spacebar]
        shift       = "\u2019"  # RIGHT SINGLE QUOTATION MARK
        1dk         = "\u2019"  # RIGHT SINGLE QUOTATION MARK
        1dk_shift   = "\u2019"  # RIGHT SINGLE QUOTATION MARK

        [layer.nav]
        h = "Left"
        j = "Down"
        k = "Up"
        l = "Right"
      '';
    };
  };
}
