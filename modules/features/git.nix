{
  den.aspects.git.homeManager = {
    lib,
    config,
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
        settings.user = {
          name = config.git.userName;
          email = config.git.userEmail;
          init.defaultBranch = "master";
        };
      };
    };
  };
}
