{ lib, config, ... }: {
  options = {
    zathura.enable = lib.mkEnableOption "enable zathura";
  };
  config = lib.mkIf config.zathura.enable {
    programs.zathura = {
      enable = true;
      options = {
        font = "HackGen35 Console NF 15";

        selection-clipboard = "clipboard";
        incremental-search = true;
        window-title-home-tilde = true;
        recolor = false;
        recolor-keephue = true;
        zoom-max = 2000;
      };
      mappings = {
        D = "toggle_page_mode";
        i = "recolor";
        h = "scroll left";
        j = "scroll down";
        k = "scroll up";
        l = "scroll right";
        n = "navigate previous";
        N = "navigate next";
      };
    };
  };
}
