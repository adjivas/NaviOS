{ pkgs, lib, config, ... }: {
  options = {
    bemenu.enable = lib.mkEnableOption "enable bemenu";

    bemenu.package = lib.mkOption {
      type = lib.types.package;
      default = (pkgs.bemenu.override { waylandSupport = true; x11Support = false; });
      description = "bemenu packages";
    };
    bemenu.prompt = lib.mkOption {
      type = lib.types.str;
      default = ">";
    };
    bemenu.line-height = lib.mkOption {
      type = lib.types.int;
      default = 25;
    };
    bemenu.extraSettings = lib.mkOption {
      type = lib.types.attrs;
      default = {};
    };
  };
  config = lib.mkIf config.bemenu.enable {
    programs.bemenu = {
      enable = true;
      package = config.bemenu.package;

      settings = lib.mkForce (lib.recursiveUpdate config.bemenu.extraSettings {
        prompt = config.bemenu.prompt;
        line-height = config.bemenu.line-height;
        hp = 10.5;
        hf = config.stylix.base16Scheme.base0C;
        cf = config.stylix.base16Scheme.base05;
        fb = config.stylix.base16Scheme.base00;
        ff = config.stylix.base16Scheme.base05;
        nb = config.stylix.base16Scheme.base00;
        nf = config.stylix.base16Scheme.base05;
        tb = config.stylix.base16Scheme.base00;
        hb = config.stylix.base16Scheme.base00;
        tf = config.stylix.base16Scheme.base05;
        af = config.stylix.base16Scheme.base05;
        ab = config.stylix.base16Scheme.base00;
        fn = "${config.stylix.fonts.monospace.name} ${builtins.toString (config.stylix.fonts.sizes.desktop * 0.75)}";
      });
    };
  };
}
