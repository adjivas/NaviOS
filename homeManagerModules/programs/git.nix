{ lib, config, ... }: {
  options = {
    git.enable = lib.mkEnableOption "enable git";
    git.userName = lib.mkOption {
      default = config.home.username;
      description = "username";
    };
    git.userEmail = lib.mkOption {
      default = "";
      description = "username";
    };
  };
  config = lib.mkIf config.git.enable {
    programs.git = {
      enable = true;
      settings.user = {
        name = config.git.userName;
        email = config.git.userEmail;
        init.defaultBranch = "main";
      };
    };
  };
}
