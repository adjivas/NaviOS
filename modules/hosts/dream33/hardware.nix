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

    fileSystems."/" = {
      device = "/dev/mapper/crypted";
      fsType = "xfs";
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/F1C6-15DC";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };

    nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

    fileSystems."/home/adjivas/.secrets" = {
      device = "/nix/persistent/home/adjivas/.secrets";
      fsType = "none";
      options = [
        "bind"
      ];
    };
    systemd.tmpfiles.rules = [
      "d /home/adjivas 0755 adjivas users -"
      "d /nix/persistent/home/adjivas/.secrets 0700 adjivas users -"
    ];

    boot.swraid = {
      enable = true;

      # TODO: Replace with real RAID failure notifications.
      mdadmConf = ''
        PROGRAM ${pkgs.coreutils}/bin/true
      '';
    };
  };
}
