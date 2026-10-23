{
  den.aspects.dreamland-network = {
    ethernetAddress ? null,
    ethernetName ? "en*",
  }: {
    nixos = {lib, ...}: {
      networking = {
        useDHCP = false;

        networkmanager = {
          enable = true;
          wifi.backend = "iwd";

          unmanaged = [
            "interface-name:${ethernetName}"
            "interface-name:br0"
          ];
        };
      };

      services.resolved.enable = true;

      systemd.network = {
        enable = true;
        wait-online.enable = false;

        networks."30-ethernet" = {
          matchConfig.Name = ethernetName;

          linkConfig.RequiredForOnline = "no";

          networkConfig.DHCP =
            if ethernetAddress == null
            then "yes"
            else "no";

          address = lib.optionals (ethernetAddress != null) [
            ethernetAddress
          ];
        };
      };
    };
  };
}
