{
  den.aspects.usbip.nixos = {
    lib,
    config,
    ...
  }: {
    options.usbip = {
      server.enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable the USB/IP server daemon.";
      };
      client.enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable the USB/IP client support.";
      };
      port = lib.mkOption {
        type = lib.types.port;
        default = 3240;
      };
    };
    config = {
      environment.systemPackages = [
        config.boot.kernelPackages.usbip
      ];

      boot.kernelModules =
        ["usbip-core"]
        ++ lib.optionals config.usbip.server.enable ["usbip-host"]
        ++ lib.optionals config.usbip.client.enable ["vhci-hcd"];

      systemd.services.usbipd = {
        description = "USB/IP daemon";
        wantedBy = ["multi-user.target"];
        after = ["network.target"];

        serviceConfig = {
          Type = "simple";

          ExecStart = ''
            ${config.boot.kernelPackages.usbip}/bin/usbipd \
              --tcp-port ${toString config.usbip.port}
          '';

          Restart = "on-failure";
          RestartSec = 2;
        };
      };
    };
  };
}
