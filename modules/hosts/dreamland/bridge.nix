{
  den.aspects.dreamland-bridge.nixos = {
    lib,
    config,
    ...
  }: {
    options.dreamland.network.bridge = {
      address = lib.mkOption {
        type = lib.types.listOf lib.types.str;
      };
    };

    config = {
      systemd.network = {
        enable = true;

        netdevs."br0" = {
          netdevConfig = {
            Name = "br0";
            Kind = "bridge";
          };
        };

        networks = {
          "10-lan-bridge-members" = {
            matchConfig.Name = [
              "eno1"
              "enp48s0"
              "vm-*"
              "vnet*"
              "tap-*"
            ];

            networkConfig.Bridge = "br0";

            linkConfig.RequiredForOnline = false;
          };

          "10-lan-bridge" = {
            matchConfig.Name = "br0";

            networkConfig = {
              Address = config.dreamland.network.bridge.address;
              Gateway = "192.168.1.1";
              DNS = ["192.168.1.1"];
              IPv6AcceptRA = true;
            };

            linkConfig.RequiredForOnline = false;
          };
        };
      };
    };
  };
}
