{ self, config, pkgs, lib, inputs, ... }: {
  nix.settings = {
    # trusted-users = [ "root" "kad" ];
    accept-flake-config = true;
    experimental-features = [ "nix-command" "flakes" ];
  };

  nixpkgs.config.allowUnfree = true;

  imports = [
    ./vms
    ./home
    (self + /nixosModules)
  ];
  pipewire.enable = true;
  lact.enable = true;
  i18n.enable = true;
  steam.enable = true;
  greetd = {
    enable = true;
    user = "kad";
    command = "${pkgs.sway}/bin/sway";
  };

  # VM
  arkad = {
    enable = true;
    cdrom = pkgs.fetchurl {
      url = "https://github.com/nix-community/nixos-images/releases/download/nixos-unstable/nixos-installer-x86_64-linux.iso";
      sha256 = "sha256-2k9uRjw+xMN8dVGessDd4u8eosPmV8bOyNE4yUNRFBY=";
      name = "nixos-installer-x86_64-linux.iso";
    };
  };

  virtualisation = {
    enable = true;
    user = "kad";
    machines = lib.filter (vm: vm.enable or false) (with config; [ arkad ]);
    networks = [
      {
        definition = inputs.nixvirt.lib.network.writeXML (inputs.nixvirt.lib.network.templates.bridge {
          uuid = "70b42691-28dc-4b47-90a1-45bbeac9ab5a";
          subnet_byte = 71;
        });
        active = true;
      }
    ];
  };

  boot.tmp.useTmpfs = false;

  time.timeZone = "Europe/Paris";

  users.motd = "hey listen!";
  users.users.nixos.isNormalUser = true;
  users.groups.nixos = {};
  users.users.nixos.group = "nixos";
  users.users.nixos.extraGroups = [ "wheel" ];

  networking.hostName = "dreamkad";

  networking.hosts."192.168.1.3" = [ "luanti.navi" ];

  # hardware.enableAllFirmware = true;
  hardware.enableRedistributableFirmware = true;
  # # hardware.firmware = [ pkgs.linux-firmware ];
  #
  # boot.kernelPackages = pkgs.linuxPackages_latest;
  # boot.initrd.kernelModules = [ "amdgpu" ];
  #
  # # Forward kernel and grub messages to the serial port
  boot.kernelParams = [
    "amdgpu.modeset=1"
    "amdgpu.seamless=1"
    "amdgpu.dc=1"
    "video=efifb:off"
    "console=hvc0"
    "console=tty1"
  ];

  # # boot.loader.grub.enable = true;
  # # boot.loader.grub.efiSupport = true;
  # # boot.loader.grub.device = lib.mkForce "nodev";
  # # boot.loader.efi.canTouchEfiVariables = false;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  #  extraPackages = with pkgs; [
  #    amdvlk
  #  ];
  };

  environment.sessionVariables = {
    # WLR_DRM_DEVICES = "/dev/dri/by-path/pci-0000:04:00.0-card";
    WLR_DRM_DEVICES = "/dev/dri/card0";
  };

  hardware.amdgpu = {
    initrd.enable = true;
    opencl.enable = true; # Blender
  };

  users.users.kad = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    # extraGroups = [ "wheel" "video" "seat" ];
    password = "12345";
  };

  systemd.services."serial-getty@hvc0".wantedBy = [ "multi-user.target" ];
  systemd.services."serial-getty@ttyS0".enable = false;

  services.openssh.enable = true;

  programs.dconf.enable = true; # Home-Manager stylix

  environment.systemPackages = with pkgs; [
    # Audio
    pwvucontrol
  ];

  system.stateVersion = "25.05";
}
