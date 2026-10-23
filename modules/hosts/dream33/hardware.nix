{
  den.aspects.dream33-hardware.nixos = {
    lib,
    pkgs,
    modulesPath,
    ...
  }: {
    imports = [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

    boot.initrd.availableKernelModules = [
      "xhci_pci"
      "nvme"
      "usb_storage"
    ];

    boot.initrd.luks.devices."crypted".device = "/dev/disk/by-uuid/53c4fac6-f2e6-4f82-84a5-1a71bf2f7bdd";

    fileSystems."/persistent" = {
      device = "/dev/mapper/crypted";
      fsType = "xfs";
      neededForBoot = true;
    };

    fileSystems."/nix" = {
      device = "/persistent/nix";
      fsType = "none";
      options = [
        "bind"
      ];

      depends = [
        "/persistent"
      ];

      neededForBoot = true;
    };

    fileSystems."/" = {
      device = "none";
      fsType = "tmpfs";
      options = [
        "defaults"
        "mode=755"
      ];
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/F1C6-15DC";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };

    swapDevices = [
      {
        device = "/persistent/swapfile";
        size = 12 * 1024;
      }
    ];

    nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

    boot.swraid = {
      enable = true;

      # TODO: Replace with real RAID failure notifications.
      mdadmConf = ''
        PROGRAM ${pkgs.coreutils}/bin/true
      '';
    };
  };
}
