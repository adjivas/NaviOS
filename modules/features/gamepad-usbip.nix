{
  den.aspects.gamepad-usbip.nixos = {
    config,
    lib,
    ...
  }: {
    services.udev.extraRules = lib.mkAfter ''
      ACTION=="add", SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", \
        ATTR{idVendor}=="054c", ATTR{idProduct}=="09cc", \
        TAG+="systemd", \
        ENV{SYSTEMD_WANTS}+="usbip-bind@%k.service"
    '';

    systemd.services."usbip-bind@" = {
      description = "Export USB device %i through USB/IP";

      requires = [
        "usbipd.service"
      ];

      after = [
        "usbipd.service"
        "systemd-modules-load.service"
      ];

      unitConfig.ConditionPathExists = "/sys/bus/usb/devices/%i";

      serviceConfig = {
        Type = "oneshot";

        ExecStart = "${config.boot.kernelPackages.usbip}/bin/usbip bind --busid=%i";
      };
    };
  };
}
