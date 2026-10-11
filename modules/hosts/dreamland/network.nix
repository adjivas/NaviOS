{
  den.aspects.dreamland-network.nixos = {lib, ...}: {
    options.dreamland.network = {
      wifi.address = lib.mkOption {
        type = lib.types.listOf lib.types.str;
      };
    };

    config = {
      networking = {
        useDHCP = false;

        networkmanager = {
          enable = true;
          wifi.backend = "iwd";

          unmanaged = [
            "interface-name:enp48s0"
            "interface-name:br0"
          ];
        };
      };

      services.resolved.enable = true;

      systemd.network = {
        enable = true;
        wait-online.enable = false;

        networks."30-ethernet" = {
          matchConfig.Name = "enp48s0";

          linkConfig.RequiredForOnline = "no";

          networkConfig = {
            DHCP = "yes";
          };
        };
      };
    };
  };
}
