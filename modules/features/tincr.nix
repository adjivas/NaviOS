{
  inputs,
  lib,
  ...
}: let
  description = ''
    ## Example
    Configure the aspect:
    '''nix
    (den.aspects.tincr {
      name = "dreamland";
      key = config: config.age.secrets.tincr_dream00_ed25519_key.path;

      netAddress = "10.77.0.1";
      dnsAddress = "10.77.0.254";

      hosts = {
        dreamland = {
          subnet = "10.77.0.1";
          pub = "x+HORyUyUS2taqEWq3TY0IOghkfA2kJfv8u5Ed6XS0P";
        };

        firefox = {
          subnet = "10.77.0.10";
          pub = "vsl/XNVEVSA5IFrMs/2GBVDdm8p35ByRqDT3hK6Va/B";
        };
      };
    })
    ```
    Configure the network:
    ```nix
    networking.hosts = {
      "10.77.0.22" = ["meta.sr.ht.local" "git.sr.ht.local"];
      "192.168.77.50" = ["drive" "auth.drive" "s3.drive"];
      "192.168.77.51" = ["tchap" "auth.tchap"];
      "192.168.77.52" = ["grist"];
      "192.168.1.143" = ["dream33"];
    };
    networking.firewall.trustedInterfaces = [
      "tinc-dreamland"
    ];
    ```
    Configure the secret:
    ```
    age.secrets.tincr_dream00_ed25519_key = {
      owner = "tincr";
      group = "tincr";
      mode = "0400";
    };
    ```
  '';
in {
  den.aspects.tincr = {
    name,
    interfaceName ? "tinc-${name}",
    key,
    netAddress ? "10.77.0.1",
    dnsAddress ? null,
    connectTo ? [],
    hosts ? [],
    autoConnect ? false,
  }: {
    inherit description;
    nixos = {
      config,
      pkgs,
      ...
    }: {
      imports = [
        inputs.tincr.nixosModules.tincr
      ];
      environment.systemPackages = [
        inputs.tincr.packages.${pkgs.stdenv.hostPlatform.system}.tincd
      ];

      # networking.firewall = {
      #   allowedTCPPorts = [655];
      #   allowedUDPPorts = [655];
      # };
      services.tincr.networks.${name} =
        {
          nodeName = name;
          inherit interfaceName connectTo autoConnect;

          addresses = [
            "${netAddress}/24"
          ];

          ed25519PrivateKeyFile =
            if lib.isFunction key
            then key config
            else key;
          hosts =
            lib.mapAttrs (_: host: let
              addresses =
                (lib.optional ((host.address or null) != null) host.address)
                ++ (host.addresses or []);
            in ''
              Subnet = ${host.subnet}/32
              Ed25519PublicKey = ${host.pub}
              ${lib.optionalString (host.tcpOnly or false) "TCPOnly = yes"}
              ${lib.concatMapStringsSep "\n" (address: "Address = ${address}") addresses}
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
