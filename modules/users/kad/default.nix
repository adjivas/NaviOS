{
  den.aspects.kad.homeManager = {
    config,
    pkgs,
    ...
  }: {
    home.shellAliases = {
      zathura = "${pkgs.zathura}/bin/zathura --fork";
    };

    nvf = {
      mouse = "a";
    };
    git = {
    };

    stylix.targets.firefox.profileNames = [config.firefox.profileName];
  };
}
