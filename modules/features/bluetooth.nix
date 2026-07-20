{
  den.aspects.bluetooth.nixos = {
    pkgs,
    lib,
    ...
  }: {
    options.bluetooth = {
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.bluez-experimental;
        description = "bluetooth packages";
      };
    };

    config = {
      hardware.bluetooth = {
        enable = true;
        package = pkgs.bluez-experimental;
        powerOnBoot = true;
        settings = {
          General = {
            ControllerMode = "dual";
            Experimental = true;
            FastConnectable = true;
          };
          Policy = {
            AutoEnable = true;
          };
        };
      };
    };
  };
}
