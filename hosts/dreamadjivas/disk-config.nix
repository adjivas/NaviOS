{ lib, ... }: {
  disko.devices = {
    disk.dream00 = {
      imageSize = "32G";
      imageName = "nixos-x86_64-linux-generic-btrfs";
      device = lib.mkDefault "/dev/disk/by-id/ata-Samsung_SSD_860_EVO_500GB_S4XDNF0M914953K";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            label = "dreamboot";
            name = "ESP";
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [
                "defaults"
              ];
            };
          };
          luks = {
            name = "luks";
            size = "100%";
            content = {
              type = "luks";
              name = "cryptroot";
              passwordFile = "/tmp/disk.key";
              settings = {
                allowDiscards = true;
                crypttabExtraOpts = [
                  "fido2-device=auto" "token-timeout=10"
                ];
              };
              extraOpenArgs = [
                "--perf-no_read_workqueue"
                "--perf-no_write_workqueue"
              ];
              content = {
                type = "btrfs";
                extraArgs = ["-L" "nixos" "-f"];
                subvolumes = {
                  "/nix" = {
                    mountpoint = "/nix";
                    mountOptions = ["subvol=nix" "compress=zstd" "noatime"];
                  };
                  "/nix/persistent" = {
                    mountpoint = "/nix/persistent";
                    mountOptions = ["subvol=persistent" "compress=zstd" "noatime"];
                  };
                  "/nix/swap" = {
                    mountpoint = "/nix/swap";
                    mountOptions = [ "subvol=swap" "noatime" "nodatacow" ];
                  };
                };
              };
            };
          };
        };
      };
    };
  };

  fileSystems."/" = {
    device = "tmpfs";
    fsType = "tmpfs";
    options = [ "mode=755" ];
  };

  fileSystems."/nix/persistent" = {
    neededForBoot = true;
  };

  swapDevices = [
    {
      device = "/nix/swap/swapfile";
      size = 32768;
    }
  ];
}
