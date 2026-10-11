{
  den.aspects.git.homeManager = {
    config,
    pkgs,
    lib,
    ...
  }: {
    options.git = {
      userName = lib.mkOption {
        default = config.home.username;
        description = "username";
      };
      userEmail = lib.mkOption {
        default = "";
        description = "username";
      };
    };
    config = {
      programs.git = {
        enable = true;
        settings = {
          user = {
            name = config.git.userName;
            email = config.git.userEmail;
          };
          init.defaultBranch = "master";
        };
      };

      home.shellAliases = {
        # Git
        set-url = "${lib.getExe pkgs.git} remote set-url origin";
      };
    };
  };
}
