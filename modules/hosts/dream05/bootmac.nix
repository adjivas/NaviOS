# NixOS module for WiFi and Bluetooth MAC address configuration at boot using
# bootmac.
#
# This module configures MAC addresses for WLAN and Bluetooth interfaces at boot.
# It generates deterministic MAC addresses from the device's serial number.
#
# Without this, both WiFi and Bluetooth will use randomly generated MAC addresses
# that change on every reboot, causing issues with network identification and
# Bluetooth pairing.
{den, ...}: {
  den.aspects.dream05-bootmac.nixos = {
    lib,
    pkgs,
    ...
  }: {
    options.dream05-bootmac = {
      bluetooth.interface = lib.mkOption {
        type = lib.types.str;
        default = "hci0";
        description = "Name of the Bluetooth interface to configure.";
      };

      wifi.interface = lib.mkOption {
        type = lib.types.str;
        default = "wlan0";
        description = "Name of the WiFi interface to configure.";
      };

      macPrefix = lib.mkOption {
        type = lib.types.str;
        default = "0200";
        description = ''
          MAC address prefix to use when generating addresses.

          The default "0200" indicates a locally administered unicast address.
          Can be set to a longer value like an IEEE OUI if needed.
        '';
      };

      timeout = lib.mkOption {
        type = lib.types.int;
        default = 5;
        description = ''
          Timeout in seconds for setting MAC addresses.

          If the interface is not ready, bootmac will retry for this many seconds
          before giving up.
        '';
      };
    };

    config = {
      # Ensure bootmac package is available.
      environment.systemPackages = [
        pkgs.bootmac
      ];
    };
  };

  den.aspects.dream05-bluetooth = {
    includes = [
      den.aspects.dream05-bootmac
    ];

    nixos = {
      config,
      pkgs,
      ...
    }: {
      # Enable Bluetooth.
      hardware.bluetooth = {
        enable = true;
        powerOnBoot = true;
      };

      # Systemd service to set Bluetooth MAC address before `bluetoothd` starts.
      systemd.services.bootmac-bluetooth = {
        description = "Set Bluetooth MAC address";

        # Wait for the Bluetooth device to be available.
        after = [
          "sys-subsystem-bluetooth-devices-${config.dream05-bootmac.bluetooth.interface}.device"
        ];
        requires = [
          "sys-subsystem-bluetooth-devices-${config.dream05-bootmac.bluetooth.interface}.device"
        ];

        # Run before bluetooth.service starts.
        before = ["bluetooth.service"];
        wantedBy = ["bluetooth.service"];

        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;

          ExecStart =
            "${pkgs.bootmac}/bin/bootmac "
            + "--bluetooth-if ${config.dream05-bootmac.bluetooth.interface} "
            + "--prefix ${config.dream05-bootmac.macPrefix}";

          Environment = "BT_TIMEOUT=${toString config.dream05-bootmac.timeout}";
        };
      };
    };

    # Ensure bluez is available for btmgmt command (required for Bluetooth).
    services.blueman.enable = true;
  };

  den.aspects.dream05-wifi = {
    includes = [
      den.aspects.dream05-bootmac
    ];

    nixos = {
      config,
      pkgs,
      ...
    }: {
      # Systemd service to set WiFi MAC address before network starts.
      systemd.services.bootmac-wifi = {
        description = "Set WiFi MAC address";

        # Wait for the WiFi network device to be available.
        after = [
          "sys-subsystem-net-devices-${config.dream05-bootmac.wifi.interface}.device"
        ];
        requires = [
          "sys-subsystem-net-devices-${config.dream05-bootmac.wifi.interface}.device"
        ];

        # Run before network starts.
        before = ["network-pre.target"];
        wantedBy = ["network-pre.target"];

        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;

          ExecStart =
            "${pkgs.bootmac}/bin/bootmac "
            + "--wlan-if ${config.dream05-bootmac.wifi.interface} "
            + "--prefix ${config.dream05-bootmac.macPrefix}";

          Environment = "WLAN_TIMEOUT=${toString config.dream05-bootmac.timeout}";
        };
      };
    };
  };
}
