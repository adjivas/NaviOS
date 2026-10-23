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
          "/var/lib/nixos"
          "/var/lib/systemd/timers"
          "/var/log"
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
