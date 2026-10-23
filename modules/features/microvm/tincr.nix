{den, ...}: {
  den.aspects.microvm-tincr = {
    name,
    overlayAddress,
    overlayPub,
    tincName,
    connectTo ? ["dream33"],
    key ? "/run/host-secrets/${name}_ed25519.key",
    peers ? {
      dream33 = {
        address = "192.168.77.1";
        subnet = "10.77.0.1";
        pub = "QFIM9Valy8Qvbobpx2VlooEhCQ4cS6CaXVMjMpzRGKK";
      };
      dream05 = {
        subnet = "10.77.0.5";
        pub = "8XCzh6rYgQSsEcQswjqdv4hWVGwlgsUaYIwSKhpEsaG";
      };
      dream55 = {
        subnet = "10.77.0.55";
        pub = "29B2AM47TMupQWjE2+uwbERQo8V5rNGmp7TnvJmUtcD";
      };
      dream76 = {
        subnet = "10.77.0.76";
        pub = "/wKOy6voAz/7+85NWlgJzRb87WOnhbP0NMrHAWArRiG";
      };
    },
  }: {
    includes = [
      (den.aspects.tincr {
        inherit name key connectTo;

        netAddress = overlayAddress;

        hosts =
          peers
          // {
            ${name} = {
              subnet = overlayAddress;
              pub = overlayPub;
            };
          };
      })
    ];

    nixos = {
      networking.firewall.trustedInterfaces = [tincName];

      systemd.services."tincr-${name}".unitConfig.RequiresMountsFor = [
        "/run/host-secrets"
      ];
    };
  };
}
