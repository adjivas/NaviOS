{
  config,
  secrets,
  pkgs,
  ...
}: {
  networking.hostName = "fairphone";

  networking.firewall.interfaces.wlan0.allowedUDPPorts = [
    53 # DNS provided by NetworkManager's shared connection
    67 # DHCP server
  ];

  nix = {
    distributedBuilds = true;
    buildMachines = [
      {
        hostName = "192.168.1.238";
        system = "aarch64-linux";
        protocol = "ssh";
        sshUser = "alice";
        sshKey = "/root/.ssh/dream33-builder";
        supportedFeatures = ["big-parallel"];
      }
    ];
    settings = {
      max-jobs = 0; # No local build
      builders-use-substitutes = true;
    };
  };

  # Enable Qualcomm modem support.
  nixos-fairphone-fp5.modem.enable = true;

  # Enable experimental Nix features (flakes).
  nix.settings.experimental-features = ["nix-command" "flakes"];

  age = {
    identityPaths = [
      "/nix/secrets/ident.txt"
    ];

    secrets = {
      mms = {
        file = "${secrets}/mms.age";
        path = "/home/admin/.mms/modemmanager/mms";
        owner = "admin";
        group = "users";
        mode = "0400";
      };
      wallpaper = {
        file = "${secrets}/wallpaper.age";
        owner = "admin";
        group = "users";
        mode = "0400";
      };
    };
  };

  # Disable documentation (hides desktop icon).
  documentation.nixos.enable = false;

  time.timeZone = "Europe/Paris";

  # Core GNOME apps are set by the `gnome-mobile` module. The additional packages
  # listed here can be seen as an example of other useful apps for mobile use.
  environment.systemPackages = with pkgs; [
    # Miscellaneous packages.
    wl-clipboard # Wayland clipboard util, also used for Waydroid clipboard sharing.

    # Apps.
    dialect # Translation app.
    firefox-mobile
    gnome-decoder # QR code scanner & generator.
    gnome-software
    gnome-clocks
    resources # System resource monitor.
    warp # Magic wormhole file transfer.

    # GNOME extensions.
    gnomeExtensions.app-hider # Hide desktop icons.

    # Others
    neovim
    git
    tcpdump
    gnome-maps

    (pkgs.writeShellScriptBin "switch" ''
      set -euo pipefail

      cd /home/admin/Repositories/NaviOS

      if ! ${pkgs.nix-output-monitor}/bin/nom build \
        .#system-gnome-mobile \
        --out-link result-system \
        "$@"; then
        printf '\a' >&2
        exit 1
      fi

      system_path="$(${pkgs.coreutils}/bin/readlink -e result-system)"

      printf '\a'
      echo "Press Enter to switch"
      read -r

      sudo ${pkgs.nix}/bin/nix-env \
        --profile /nix/var/nix/profiles/system \
        --set "$system_path"

      sudo "$system_path/bin/switch-to-configuration" switch
    '')
  ];

  # Enable Flatpak.
  services.flatpak.enable = true;
  systemd.services.flatpak-remote-add-flathub = {
    description = "Add Flathub repository for Flatpak";
    wantedBy = ["multi-user.target"];
    after = ["network-online.target"];
    wants = ["network-online.target"];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.flatpak}/bin/flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo";
      # Restart on failure (e.g., network not actually connected yet).
      Restart = "on-failure";
      RestartSec = "30s";
      # Give up after 20 attempts to avoid infinite retries.
      StartLimitBurst = 20;
    };
  };

  services.openssh = {
    enable = true;
    openFirewall = true;
    settings.PasswordAuthentication = true;
  };

  services.mmsd = {
    enable = true;
    extraArgs = ["--debug"];
  };

  # Create admin user with default password for testing.
  users = {
    mutableUsers = true;

    users.admin = {
      isNormalUser = true;
      # Default password: "admin" (insecure, for testing only).
      # Users should change this with `passwd` after first login.
      initialPassword = "admin";
      # Add to wheel group for sudo access and other groups for GNOME functionality.
      extraGroups = [
        "networkmanager" # Network configuration.
        "video" # Video device access.
        "wheel" # Sudo.
      ];
    };
  };

  programs.dconf = {
    enable = true;

    profiles.user.databases = [
      {
        settings = {
          "org/freedesktop/ibus/engine/typing-booster" = {
            dictionary = "en_US,fr_FR";
          };

          "org/gnome/desktop/background" = {
            picture-uri = "file://${config.age.secrets.wallpaper.path}";
            picture-uri-dark = "file://${config.age.secrets.wallpaper.path}";
          };
        };
      }
    ];
  };

  system.stateVersion = "25.05";
}
