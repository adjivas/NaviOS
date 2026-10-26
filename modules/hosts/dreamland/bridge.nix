{
  den.aspects.dreamland-bridge.nixos = {
    config,
    lib,
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

        netdevs."10-br0" = {
          netdevConfig = {
            Name = "br0";
            Kind = "bridge";
          };
        };

        networks = {
          "10-vm-bridge-members" = {
            matchConfig.Name = [
              "vm-*"
              "vnet*"
              "tap-*"
            ];

            networkConfig.Bridge = "br0";

            linkConfig.RequiredForOnline = false;
          };
          "20-vm-bridge" = {
            matchConfig.Name = "br0";

            address = config.dreamland.network.bridge.address;

            networkConfig = {
              ConfigureWithoutCarrier = true;
              # IPv6AcceptRA = false;
            };

            linkConfig.RequiredForOnline = false;
          };
        };
      };
    };
  };
}
