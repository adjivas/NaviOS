{
  den.aspects.dream33-bridge.nixos = {
    pkgs,
    lib,
    ...
  }: let
    id = "srht";
    bridge = "br0";
    user = "adjivas";
  in {
    networking.bridges.${bridge}.interfaces = [];

    networking.interfaces.${bridge}.ipv4.addresses = [
      {
        address = "192.168.77.1";
        prefixLength = 24;
      }
    ];

    systemd.services."microvm-tap-${id}" = {
      description = "Prepare TAP interface tap-${id}";
      wantedBy = ["multi-user.target"];
      after = ["network.target" "sys-subsystem-net-devices-${bridge}.device"];
      requires = ["sys-subsystem-net-devices-${bridge}.device"];

      path = [pkgs.iproute2];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };

      script = ''
        if ! ip link show tap-${id} >/dev/null 2>&1; then
          ip tuntap add \
            dev tap-${id} \
            mode tap \
            user ${lib.escapeShellArg user} \
            multi_queue \
            vnet_hdr
        fi

        ip link set tap-${id} master ${lib.escapeShellArg bridge}
        ip link set tap-${id} up
      '';

      preStop = ''
        ip link delete tap-${id} 2>/dev/null || true
      '';
    };
  };
}
