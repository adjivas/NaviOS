{
  den.aspects.newsboat.homeManager = {
    config,
    pkgs,
    lib,
    ...
  }: {
    options.newsboat = {
      browser = lib.mkOption {
        type = lib.types.str;
        default = "${pkgs.firefox}/bin/firefox";
      };
      urls = lib.mkOption {
        type = lib.types.listOf lib.types.attrs;
        default = [];
      };
    };
    config = {
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
  };
}
