{ self, config, lib, pkgs, inputs, ... }: {
  environment.persistence."/nix/persistent" = {
    hideMounts = true;
    directories = [
      "/tmp" # The boot is clean on reboot
      # "/var/log"
      "/var/lib/bluetooth"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/secrets"
      # Virt
      "/var/lib/libvirt/images"
      "/var/lib/libvirt/qemu/nvram"
      # MicroVM
      "/var/lib/microvms"
      # Luanti
      "/var/lib/luanti"
      # Steam
      "/home/adjivas/.local/share/Steam"
      "/home/adjivas/Steam"
      # Kad
      "/home/kad"
    ];
    files = [
      "/etc/machine-id"
    ];
  };

  # Home Manager right permissions
  system.activationScripts.persistentHome.text = ''
    install -d -m 0700 -o adjivas -g users /nix/persistent/home/adjivas
    chown adjivas:users /nix/persistent/home/adjivas/.secrets/age/*.age
    chown adjivas:users /nix/persistent/home/adjivas/.secrets/ident.txt
    chown adjivas:users /nix/persistent/home/adjivas/.config/passage/identities
    chown adjivas:users /nix/persistent/home/adjivas/.local/share/Steam
    chown adjivas:users /nix/persistent/home/adjivas/Steam
    install -d -m 0700 -o kad -g users /nix/persistent/home/kad
    chown kad:users /nix/persistent/home/kad
  '';

  # nix.package = pkgs.nixVersions.nix_2_30;
  nix.settings = {
    eval-cores = 0;

    accept-flake-config = true;
    warn-dirty = false;
    trusted-users = [ "@wheel" ];
    experimental-features = [
      "nix-command"
      "flakes"
      "parallel-eval"
    ];
  };

  nixpkgs.overlays = [
    inputs.microvm.overlay
    inputs.nix-cachyos-kernel.overlays.pinned
  ];
  boot.kernelModules = [
    "kvm-intel"
  ];

  boot.tmp.cleanOnBoot = true;

  hardware.enableRedistributableFirmware = true;

  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest;

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  nix.extraOptions = ''extra-platforms = aarch64-linux i686-linux'';

  age = {
    identityPaths = [ "/nix/persistent/secrets/ident.txt" ];
    secretsMountPoint = "/run/agenix.d";
  };

  age.secrets = let
    secretsDirStore = inputs.secrets;
    allEntries = builtins.attrNames (builtins.readDir secretsDirStore);
    ageFiles = builtins.filter (f: lib.hasSuffix ".age" f) allEntries;
  in builtins.listToAttrs (map (file:
    let
      key = lib.toLower (lib.removeSuffix ".age" file);
    in lib.nameValuePair key {
      file = "${secretsDirStore}/${file}";
    }
  ) ageFiles);

  environment.etc = let nms = (builtins.attrNames (lib.filterAttrs
    (name: _: lib.hasSuffix ".nmconnection" name)
    config.age.secrets
  )); in builtins.listToAttrs (map (name: {
    name = "NetworkManager/system-connections/${name}.age";
    value = {
      source = config.age.secrets."${name}".path;
    };
  }) nms);

  nixpkgs.config.allowUnfree = true;

  imports = [
    # inputs.nix-luanti.nixosModules.default
    (self + /nixosModules)
    ./home
    ./vms
    ./luanti # server
    ./modem.nix
    ./gamepad.nix
    ./android.nix
    ./bluetooth.nix
  ];
  yubico.enable = true;
  pipewire = {
    enable = true;
    sink = "alsa_output.pci-0000_00_1b.0.analog-stereo";
  };
  gc.enable = true;
  i18n.enable = true;
  steam = {
    enable = true;
    extraCompatPackages = [ pkgs.proton-ge-bin ];
  };
  lafayette = {
    enable = true;
    path = pkgs.writeText "lafayette-navi.toml" ''
      name = "Qwerty-Lafayette"
      name8 = "Qwerty-L"
      locale = "fr"
      variant = "lafayette"
      author = "Fabien Cazenave (:kazé), navi"
      description = "French (Qwerty-Lafayette Mousy-Industry)"
      url = "https://github.com/fabi1cazenave/qwerty-lafayette"
      geometry = "ERGO"
      version = "0.9.2"

      base = ''''
      ╭╌╌╌╌╌┰─────┬─────┬─────┬─────┬─────┰─────┬─────┬─────┬─────┬─────┰╌╌╌╌╌┬╌╌╌╌╌╮
      ┆ ~   ┃ !   │ @   │ #   │ $   │ %   ┃ ^   │ &   │ *   │ (   │ )   ┃ _   ┆ + ± ┆
      ┆ `   ┃ 1   │ 2   │ 3   │ 4   │ 5 ‰ ┃ 6   │ 7   │ 8   │ 9   │ 0 ° ┃ - — ┆ = ≠ ┆
      ╰╌╌╌╌╌╂─────┼─────┼─────┼─────┼─────╂─────┼─────┼─────┼─────┼─────╂╌╌╌╌╌┼╌╌╌╌╌┤
      ·     ┃ Q   │ W   │ E   │ R   │ T   ┃ Y   │ U   │ I   │ O   │ P   ┃ {   ┆ }   ┆
      ·     ┃   æ │   é │   è │     │     ┃     │   ù │   ï │   œ │     ┃ [   ┆ ]   ┆
      ·     ┠─────┼─────┼─────┼─────┼─────╂─────┼─────┼─────┼─────┼─────╂╌╌╌╌╌┼╌╌╌╌╌┤
      ·     ┃ A   │ S   │ D   │ F   │ G   ┃ H   │ J   │ K   │ L   │**   ┃ "   ┆ |   ┆
      ·     ┃   à │     │   ê │     │     ┃   ŷ │   û │   î │   ô │  *¨ ┃ '   ┆ \   ┆
      ╭╌╌╌╌╌╂─────┼─────┼─────┼─────┼─────╂─────┼─────┼─────┼─────┼─────╂╌╌╌╌╌┴╌╌╌╌╌╯
      ┆ >   ┃ Z ≤ │ X ≥ │ C   │ V   │ B   ┃ N   │ M   │ ;   │ :   │ ?   ┃           ·
      ┆ <   ┃   < │   > │   ç │     │     ┃     │     │ ,   │ .   │ /   ┃           ·
      ╰╌╌╌╌╌┸─────┴─────┴─────┴─────┴─────┸─────┴─────┴─────┴─────┴─────┚ · · · · · ·
      ''''

      [spacebar]
      shift       = "\u2019"  # RIGHT SINGLE QUOTATION MARK
      1dk         = "\u2019"  # RIGHT SINGLE QUOTATION MARK
      1dk_shift   = "\u2019"  # RIGHT SINGLE QUOTATION MARK

      [layer.nav]
      h = "Left"
      j = "Down"
      k = "Up"
      l = "Right"
    '';
  };
  pixie = {
    enable = true;
    ident = config.age.secrets."secret.ident".path;
  };
  plymouth = {
    enable = true;
  };

  # Micro VM
  # systemd.services."microvm-tap-interfaces@dreamluanti-microvm.service".restartIfChanged = false;
  # systemd.services."microvm-virtiofsd@dreamluanti-microvm.service".restartIfChanged = false;
  # systemd.services."microvm@dreamluanti-microvm.service".restartIfChanged = false;

  microvm.autostart = [
    "anchor-server"
    "luanti-server"
    "sm64ex-server"
    "xonotic-server"
    "supertuxkart-server"
  ];

  # /run/wrappers/bin/vm-xonotic-client-red
  security.wrappers = let
    prefixes = [ "luanti-client" "sm64ex-client" "soh-anchor-client" "xonotic-client" "supertuxkart-client" ];
    colors   = [ "blue" "orange" "purple" ];
    colorSet = lib.genAttrs colors (_: {});
  in lib.mkMerge (map (namePrefix:
    lib.mapAttrs' (color: _: {
      name = "vm-${namePrefix}-${color}";
      value = {
        source = "/var/lib/microvms/${namePrefix}-${color}/current/bin/microvm-run";
        owner = "root";
        group = "kvm";
        permissions  = "u+rx,g+rx,o+rx";
        capabilities = "cap_net_admin+ep";
      };
    }) colorSet
  ) prefixes);

  home-manager.users.adjivas.xdg.desktopEntries = let
    prefixes = [ "luanti-client" "sm64ex-client" "soh-anchor-client" "xonotic-client" "supertuxkart-client" ];
    colors   = [ "blue" "orange" "purple" ];
    colorSet = lib.genAttrs colors (_: {});
  in lib.mkMerge (map (namePrefix:
    lib.mapAttrs' (color: _: {
      name = "${namePrefix}-microvm-${color}";
      value = {
        name = "${namePrefix} (microvm) ${color}";
        genericName = "${namePrefix} client ${color}";
        exec = "/run/wrappers/bin/vm-${namePrefix}-${color}";
        terminal = false;
        type = "Application";
        categories = [ "Game" ];
        icon = namePrefix;
      };
    }) colorSet
  ) prefixes);

  # VM
  # systemd.services."libvirt-guests".restartIfChanged = false;
  # systemd.services."nixvirt.service".restartIfChanged = false; # VMs list
  systemd.services."libvirtd.service".restartIfChanged = false; # QEMU/KVM connection?

  virtualisation = {
    enable = true;
    user = "adjivas";
  };

  dreamkad.enable = false;
  dreaminstall.enable = true;
  windows.enable = true;
  #windows.windows.iso = pkgs.fetchurl {
  #  url = "https://archive.org/download/windows11_20220930/Win11_22H2_English_x64v1.iso";
  #  sha256 = "sha256-DfLxc9hNAHQ9wI7YJPvRdNlykpvYS4f+OE7ZUPW9qyI=";
  #  name = "Win11_22H2_English_x64v1.iso";
  #};

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub = {
    efiSupport = true;

    device = "nodev";

    extraEntriesBeforeNixOS = false;
    extraFiles = { "ipxe.efi" = "${pkgs.ipxe}/ipxe.efi"; };
    extraEntries = ''
      menuentry "Reinstall via iPXE" {
        chainloader /ipxe.efi
      }
    '';
  };

  # Increase buffer size
  nix.settings.download-buffer-size = "5096M";

  # Graphic + Sway
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    # extraPackages = with pkgs; [
    #   vpl-gpu-rt
    # ];
  };

  environment.sessionVariables.GSK_RENDERER = "ngl";

  security.polkit.enable = true;
  security.pam.services.swaylock = {};

  networking.useNetworkd = true;
  networking.useDHCP = false;
  networking.hostName = "dreamland"; # Define your hostname.

  networking.hosts."192.168.1.3" = [ "luanti.navi" ];
  networking.hosts."192.168.1.4" = [ "mario.navi" ];
  networking.hosts."192.168.1.5" = [ "zelda.navi" ];
  networking.hosts."192.168.1.6" = [ "xonotic.navi" ];
  networking.hosts."192.168.1.7" = [ "tux.navi" ];

  networking.hosts."192.168.1.8" = [ "blue.seat" ];
  networking.hosts."192.168.1.9" = [ "orange.seat" ];
  networking.hosts."192.168.1.10" = [ "purple.seat" ];

  services.resolved.enable = true;

  services.logind.settings = {
    Login = {
      HandlePowerKey = "ignore";
    };
  };

  systemd.network.enable = true;
  systemd.network.networks."10-lan" = {
    matchConfig.Name = [ "eno1" "vm-*" "vnet*" "tap-*" ];
    networkConfig = {
      Bridge = "br0";
    };
  };
  systemd.network.netdevs."br0" = {
    netdevConfig = {
      Name = "br0";
      Kind = "bridge";
    };
  };
  systemd.network.networks."10-lan-bridge" = {
    matchConfig.Name = "br0";
    networkConfig = {
      Address = ["192.168.1.2/24" "2001:db8::a/64"];
      Gateway = "192.168.1.1";
      DNS = ["192.168.1.1"];
      IPv6AcceptRA = true;
    };
    linkConfig.RequiredForOnline = "routable";
  };

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  users.users.root.hashedPasswordFile = config.age.secrets."root-password".path;
  users.users.adjivas = {
    isNormalUser = true;
    hashedPasswordFile = config.age.secrets."adjivas-password".path;
    extraGroups = [ "wheel" "power" "autologin" "seat" "video" "render" "input" "uinput" ]; # Enable ‘sudo’ for the user.
    #openssh.authorizedKeys.keys = lib.lists.forEach (lib.filesystem.listFilesRecursive "./keys") (key: builtins.readFile key);
    # openssh.authorizedKeys.keyFiles = [ /nix/persistent/secrets/yubikey_5a_adjivas.pub ];
  };

  users.users.kad = {
    isNormalUser = true;
    hashedPasswordFile = config.age.secrets."adjivas-password".path;
    extraGroups = [ "wheel" "power" "autologin" "seat" "video" "render" "kvm" "libvirtd" "input" "uinput" ]; # Enable ‘sudo’ for the user.
  };

  services.openssh = {
    enable = true;
    ports = [ 60022 ];
    settings = {
      # PasswordAuthentication = false;
      AllowUsers = [ "adjivas" ];
      PermitRootLogin = "no";
    };
  };

  programs.fuse.userAllowOther = true; # Home-Manager impermanence
  programs.dconf.enable = true; # Home-Manager stylix

  xdg.portal = {
    enable = true;
    config = {
      common = {
        default = [ "wlr" "gtk" ];
        "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
      };
      sway = {
        default = [ "wlr" "gtk" ];
        "org.freedesktop.ScreenSaver" = [ "none" ];
        "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
        "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
        "org.freedesktop.impl.portal.RemoteDesktop" = [ "wlr" ];
        "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
        "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
        "org.freedesktop.impl.portal.OpenURI" = [ "gtk" ];
      };
    };
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk
    ];
  };

  programs.seahorse.enable = true;

  services.gnome.at-spi2-core.enable = true;
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;
  security.pam.services.swaylock.enableGnomeKeyring = true;

  services.displayManager = {
    enable = true;
    sessionPackages = [ pkgs.sway ];
    defaultSession = "sway"; # /share/wayland-sessions/sway.desktop
    autoLogin = {
      enable = true;
      user = "adjivas";
    };
  };
  services.xserver = {
    enable = true;
    displayManager.lightdm = {
      enable = true;
      greeters.gtk.enable = true;
    };
  };

  specialisation.vfio-passthrough.configuration = {
    # boot.kernelModules = [
    #   "kvm-intel"
    # ];
    # boot.kernelParams = [
    #   "i915.enable_psr=0"
    #   # "nosplash"
    # ];
    virtualisation = {
      vfio = {
        # "vfio_pci" "vfio_iommu_type1" "vfio" 
        # "vfio_virqfd" if < 6.2
        enable = true;
        IOMMUType = "intel"; # intel_iommu=on iommu=pt
        ignoreMSRs = true; # kvm ignore_msrs=1 report_ignored_msrs=0
        devices = [ # vfio-pci ids=1002:744c,1002:ab30
          # GPU RX 7900 GRE
          "1002:744c"
          # Audio HDMI Navi 31
          "1002:ab30"
        ];
      };
      # kvmfr
      # static_size_mb=64
      kvmfr = {
        enable = true;
        devices = [{
          # size = 67108864;
          size = 64;

          permissions = {
            user = config.virtualisation.user;
            group = "qemu-libvirtd";
            mode = "0660";
          };
        }];
      };
      libvirtd = {
        enable = true;
        onBoot = "ignore";
        onShutdown = "shutdown";

        qemu = {
          package = pkgs.qemu_full;
          runAsRoot = true;
          swtpm.enable = true;
        };

        deviceACL = [
          "/dev/vfio/vfio"
          "/dev/kvm"
          "/dev/kvmfr0"
          "/dev/null"
          "/dev/full"
          "/dev/zero"
          "/dev/random"
          "/dev/urandom"
          "/dev/pts"
          "/dev/ptmx"
          "/dev/input/by-id/usb-30fa_USB_Optical_Mouse-event-mouse"
          "/dev/input/by-id/usb-Apple_Inc._Magic_Trackpad_2_CC2929200Z7J5R9AM-if01-event-mouse"
          "/dev/input/by-id/usb-System76_Launch_Configurable_Keyboard__launch_1_-if02-event-kbd"
          "/dev/input/by-id/usb-Bregoli_Swiss-event-kbd"
          "/dev/shm/looking-glass"
        ];
      };
    };
  };

  specialisation.multiseat.configuration = {
    # environment.sessionVariables.LIBSEAT_BACKEND = "logind";

    services.xserver.displayManager.lightdm = {
      extraConfig = lib.mkForce ''
        [Seat:*]
        greeter-session=lightdm-gtk-greeter
        user-session=sway

        [Seat:seat0]
        autologin-user=adjivas
        autologin-session=sway

        [Seat:seat1]
        autologin-user=kad
        autologin-session=sway
      '';
    };

    # services.udev.extraRules = ''
    # environment.etc.seat = {
    #   target = "udev/rules.d/72-seat-map-seat1.rules";
    #   text = ''
    services.udev.extraRules = ''
      SUBSYSTEM=="drm", ENV{ID_AUTOSEAT}="0", ENV{ID_SEAT}=""

      # seat0: Intel Corporation Xeon E3-1200 v3/4th Gen Core Processor Integrated Graphics Controller
      SUBSYSTEM=="drm", KERNEL=="card*", KERNELS=="0000:00:02.0", ENV{ID_SEAT}="seat0"
      SUBSYSTEM=="drm", KERNEL=="card*-*", KERNELS=="0000:00:02.0", ENV{ID_SEAT}="seat0"
      SUBSYSTEM=="drm", KERNEL=="renderD*", KERNELS=="0000:00:02.0", ENV{ID_SEAT}="seat0"

      SUBSYSTEM=="tty", KERNEL=="tty1", ENV{ID_SEAT}="seat0"
      # seat0: Bus 001 Device 018: ID feed:1307 ErgoDox EZ ErgoDox EZ
      SUBSYSTEM=="input", ENV{ID_BUS}=="usb", ENV{ID_VENDOR_ID}=="feed", ENV{ID_MODEL_ID}=="1307", ENV{ID_SEAT}="seat0"
      # seat0: Apple, Inc. Magic Trackpad 2
      SUBSYSTEM=="input", ENV{ID_BUS}=="usb", ENV{ID_VENDOR_ID}=="05ac", ENV{ID_MODEL_ID}=="0265", ENV{ID_SEAT}="seat0"

      # seat1: USB Optical Mouse
      SUBSYSTEM=="input", ENV{ID_BUS}=="usb", ENV{ID_VENDOR_ID}=="30fa", ENV{ID_MODEL_ID}=="0400", ENV{ID_SEAT}="seat1"
      # seat1: Wacom Co., Ltd CTL-480 [Intuos Pen (S)]
      SUBSYSTEM=="input", ENV{ID_BUS}=="usb", ENV{ID_VENDOR_ID}=="056a", ENV{ID_MODEL_ID}=="030e", ENV{ID_SEAT}="seat1"
      # seat1: RDMCTMZT Panda 20
      SUBSYSTEM=="input", ENV{ID_BUS}=="usb", ENV{ID_VENDOR_ID}=="36b0", ENV{ID_MODEL_ID}=="3006", ENV{ID_SEAT}="seat1"
      # seat1: Swiss (Cheeseboard)
      SUBSYSTEM=="input", ENV{ID_BUS}=="usb", ENV{ID_VENDOR_ID}=="4c43", ENV{ID_MODEL_ID}=="0420", ENV{ID_SEAT}="seat1"
      # ACTION=="add", SUBSYSTEM=="input", ENV{ID_BUS}=="usb", ENV{ID_VENDOR_ID}=="4c43", ENV{ID_MODEL_ID}=="0420", ENV{ID_SEAT}="seat1"
      # ACTION=="change", SUBSYSTEM=="input", ENV{ID_BUS}=="usb", ENV{ID_VENDOR_ID}=="4c43", ENV{ID_MODEL_ID}=="0420", ENV{ID_SEAT}="seat1"

      # seat1: [AMD/ATI] Navi 31 [Radeon RX 7900 XT/7900 XTX/7900 GRE/7900M]
      SUBSYSTEM=="drm", KERNEL=="card*", KERNELS=="0000:03:00.0", ENV{ID_SEAT}="seat1"
      SUBSYSTEM=="drm", KERNEL=="card*-*", KERNELS=="0000:03:00.0", ENV{ID_SEAT}="seat1"
      SUBSYSTEM=="drm", KERNEL=="renderD*", KERNELS=="0000:03:00.0", ENV{ID_SEAT}="seat1"
      SUBSYSTEM=="sound", KERNEL=="card*", KERNELS=="0000:03:00.1", ENV{ID_SEAT}="seat1"

      # seat1: HDA/Intel
      SUBSYSTEM=="sound", KERNEL=="card0", ENV{ID_SEAT}="seat1"

      SUBSYSTEM=="tty", KERNEL=="tty2", ENV{ID_SEAT}="seat1"

      SUBSYSTEM=="drm", KERNEL=="card*", KERNELS=="0000:03:00.0", SYMLINK+="dri/amd"
      SUBSYSTEM=="drm", KERNEL=="card*", KERNELS=="0000:00:02.0", SYMLINK+="dri/intel"
    '';
  };

  # OOM
  systemd.services.systemd-oomd = {
    after = [ "swap.target" ];
    requires = [ "swap.target" ];
  };
  systemd.slices."system.slice".sliceConfig.ManagedOOMSwap = "kill";
  systemd.slices."user.slice".sliceConfig.ManagedOOMSwap = "kill";

  environment.variables.EDITOR = "nvim";

  environment.systemPackages = with pkgs; [
    neovim
  ];

  system.stateVersion = "25.05";
}
