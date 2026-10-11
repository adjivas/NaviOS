{
  den.aspects.dream33-configuration.nixos = {pkgs, ...}: {
    boot.kernelPackages = pkgs.linuxPackages_latest;

    boot = {
      initrd.kernelModules = ["amdgpu"];
      kernelModules = ["amdgpu"];

      loader.grub = {
        enable = true;
        efiSupport = true;
        efiInstallAsRemovable = true;
        device = "nodev";
      };
    };

    boot.kernelParams = [
      "fbcon=map:1"
    ];

    boot.loader.grub.configurationLimit = 5;

    swapDevices = [
      {
        device = "/var/lib/swapfile";
        size = 12 * 1024;
      }
    ];

    hardware.enableRedistributableFirmware = true;
    hardware.graphics.enable = true;

    networking.hostName = "dream33";
    networking.networkmanager.enable = true;
    networking.hosts."192.168.77.22" = [
      "git.sr.ht.local"
      "meta.sr.ht.local"
    ];

    services.fwupd.enable = true;

    nixpkgs.config.allowUnfree = true;
    nix = {
      settings = {
        builders-use-substitutes = true;
        accept-flake-config = true;
        warn-dirty = false;
        trusted-users = ["@wheel"];
        experimental-features = [
          "flakes"
          "nix-command"
          "pipe-operators"
        ];
      };
    };

    system.stateVersion = "26.05";
  };
}
