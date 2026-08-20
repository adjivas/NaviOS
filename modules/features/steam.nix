{
  den.aspects.steam.nixos = {
    config,
    pkgs,
    lib,
    ...
  }: {
    options.steam = {
      extraCompatPackages = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [pkgs.proton-ge-bin];
        description = "proton packages";
      };
    };
    config = {
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
      security.wrappers.bwrap = lib.mkForce {
        source = "${pkgs.bubblewrap}/bin/bwrap";
        owner = "root";
        group = "root";
        permissions = "u=rwx,g=rx,o=rx";
      };
    };
  };
}
