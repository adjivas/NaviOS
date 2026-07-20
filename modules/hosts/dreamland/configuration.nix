{inputs, ...}: {
  den.aspects.dreamland.nixos = {
    pkgs,
    lib,
    config,
    ...
  }: {
    nixpkgs.config.allowUnfree = true;

    # flake.modules.nixos.dreamland = { inputs, hostname, pkgs, lib, config, ... }: {
    environment.persistence."/nix/persistent" = {
      hideMounts = true;
      directories = [
        "/tmp" # The boot is clean on reboot
        "/etc/navios"
        "/var/lib/libvirt/secrets"
        # Firefox Syncserver
        "/var/lib/mysql"
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
      chown adjivas:users /nix/persistent/snapshots/adjivas/{Documents,Pictures,Etudes,PoCs}

      install -d -m 0700 -o kad -g users /nix/persistent/home/kad
      chown -R kad:users /nix/persistent/home/kad
    '';

    nix = {
      settings = {
        accept-flake-config = true;
        warn-dirty = false;
        trusted-users = ["@wheel"];
        experimental-features = [
          "flakes"
          "nix-command"
          "pipe-operators"
        ];
      };
      # PATCH detnix : https://github.com/nix-community/home-manager/issues/7935#issuecomment-4331142453
      package = lib.mkForce (
        (inputs.determinate.inputs.nix.packages.${pkgs.stdenv.hostPlatform.system}.default.appendPatches [
          inputs.detnix-patch
        ]).overrideAttrs (_old: {
          doCheck = false;
          doInstallCheck = false;
        })
      );
    };

    documentation = {
      enable = false;
      man.enable = false;
      info.enable = false;
      doc.enable = false;
      nixos.enable = false;
    };

    nixpkgs.overlays = [
      inputs.microvm.overlay
      inputs.nix-cachyos-kernel.overlays.pinned
      (_: prev: {
        gtksourceview5 = prev.gtksourceview5.overrideAttrs (_old: {
          doCheck = false;
        });
      })
    ];
    boot.kernelModules = [
      "kvm-intel"
    ];
    boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-lts;

    boot.tmp.cleanOnBoot = true;

    # sudo udevadm control --reload-rules
    # sudo udevadm trigger
    services.udev.extraRules = ''
      # Player 1
      ACTION=="add|change", SUBSYSTEM=="input", KERNEL=="event*", ATTRS{uniq}=="10:18:49:a1:9b:26", ENV{ID_INPUT_JOYSTICK}=="1", SYMLINK+="input/player1-gamepad"
      ACTION=="add|change", SUBSYSTEM=="input", KERNEL=="event*", ATTRS{uniq}=="10:18:49:a1:9b:26", ENV{ID_INPUT_TOUCHPAD}=="1", SYMLINK+="input/player1-touchpad"

      # Player 2
      ACTION=="add|change", SUBSYSTEM=="input", KERNEL=="event*", ATTRS{uniq}=="a4:53:85:94:03:f3", ENV{ID_INPUT_JOYSTICK}=="1", SYMLINK+="input/player2-gamepad"
      ACTION=="add|change", SUBSYSTEM=="input", KERNEL=="event*", ATTRS{uniq}=="a4:53:85:94:03:f3", ENV{ID_INPUT_TOUCHPAD}=="1", SYMLINK+="input/player2-touchpad"

      # Player 3
      ACTION=="add|change", SUBSYSTEM=="input", KERNEL=="event*", ATTRS{uniq}=="d0:bc:c1:a4:5f:98", ENV{ID_INPUT_JOYSTICK}=="1", SYMLINK+="input/player3-gamepad"
      ACTION=="add|change", SUBSYSTEM=="input", KERNEL=="event*", ATTRS{uniq}=="d0:bc:c1:a4:5f:98", ENV{ID_INPUT_TOUCHPAD}=="1", SYMLINK+="input/player3-touchpad"
    '';

    systemd.services.NetworkManager-wait-online.enable = false;

    # boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
    # nix.extraOptions = ''extra-platforms = aarch64-linux i686-linux'';

    # imports = [
    #   self.nixosModules.vm-dreaminstall
    # ];

    networking.hosts = {
      "192.168.1.10" = ["dream00"];
      "2a04:cec0:1902:2824::10" = ["dream00"];
      "192.168.1.11" = ["dream00"];
      "2a04:cec0:1902:2824::11" = ["dream00"];
      "192.168.1.76" = ["dream76"];
      "2a04:cec0:1902:2824::76" = ["dream76"];
      "192.168.1.77" = ["dream76"];
      "2a04:cec0:1902:2824::77" = ["dream76"];
    };

    btrbk = {
      sshPrivateKey = config.age.secrets."btrbk_dreamland_ed25519_key".path;
      sshPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM9BGZsby0ScvKVz6AvzUVBaGgFgYGfBOMBIAGl//jcy";
      subvolume = {
        "home/adjivas/Documents" = {};
        "home/adjivas/Pictures" = {};
        "home/adjivas/Etudes" = {};
        "home/adjivas/PoCs" = {};
      };
    };
    pipewire = {
      sink = "alsa_output.pci-0000_00_1b.0.analog-stereo";
    };
    steam = {
      extraCompatPackages = [pkgs.proton-ge-bin];
    };
    lafayette = {
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
    gitlab-runner = {
      authenticationTokenConfigFile = config.age.secrets."gitlab-runner.env".path;
    };

    # VM
    virtualisation = {
      user = "adjivas";
    };

    # users.users.appvm = {
    #   isNormalUser = true;
    #   uid = 1337;
    #   group = "appvm";
    # };
    #
    # users.groups.appvm.gid = 1337;
    systemd.targets.microvms.wants = lib.mkForce [];
    users.groups.microvm = {};

    # vm-dreamkad.enable = false;
    # vm-nightmare.iso = pkgs.fetchurl {
    #  url = "https://archive.org/download/windows11_20220930/Win11_22H2_English_x64v1.iso";
    #  sha256 = "sha256-DfLxc9hNAHQ9wI7YJPvRdNlykpvYS4f+OE7ZUPW9qyI=";
    #  name = "Win11_22H2_English_x64v1.iso";
    #};
    nix.cache.server = {
      address = "0.0.0.0";
      port = 5000;
      key = config.age.secrets."cache-priv-key.pem".path;
    };

    environment.sessionVariables = {
      GSK_RENDERER = "gl";
      GTK_USE_PORTAL = "1";
      QT_USE_PORTAL = "1";
    };

    security.polkit.enable = true;
    security.pam.services.swaylock = {};

    services.logind.settings = {
      Login = {
        HandlePowerKey = "ignore";
      };
    };

    # Set your time zone.
    time.timeZone = "Europe/Paris";

    users.users.root.hashedPasswordFile = config.age.secrets."root-password".path;

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
          default = ["gtk" "wlr"];
          "org.freedesktop.impl.portal.Secret" = ["gnome-keyring"];
          "org.freedesktop.impl.portal.FileChooser" = ["gtk"];
          "org.freedesktop.impl.portal.OpenURI" = ["gtk"];
        };

        sway = {
          default = ["wlr" "gtk"];
          "org.freedesktop.ScreenSaver" = ["none"];
          "org.freedesktop.impl.portal.Screenshot" = ["wlr"];
          "org.freedesktop.impl.portal.ScreenCast" = ["wlr"];
          "org.freedesktop.impl.portal.RemoteDesktop" = ["wlr"];
          "org.freedesktop.impl.portal.Secret" = ["gnome-keyring"];
          "org.freedesktop.impl.portal.FileChooser" = ["gtk"];
          "org.freedesktop.impl.portal.OpenURI" = ["gtk"];
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
      sessionPackages = [pkgs.sway];
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
  };
}
