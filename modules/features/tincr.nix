{lib, ...}: {
  den.batteries.tincr = {
    name,
    interfaceName ? "tinc-${name}",
    key,
    netAddress ? "10.77.0.1",
    dnsAddress ? null,
    connectTo ? [],
    autoConnect ? false,
    hosts ? {},
  }: {
    nixos = {config, ...}: {
      services.tincr.networks.${name} =
        {
          nodeName = name;
          inherit interfaceName connectTo autoConnect;

          addresses = ["${netAddress}/24"];
          ed25519PrivateKeyFile = key config;

          hosts =
            lib.mapAttrs (_: host: ''
              Subnet = ${host.subnet}/32
              Ed25519PublicKey = ${host.pub}
              ${lib.optionalString (host.tcpOnly or false) "TCPOnly = yes"}
              ${lib.optionalString ((host.address or null) != null) "Address = ${host.address}"}
            '')
            hosts;

          openFirewall = true;
          socketActivation = false;
        }
        // lib.optionalAttrs (dnsAddress != null) {
          dns = {
            enable = true;
            suffix = name;
            address4 = dnsAddress;
          };
        };
    };
  };
}
