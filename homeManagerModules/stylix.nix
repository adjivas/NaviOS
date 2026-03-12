{ pkgs, lib, config, ... }: {
  options.stylix-theme = {
    scheme = lib.mkOption {
      type = lib.types.attrs;
      default = {};
    };
    cursorPackage = lib.mkOption {
      type = lib.types.package;
      default = pkgs.adwaita-icon-theme;
    };
  };
  config = {
    stylix = {
      enable = true;
      # Kitty Color https://raw.githubusercontent.com/kovidgoyal/kitty-themes/master/template.conf
      # Kitty Themes https://github.com/dexpota/kitty-themes/tree/master
      # Japanesque?
      # Bright Lights?
      # Glacier?
      # base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
      base16Scheme = let
        base = {
          scheme = "Navy Industry";
          author = "navi";

          base00 = "#1c1b22"; # background terminal, unified with all the other apps
          base08 = "#cc0403"; # waybar urgent

          base01 = "#767676";
          base09 = "#ff8700"; # waybar warning

          base02 = "#0d73cc";
          base0A = "#cecb00";

          base03 = "#767676";
          base0B = "#81e476";

          base04 = "#dddddd";
          base0C = "#0dcdcd";

          base05 = "#ffffff";
          base0D = "#0d73cc";

          base06 = "#ffffff";
          base0E = "#c81dce";

          base07 = "#ffffff";
          base0F = "#875f00";
        };
      in (lib.recursiveUpdate base config.stylix-theme.scheme);

      polarity = "dark";

      cursor = {
        name = "Adwaita";
        package = config.stylix-theme.cursorPackage;
        size = 24;
      };
      targets = {
        kitty.enable = false;
        sway.enable = false;
      };
      fonts = {
        monospace = {
          package = pkgs.hackgen-nf-font;
          name = "HackGen35 Console NF";
        };
        sizes = {
          terminal = 15;
          desktop = 18;
        };
      };
    };
  };
}
