{ pkgs, lib, config, ... }: {
  options = {
    newsboat.enable = lib.mkEnableOption "enable newsboat";

    newsboat.browser = lib.mkOption {
      type = lib.types.str;
      default = "${pkgs.firefox}/bin/firefox";
    };
    newsboat.urls = lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      default = [];
    };
  };
  config = lib.mkIf config.newsboat.enable {
    programs.newsboat = {
      enable = true;
      browser = config.newsboat.browser;
      urls = config.newsboat.urls;
      maxItems = 50;
      autoReload = true;
      extraConfig = ''
        bind-key j down
        bind-key k up
        bind-key J next-feed articlelist
        bind-key K prev-feed articlelist
        bind-key G end
        bind-key g home
        bind-key l open
        bind-key h quit
      '';
    };
  };
}
