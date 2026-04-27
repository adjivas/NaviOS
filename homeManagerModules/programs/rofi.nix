{ pkgs, lib, config, ... }: {
  options = {
    rofi.enable = lib.mkEnableOption "enable rofi";

    rofi.package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.rofi;
      description = "rofi packages";
    };
    rofi.pass = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      description = "rofi pass";
    };
  };
  config = lib.mkIf config.rofi.enable {
    programs.rofi = {
      enable = true;
      package = config.rofi.package;
      pass = config.rofi.pass;
      extraConfig = { modi = "drun,window"; };

      # font = "${config.stylix.fonts.monospace.name} ${builtins.toString (config.stylix.fonts.sizes.desktop * 0.75)}";
      theme = lib.mkForce (builtins.toString (pkgs.writeText "rofi-theme" ''
        * {
          background-color: ${config.stylix.base16Scheme.base00};
          text-color: ${config.stylix.base16Scheme.base05};
          border-color: ${config.stylix.base16Scheme.base0C};
          font: "${config.stylix.fonts.monospace.name} ${builtins.toString (config.stylix.fonts.sizes.desktop * 0.75)}";
        }
        window {
          anchor:     north;
          location:   north;
          width:      100%;
          padding:    4px;
          children:   [ horibox ];
        }
        horibox {
          orientation: horizontal;
          children:   [ prompt, entry, listview ];
        }
        listview {
          layout:     horizontal;
          spacing:    5px;
          lines:      100;
        }
        entry {
          expand:     false;
          width:      10em;
        }
        element {
          padding: 0px 2px;
        }
        element selected {
          background-color: ${config.stylix.base16Scheme.base05};
          text-color: ${config.stylix.base16Scheme.base00};
        }

        element-text, element-icon {
          background-color: inherit;
          text-color: inherit;
        }
      ''));
    };
  };
}
