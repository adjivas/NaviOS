{ pkgs, lib, config, ... }: {
  options = {
    steam.enable = lib.mkEnableOption "enable steam";
    steam.extraCompatPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ pkgs.proton-ge-bin ];
      description = "proton packages";
    };
  };
  config = lib.mkIf config.steam.enable {
    # Steam
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      extraCompatPackages = config.steam.extraCompatPackages;
      gamescopeSession = {
        enable = true;
        args = ["--prefer-vk-device 1002:744c"];
      };
    };
    programs.gamescope = {
      enable = true;
      capSysNice = true;
      args = ["--prefer-vk-device 1002:744c"];
    };
  };
}
