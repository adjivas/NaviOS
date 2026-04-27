{ self, hostname, config, lib, pkgs, inputs, ... }: {
  environment.persistence."/nix/persistent" = {
    hideMounts = true;
    directories = [
      "/tmp" # The boot is clean on reboot
      "/etc/navios"
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

  system.activationScripts.persistentHome.text = ''
    install -d -m 0700 -o adjivas -g users /nix/persistent/home/adjivas
    chown -R adjivas:users /nix/persistent/home/adjivas

    install -d -m 0700 -o kad -g users /nix/persistent/home/kad
    chown kad:users /nix/persistent/home/kad
  '';

  # nix.extraOptions = lib.mkAfter ''
  #   !include ${config.age.secrets."github-tokens.txt".path}
  # '';
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
    # Cache
    substituters = [
      "http://192.168.1.2:5000"
      "https://cache.nixos.org"
    ];

    trusted-public-keys = [
      "binarycache.example.com:9TSbWtdq8CqiAC28r3g2OF27vJP2I28edNSyRwMVgts="
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

  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest;

  # boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  # nix.extraOptions = ''extra-platforms = aarch64-linux i686-linux'';

  nixpkgs.config.allowUnfree = true;

  imports = [
    # inputs.nix-luanti.nixosModules.default
    (self + /nixosModules)
    ./homes
    ./vms
    ./luanti # server
    ./modem.nix
    ./gamepad.nix
    ./android.nix
    ./bluetooth.nix
    ./agenix.nix
    ./specializations/vfio-passthrough.nix
    ./specializations/multiseat.nix
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
  plymouth = {
    enable = true;
  };
  gitlab-runner = {
    enable = true;
  };

  # VM
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
  cache = {
    enable = true;
    address = "0.0.0.0";
    port = 5000;
    key = config.age.secrets."cache-priv-key.pem".path;
  };

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



  environment.sessionVariables = {
    GSK_RENDERER = "ngl";
    GTK_USE_PORTAL = "1";
    QT_USE_PORTAL = "1";
  };

  security.polkit.enable = true;
  security.pam.services.swaylock = {};

  networking.useNetworkd = true;
  networking.useDHCP = false;
  networking.hostName = hostname; # Define your hostname.

  networking.hosts."192.168.1.3" = [ "luanti.navi" ];
  networking.hosts."192.168.1.4" = [ "mario.navi" ];
  networking.hosts."192.168.1.5" = [ "zelda.navi" ];
  networking.hosts."192.168.1.6" = [ "xonotic.navi" ];
  networking.hosts."192.168.1.7" = [ "tux.navi" ];

  networking.hosts."192.168.1.8" = [ "blue.seat" ];
  networking.hosts."192.168.1.9" = [ "orange.seat" ];
  networking.hosts."192.168.1.10" = [ "purple.seat" ];

  services.logind.settings = {
    Login = {
      HandlePowerKey = "ignore";
    };
  };

  services.resolved.enable = true;
  systemd.network = {
    enable = true;
    netdevs."br0" = {
      netdevConfig = {
        Name = "br0";
        Kind = "bridge";
      };
    };
    networks = {
      "10-lan" = {
        matchConfig.Name = [ "eno1" "vm-*" "vnet*" "tap-*" ];
        networkConfig = {
          Bridge = "br0";
        };
      };
      "10-lan-bridge" = {
        matchConfig.Name = "br0";
        networkConfig = {
          Address = ["192.168.1.2/24" "2001:db8::a/64"];
          Gateway = "192.168.1.1";
          DNS = ["192.168.1.1"];
          IPv6AcceptRA = true;
        };
        linkConfig.RequiredForOnline = "routable";
      };
    };
  };

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  users.users.root.hashedPasswordFile = config.age.secrets."root-password".path;
  users.users.adjivas = {
    isNormalUser = true;
    hashedPasswordFile = config.age.secrets."adjivas-password".path;
    extraGroups = [ "wheel" "power" "autologin" "seat" "video" "render" "input" "uinput" "docker" ]; # Enable ‘sudo’ for the user.
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
      AllowUsers = [ "adjivas" ];
      PermitRootLogin = "no";
    };
  };

  programs.fuse.userAllowOther = true; # Home-Manager impermanence
  programs.dconf.enable = true; # Home-Manager stylix

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk
    ];

    config = {
      common = {
        default = [ "gtk" "wlr" ];
        "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
        "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
        "org.freedesktop.impl.portal.OpenURI" = [ "gtk" ];
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

  environment.variables.EDITOR = "nvim";

  environment.systemPackages = with pkgs; [
    neovim
  ];

  system.stateVersion = "25.05";

  # Micro VM
  # systemd.services."microvm-tap-interfaces@dreamluanti-microvm.service".restartIfChanged = false;
  # systemd.services."microvm-virtiofsd@dreamluanti-microvm.service".restartIfChanged = false;
  # systemd.services."microvm@dreamluanti-microvm.service".restartIfChanged = false;

  # microvm.autostart = [
  #   "anchor-server"
  #   "luanti-server"
  #   "sm64ex-server"
  #   "xonotic-server"
  #   "supertuxkart-server"
  # ];

  # /run/wrappers/bin/vm-xonotic-client-red
  # security.wrappers = let
  #   prefixes = [ "luanti-client" "sm64ex-client" "soh-anchor-client" "xonotic-client" "supertuxkart-client" ];
  #   colors   = [ "blue" "orange" "purple" ];
  #   colorSet = lib.genAttrs colors (_: {});
  # in lib.mkMerge (map (namePrefix:
  #   lib.mapAttrs' (color: _: {
  #     name = "vm-${namePrefix}-${color}";
  #     value = {
  #       source = "/var/lib/microvms/${namePrefix}-${color}/current/bin/microvm-run";
  #       owner = "root";
  #       group = "kvm";
  #       permissions  = "u+rx,g+rx,o+rx";
  #       capabilities = "cap_net_admin+ep";
  #     };
  #   }) colorSet
  # ) prefixes);
  #
  # home-manager.users.adjivas.xdg.desktopEntries = let
  #   prefixes = [ "luanti-client" "sm64ex-client" "soh-anchor-client" "xonotic-client" "supertuxkart-client" ];
  #   colors   = [ "blue" "orange" "purple" ];
  #   colorSet = lib.genAttrs colors (_: {});
  # in lib.mkMerge (map (namePrefix:
  #   lib.mapAttrs' (color: _: {
  #     name = "${namePrefix}-microvm-${color}";
  #     value = {
  #       name = "${namePrefix} (microvm) ${color}";
  #       genericName = "${namePrefix} client ${color}";
  #       exec = "/run/wrappers/bin/vm-${namePrefix}-${color}";
  #       terminal = false;
  #       type = "Application";
  #       categories = [ "Game" ];
  #       icon = namePrefix;
  #     };
  #   }) colorSet
  # ) prefixes);
}
