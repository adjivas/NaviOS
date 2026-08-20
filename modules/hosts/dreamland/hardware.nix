{
  den.aspects.hardware.nixos = {
    pkgs,
    lib,
    ...
  }: {
    boot.initrd.availableKernelModules = [
      "xhci_pci"
      "ehci_pci"
      "ahci"
      "nvme"
      "usb_storage"
      "sd_mod"
      "sr_mod"
      "usbhid"
    ];

    boot.kernelParams = [
      "usbcore.autosuspend=-1"
    ];

    hardware.enableRedistributableFirmware = true;

    hardware.cpu.intel.updateMicrocode = true;

    # Graphic + Sway
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        mesa
        vulkan-loader
        vulkan-tools
        vulkan-validation-layers
      ];
    };

    boot.initrd = {
      systemd.enable = true;
      luks.fido2Support = false;
    };

    fileSystems."/" = {
      device = "tmpfs";
      fsType = "tmpfs";
      options = ["mode=755"];
    };

    fileSystems."/nix/persistent" = {
      neededForBoot = true;
    };

    fileSystems."/home/adjivas/Documents" = {
      device = "/nix/persistent/home/adjivas/Documents";
      fsType = "none";
      options = ["bind"];
    };

    fileSystems."/home/adjivas/Pictures" = {
      device = "/nix/persistent/home/adjivas/Pictures";
      fsType = "none";
      options = ["bind"];
    };

    fileSystems."/home/adjivas/Etudes" = {
      device = "/nix/persistent/home/adjivas/Etudes";
      fsType = "none";
      options = ["bind"];
    };

    fileSystems."/home/adjivas/PoCs" = {
      device = "/nix/persistent/home/adjivas/PoCs";
      fsType = "none";
      options = ["bind"];
    };

    swapDevices = [
      {
        device = "/nix/swap/swapfile";
        size = 32768;
      }
    ];

    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.grub = {
      efiSupport = true;

      device = "nodev";

      extraEntriesBeforeNixOS = false;
      extraFiles = {"ipxe.efi" = "${pkgs.ipxe}/ipxe.efi";};
      extraEntries = ''
        menuentry "Reinstall via iPXE" {
          chainloader /ipxe.efi
        }
      '';
    };

    # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
    # (the default) this is the recommended approach. When using systemd-networkd it's
    # still possible to use this option, but it's recommended to use it in conjunction
    # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
    # networking.useDHCP = lib.mkDefault true;
    # networking.interfaces.ens3.useDHCP = lib.mkDefault true;
    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  };
}
