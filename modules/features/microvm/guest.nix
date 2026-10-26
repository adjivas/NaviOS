{
  den,
  inputs,
  ...
}: {
  den.aspects.microvm-guest = {
    name,
    underlayAddress,
    macAddress,
    tapName ? "tap-${name}",
    vsockCid ? 30,
    vcpu,
    mem,
    shares ? [],
  }: {
    includes = [
      den.aspects.microvm-rootless-virtiofsd
    ];

    nixos = {
      imports = [
        inputs.microvm.nixosModules.microvm
      ];

      networking.firewall = {
        enable = true;

        interfaces.${tapName} = {
          allowedTCPPorts = [655];
          allowedUDPPorts = [655];
        };
      };

      systemd.network = {
        enable = true;

        networks."20-underlay" = {
          matchConfig.MACAddress = macAddress;

          address = [
            "${underlayAddress}/24"
          ];

          linkConfig.RequiredForOnline = false;
        };
      };

      microvm = {
        inherit vcpu mem;

        hypervisor = "cloud-hypervisor";

        kernelParams = ["console=ttyAMA0"];

        cloud-hypervisor.extraArgs = [
          "--serial"
          "socket=/run/microvm-${name}/serial.sock"
          "--console"
          "off"
        ];

        machineId = builtins.substring 0 32 (builtins.hashString "sha256" name);

        vsock.cid = vsockCid;

        virtiofsd = {
          inodeFileHandles = "never";
          group = "users";
        };

        shares =
          [
            {
              source = "/nix/store";
              mountPoint = "/nix/.ro-store";
              tag = "ro-store";
              proto = "virtiofs";
              socket = "/run/microvm-${name}/ro-store.sock";
            }
            {
              source = ".secrets";
              mountPoint = "/run/host-secrets";
              tag = "tincr-secrets";
              proto = "virtiofs";
              readOnly = true;
              socket = "/run/microvm-${name}/tincr-secrets.sock";
            }
            {
              source = "/var/lib/microvms/${name}/journal";
              mountPoint = "/var/log/journal";
              tag = "journal";
              proto = "virtiofs";
              socket = "/run/microvm-${name}/journal.sock";
            }
          ]
          ++ shares;

        interfaces = [
          {
            type = "tap";
            id = tapName;
            mac = macAddress;
          }
        ];

        socket = "/run/microvm-${name}/control.socket";
        writableStoreOverlay = "/nix/.rw-store";
      };
    };
  };
}
