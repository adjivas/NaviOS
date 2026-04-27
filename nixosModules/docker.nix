{ pkgs, lib, config, ... }: {
  options = {
    docker.enable = lib.mkEnableOption "enable docker";
    docker.data-root = lib.mkOption {
      type = lib.types.str;
      default = "/nix/persistent/docker";
    };
  };
  config = lib.mkIf config.docker.enable {
    boot.kernel.sysctl."net.ipv4.ip_forward" = true;

    virtualisation.docker = {
      enable = true;
      enableOnBoot = true;
      autoPrune.enable = true;
      daemon.settings = {
        data-root = config.docker.data-root;
      };
    };
  };
}
