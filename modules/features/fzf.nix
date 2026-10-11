{
  den.aspects.fzf.homeManager = {
    config,
    lib,
    pkgs,
    wrappers,
    ...
  }: {
    options.fzf = {
      colors = {
        background = lib.mkOption {
          type = lib.types.str;
          default = "#0dcdcd";
        };

        foreground = lib.mkOption {
          type = lib.types.str;
          default = "#000000";
        };
      };

      package = lib.mkOption {
        type = lib.types.package;
        readOnly = true;

        default = wrappers {
          inherit pkgs;

          package = pkgs.fzf;
          exePath = lib.getExe pkgs.fzf;
          binName = "fzf";

          flags = {
            "--highlight-line" = true;
            "--color" =
              "current-bg:${config.fzf.colors.background},"
              + "current-fg:${config.fzf.colors.foreground}";
          };
        };
      };
    };

    config.programs.fzf = {
      enable = true;
      enableBashIntegration = true;

      package = config.fzf.package;
    };
  };
}
