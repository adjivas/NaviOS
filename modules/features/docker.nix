{
  den.aspects.docker.nixos = {
    config,
    lib,
    ...
  }: {
    options.docker = {
      data-root = lib.mkOption {
        type = lib.types.path;
        default = "/nix/persistent/docker";
      };
    };

    config = {
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
  };
}
