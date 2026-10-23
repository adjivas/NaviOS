{inputs, ...}: {
  den.aspects.dream76-configuration.nixos = {
    pkgs,
    lib,
    ...
  }: {
    imports = [
      inputs.impermanence.nixosModules.impermanence
    ];

    nixpkgs.config.allowUnfree = true;

    # flake.modules.nixos.dreamland = { inputs, hostname, pkgs, lib, config, ... }: {
    environment.persistence."/nix/persistent" = {
      hideMounts = true;
      directories = [
        "/tmp" # The boot is clean on reboot
        "/etc/navios"
        "/var/lib/libvirt/secrets"
        # Gitlab
        "/var/lib/gitlab"
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
        "/home/adjivas/.Wolfram/Paclets/Repository"
      ];
      files = [
        "/etc/machine-id"
      ];
    };

    system.activationScripts.persistentHome.text = ''
      install -d -m 0700 -o adjivas -g users /nix/persistent/home/adjivas
      chown -R adjivas:users /nix/persistent/home/adjivas
      chown adjivas:users /nix/persistent/snapshots/adjivas/{Documents,Pictures,Etudes,PoCs}
    '';

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
      # PATCH detnix : https://github.com/nix-community/home-manager/issues/7935#issuecomment-4331142453
      package = lib.mkForce (
        (inputs.determinate.inputs.nix.packages.${pkgs.stdenv.hostPlatform.system}.default.appendPatches [
          inputs.detnix-patch
        ]).overrideAttrs (_old: {
          doCheck = false;
          doInstallCheck = false;
        })
      );
      distributedBuilds = true;
    };

    documentation = {
      enable = false;
      man.enable = false;
      info.enable = false;
      doc.enable = false;
      nixos.enable = false;
    };

    nixpkgs.overlays = [
      inputs.timewall.overlays.default
      inputs.microvm.overlay
      # inputs.nix-cachyos-kernel.overlays.pinned
      (_: prev: {
        gtksourceview5 = prev.gtksourceview5.overrideAttrs (_old: {
          doCheck = false;
        });
      })
    ];
    boot.kernelModules = [
      "kvm-intel"
    ];
    # boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-lts;

    boot.tmp.cleanOnBoot = true;

    # login
    security.polkit.enable = true;
    security.pam.services.login.enableGnomeKeyring = true;
    security.pam.services.swaylock = {
      enableGnomeKeyring = true;
    };

    services.gnome.at-spi2-core.enable = true;
    services.gnome.gnome-keyring.enable = true;

    programs.seahorse.enable = true;

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

    pipewire = {
      sink = "alsa_output.pci-0000_00_1b.0.analog-stereo";
    };

    services.logind.settings = {
      Login = {
        HandlePowerKey = "ignore";
      };
    };

    programs.fuse.userAllowOther = true; # Home-Manager impermanence
    programs.dconf.enable = true; # Home-Manager stylix

    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gtk
        xdg-desktop-portal-gnome
      ];

      config = {
        common = {
          default = ["gtk" "wlr"];
          "org.freedesktop.impl.portal.Secret" = ["gnome-keyring"];
          "org.freedesktop.impl.portal.FileChooser" = ["gtk"];
          "org.freedesktop.impl.portal.OpenURI" = ["gtk"];
        };

        sway = {
          "org.freedesktop.ScreenSaver" = ["none"];
          "org.freedesktop.impl.portal.Screenshot" = ["wlr"];
          "org.freedesktop.impl.portal.ScreenCast" = ["wlr"];
          "org.freedesktop.impl.portal.RemoteDesktop" = ["wlr"];
          "org.freedesktop.impl.portal.Secret" = ["gnome-keyring"];
          "org.freedesktop.impl.portal.FileChooser" = ["gtk"];
          "org.freedesktop.impl.portal.OpenURI" = ["gtk"];
        };
        niri = {
          "org.freedesktop.impl.portal.ScreenCast" = ["gnome"];
          "org.freedesktop.impl.portal.Screenshot" = ["gnome"];
          "org.freedesktop.impl.portal.RemoteDesktop" = ["gnome"];
        };
      };
    };

    services.xserver = {
      enable = true;
      displayManager.lightdm = {
        enable = true;
        greeters.gtk.enable = true;
      };
    };
  };
}
