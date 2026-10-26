{
  den.aspects.nvidia = {
    nvidiaBusId,
    intelBusId,
  }: {
    nixos = {
      config,
      lib,
      ...
    }: {
      options.nvidia.package = lib.mkOption {
        type = lib.types.package;
        default = config.boot.kernelPackages.nvidiaPackages.latest;
      };

      config = {
        services.xserver.videoDrivers = ["modesetting" "nvidia"];

        hardware.nvidia = {
          modesetting.enable = true;
          powerManagement.enable = false;
          powerManagement.finegrained = false;
          open = false;
          nvidiaSettings = true;

          prime = {
            offload.enable = true;
            offload.enableOffloadCmd = true;

            inherit nvidiaBusId intelBusId;
          };

          package = config.nvidia.package;
        };
      };
    };
  };
}
