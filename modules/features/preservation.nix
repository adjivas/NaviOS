{inputs, ...}: {
  den.aspects.preservation.nixos = {
    imports = [
      inputs.preservation.nixosModules.preservation
    ];

    preservation = {
      enable = true;

      preserveAt."/nix/persistent" = {
        files = [
          {
            file = "/etc/machine-id";
            inInitrd = true;
          }
        ];

        directories = [
          "/secrets"
          "/var/log"
          "/var/lib/nixos"
          "/var/lib/systemd/timers"
          "/var/lib/bluetooth"
          "/var/lib/NetworkManager"
          "/var/lib/tincr"
          "/var/lib/waydroid"
          {
            directory = "/etc/NetworkManager/system-connections";
            mode = "0700";
          }
        ];
      };
    };

    systemd.suppressedSystemUnits = [
      "systemd-machine-id-commit.service"
    ];
  };

  den.aspects.preservation-user = directories: {user, ...}: {
    nixos = {
      preservation.preserveAt."/nix/persistent".users.${user.name}.directories = directories;
    };
  };
}
