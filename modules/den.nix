{
  self,
  nixConfig,
  inputs,
  den,
  lib,
  ...
}: {
  imports = [
    inputs.den.flakeModule
  ];

  den.default.homeManager.home.stateVersion = "26.05";
  den.default.nixos.system.stateVersion = "26.05";

  den.default.nixos = {
    _module.args = {
      inherit nixConfig;
      nixvirt = inputs.nixvirt;
    };

    time.timeZone = "Europe/Paris";
  };

  den.schema.user.classes = lib.mkDefault ["homeManager"];

  den.default.includes = [
    den.batteries.hostname
    den.batteries.define-user
    den.batteries.host-aspects
    den.batteries.i18n
  ];

  den.hosts.x86_64-linux = {
    dream76 = {
      hostName = "dream76";
      users.adjivas.classes = ["homeManager"];
    };
  };

  den.hosts.aarch64-linux = {
    dream33 = {
      hostName = "dream33";
      users.adjivas.classes = ["homeManager"];
    };

    dream05 = {
      hostName = "dream05";
      users.adjivas.classes = ["homeManager"];
    };
  };

  den.aspects.dreamland = {
    includes = [
      den.aspects.distro

      den.aspects.yubico
      den.aspects.agenix

      den.aspects.home-land

      den.aspects.terminal
    ];
    nixos = {
      config,
      pkgs,
      ...
    }: {
      imports = [
        inputs.determinate.nixosModules.default
      ];

      environment.variables.EDITOR = "nvim";

      environment.systemPackages = with pkgs; [
        neovim
      ];

      users.users.root.hashedPasswordFile = config.age.secrets."root-password".path;

      security.pki.certificateFiles = [
        ../certificates/dreamland-root-ca.cert
      ];
      ssh.sshPrivateKey = config.age.secrets.ssh_dreamland_ed25519_key.path;
    };
  };

  den.aspects.dream76 = {
    includes = [
      den.aspects.dreamland

      den.aspects.disko
      den.aspects.plymouth
      den.aspects.blocky

      den.aspects.stylix-theme
      den.aspects.application

      den.aspects.dreamland-network # TODO evil aspect, should be unified
      den.aspects.dreamland-bridge # TODO evil aspect, should be unified
      den.aspects.dream76-hardware # TODO evil aspect, should be unified
      den.aspects.dream76-configuration # TODO evil aspect, should be unified
      den.aspects.bluetooth # TODO evil aspect, should be unified
      den.aspects.lact
      den.aspects.pipewire # TODO evil aspect, should be unified
      den.aspects.power

      (den.aspects.nvidia {
        nvidiaBusId = "PCI:1:0:0";
        intelBusId = "PCI:0:2:0";
      })
      den.aspects.system76-scheduler-niri
      (den.aspects.smartd {
        devices = ["/dev/nvme0n1"];
      })
      den.aspects.lafayette-dreamland
    ];

    nixos = {pkgs, ...}: {
      services.xserver.videoDrivers = ["intel"];

      environment.sessionVariables.SWAY_UNSUPPORTED_GPU = "true";

      stylix-theme.cursorPackage = inputs.adwaita-cursors-multicolors.packages.${pkgs.stdenv.hostPlatform.system}.default;

      dreamland.network.wifi.address = [
        "192.168.1.77/24"
        "2a04:cec0:1902:2824::77/64"
      ];
      dreamland.network.bridge.address = [
        "192.168.77.1/24"
        "fd77::1/64"
      ];
    };
  };

  den.aspects.dream33 = {
    includes = [
      den.aspects.dreamland
      den.aspects.dream33-bridge # TODO evil aspect, should be removed
      den.aspects.dream33-hardware # TODO evil aspect, should be removed
      den.aspects.dream33-configuration # TODO evil aspect, should be removed
      (den.aspects.nix-builder {
        publicKeys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICB5OPh5mj04EL5c59VwTgLdNbExKfng3yn2TAOhGlCT dreamland-nix-builder"
        ];
      })
    ];
    nixos = {};
  };

  den.aspects.dream05 = {
    includes = [
      den.aspects.dreamland

      den.aspects.dream05-hardware # TODO evil aspect, should be unified
      den.aspects.dream05-configuration # TODO evil aspect, should be unified
      den.aspects.dream05-disk-image
      den.aspects.dream05-wifi # TODO evil aspect, should be unified
      den.aspects.dream05-bluetooth # TODO evil aspect, should be unified
      den.aspects.dream05-audio # TODO evil aspect, should be unified
      den.aspects.dream05-sensors
      den.aspects.dream05-modem # TODO evil aspect, should be unified
      den.aspects.dream05-gnome-mobile # TODO evil aspect, should be unified
      den.aspects.dream05-power-button
      (den.aspects.dream05-gnome-wallpaper {
        path = "${self.outPath}/artwork/wallpaper-mobile.jpg";
      })
      den.aspects.dream05-gnome-scheme
      den.aspects.megapixels

      (den.batteries.nix-remote-builder {
        hostName = "192.168.1.238";
        port = 60022;
        publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUk5cHBWZnBaem5EQWpPaTBoVHJDaHNrZFZzbG5OWUpMNGUrTXN2KzFGL2IK";

        systems = ["aarch64-linux"];
        maxJobs = 4;
      })
    ];
    nixos = {config, ...}: {
      nixpkgs.overlays = [
        inputs.nixos-fairphone-fp5.overlays.default
      ];

      nix-remote-builder = {
        localBuilds = false;
        sshKey = config.age.secrets.dreamland-nix-builder.path;
      };

      users.mutableUsers = true; # TODO evil, should be unified
    };
  };

  den.aspects.adjivas = {
    includes = [
      den.batteries.primary-user

      den.aspects.persistence-user

      den.aspects.agenix-adjivas

      den.aspects.switch

      (den.aspects.ssh-user {
        publicKeys = [
          "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIO9h/mVcJGG/DHtu+xD5rPRQSWJ4iJbpDILQgrg/B322AAAAFnNzaDp5dWJpa2V5XzVhX2Fkaml2YXM= adjivas@dream76"
          "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAINJSiyvg6B7BRwdsAGEJ26Xgl0E8bPGIhJbouQSQ2DYjAAAAFnNzaDp5dWJpa2V5XzVjX2Fkaml2YXM= adjivas@dream76"
        ];
        identityFiles = [
          "yubikey-5a-adjivas"
          "yubikey-5c-adjivas"
        ];
      })
    ];

    user = {osConfig, ...}: {
      hashedPasswordFile = osConfig.age.secrets."adjivas-password".path;
      extraGroups = [
        "power"
        "wheel"
      ];
    };
  };

  den.aspects."adjivas@dream76" = {
    includes = [
      (den.batteries.nix-remote-builder {
        hostName = "192.168.1.238";
        port = 60022;
        publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUk5cHBWZnBaem5EQWpPaTBoVHJDaHNrZFZzbG5OWUpMNGUrTXN2KzFGL2IK";

        systems = ["aarch64-linux"];
        maxJobs = 4;
      })

      (den.aspects.autologin {
        defaultSession = "niri";
      })

      den.aspects.firefox-adjivas
      den.aspects.firefox-bookmarks-user
      den.aspects.firefox-pinned-user
      den.aspects.firefox-ublock
      den.aspects.firefox-youtube-to-vlc
      den.aspects.firefox-passff

      den.aspects.password-store

      den.aspects.steam

      den.aspects.qmk-user

      (den.batteries.niri-session {
        display = "wayland-1";
        includes = [
          den.aspects.helic
          den.aspects.anyrun
          den.aspects.swaylock-niri
          den.aspects.niri-glass
          den.aspects.niri-cursor
          (den.batteries.wlsunset {
            nightTemperature = 3500;
          })
          (den.batteries.awww {
            wallpaper = "${self.outPath}/artwork/wallpaper.jpg";
          })
          (den.batteries.waybar {
            position = "top";
            aspects = [
              den.aspects.waybar-tux
              den.aspects.waybar-time-cal
              den.aspects.waybar-tray
              den.aspects.waybar-backlight
              den.aspects.waybar-sunset
              den.aspects.waybar-wireplumber
              den.aspects.waybar-battery
              den.aspects.waybar-bluetooth
              den.aspects.waybar-network
              den.aspects.waybar-date-cal
            ];
          })
        ];
      })

      den.aspects.gnome-keyring
      den.aspects.gnome-control-center
      den.aspects.gnome-contacts
      den.aspects.chroncal
    ];

    nixos = {config, ...}: {
      nix-remote-builder.sshKey = config.age.secrets.dreamland-nix-builder.path;
    };
    homeManager = {config, ...}: {
      chroncal.accounts.framasoft = {
        server = "https://framagenda.org/remote.php/dav/calendars/adjivas/sortie";
        passwordFile = config.age.secrets.cal_framagenda.path;
      };
      firefox.policies.Certificates.Install = [
        config.age.secrets.dreamland_cert_root.path
      ];
      gnome-contacts.book = config.age.secrets."contacts.vcf".path;
    };
  };

  den.aspects."adjivas@dream05" = {
    includes = [
      den.aspects.dream05-camera # TODO evil aspect, should be unified
      (den.aspects.waydroid {
        cameraPassthrough = true;
      })

      (den.aspects.location {
        geoProviderUrl = "https://api.beacondb.net/v1/geolocate";
      })

      den.aspects.gnome-contacts

      den.aspects.vlc
    ];
    user = {osConfig, ...}: {
      hashedPasswordFile = osConfig.age.secrets."adjivas-password".path;
      extraGroups = [
        "networkmanager" # Network configuration.
        "video" # Video device access.
        "wheel" # Sudo.
      ];
    };
    homeManager = {config, ...}: {
      gnome-contacts.book = config.age.secrets."contacts.vcf".path;
    };
  };
}
