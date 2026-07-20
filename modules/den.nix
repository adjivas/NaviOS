{
  nixConfig,
  inputs,
  den,
  lib,
  ...
}: {
  imports = [inputs.den.flakeModule];

  den.default.homeManager.home.stateVersion = "26.05";
  den.default.nixos.system.stateVersion = "26.05";

  den.default.nixos = {
    _module.args = {
      inherit nixConfig;
      nixvirt = inputs.nixvirt;
    };
  };

  den.schema.user.classes = lib.mkDefault ["homeManager"];

  den.default.includes = [
    den.batteries.hostname
    den.batteries.define-user
  ];

  den.hosts.x86_64-linux = {
    dream00 = {
      hostName = "dream00";
      users.adjivas.classes = ["homeManager"];
      users.kad.classes = ["homeManager"];
    };

    dream76 = {
      hostName = "dream76";
      users.adjivas.classes = ["homeManager"];
      users.kad.classes = ["homeManager"];
    };
  };

  den.aspects.dreamland = {
    includes = [
      den.aspects.distro
      den.aspects.disko
      den.aspects.plymouth

      den.aspects.tincr
      den.aspects.usbip
    ];
    nixos = {config, ...}: {
      imports = [
        inputs.stylix.nixosModules.stylix
        inputs.determinate.nixosModules.default
        inputs.microvm.nixosModules.host
        inputs.impermanence.nixosModules.impermanence
        inputs.home-manager.nixosModules.home-manager
        inputs.agenix.nixosModules.default
        inputs.vfio.nixosModules.vfio
        inputs.nixvirt.nixosModules.default
        inputs.disko.nixosModules.disko
        inputs.fast-nix-gc.nixosModules.default
        inputs.tincr.nixosModules.tincr
      ];

      ssh = {
        sshPrivateKey = config.age.secrets.ssh_dreamland_ed25519_key.path;
      };
      age.secrets.tincr_dream00_ed25519_key = {
        # file = ./tincr_dream00_ed25519_key.age;
        owner = "tincr";
        group = "tincr";
        mode = "0400";
      };
      tincr = {
        name = "dreamland";
        key = config.age.secrets.tincr_dream00_ed25519_key.path;
        netAddress = "10.77.0.1";
        dnsAddress = "10.77.0.254";
        hosts = {
          dreamland = {
            subnet = "10.77.0.1";
            pub = "x+HORyUyUS2taqEWq3TY0IOghkfA2kJfv8u5Ed6XS0P";
          };

          firefox = {
            subnet = "10.77.0.10";
            pub = "vsl/XNVEVSA5IFrMs/2GBVDdm8p35ByRqDT3hK6Va/B";
            tcpOnly = true;
          };
          inkscape = {
            subnet = "10.77.0.11";
            pub = "cOQIaUdeWmK2Sy5Tj+emmVAtk+jJCAz7z7IW6WvFLVG";
            tcpOnly = true;
          };
          freecad = {
            subnet = "10.77.0.12";
            pub = "mMVezhC2fcY4iGxV5CXgbiTzzzevzCVhPiC822eQWaA";
            tcpOnly = true;
          };
          kicad = {
            subnet = "10.77.0.13";
            pub = "Z36RE4b/xAZ86P/pHbgrenDhXqltZyhXX19HoDBeYSN";
            tcpOnly = true;
          };
          krita = {
            subnet = "10.77.0.14";
            pub = "GlZNX7lN62vEZBiFIB0T0e7eiM26qzaW2b4iV/nvenF";
            tcpOnly = true;
          };
          blender = {
            subnet = "10.77.0.15";
            pub = "w3yZ49ODM4OKCG4F6gLn3DDsUkoRCJ4isGLIVtvsIJF";
            tcpOnly = true;
          };
          sm64coopdx = {
            subnet = "10.77.0.30";
            pub = "/JwS9PmQSkWfCXRAATzVHf1LehUSFWpNAlzoYT3N80L";
            tcpOnly = true;
          };
          xonotic = {
            subnet = "10.77.0.31";
            pub = "dK660YqKpaqHL2HHbMpc6zSN3txPv6Nk8WYAGa2LKlA";
            tcpOnly = true;
          };
          blue_player = {
            subnet = "10.77.0.50";
            pub = "Cs5G1XUw6WPPMv1ZXKdHEe6WE6fgi6tTjcYjivq+gCL";
            tcpOnly = true;
          };
          red_player = {
            subnet = "10.77.0.51";
            pub = "ZdSiO890oc9gnoM3K/lsaIUq883cBYewLxOU/xC6dvP";
            tcpOnly = true;
          };
          cyan_player = {
            subnet = "10.77.0.52";
            pub = "RXnd89Ah3IYlUI9PiEQ3sCg4RaiRuKhUgiF7dN34kPI";
            tcpOnly = true;
          };
          orange_player = {
            subnet = "10.77.0.53";
            pub = "qngKHoH6j8iRWkT7dOI0euaHqEPXv6ouowQ55em8v/P";
            tcpOnly = true;
          };
        };
      };
      # networking.firewall.interfaces."tinc-dreamland".allowedTCPPorts = [
      #   4000
      #   3240
      # ];
      networking.firewall.trustedInterfaces = [
        "tinc-dreamland"
      ];
      usbip.server.enable = true;
    };
  };

  den.aspects.dream00 = {
    includes = [
      den.aspects.dreamland-network
      den.aspects.dreamland-bridge
      den.aspects.dream00-multiseat

      den.aspects.dreamland
      den.aspects.hardware
      den.aspects.home-land
      den.aspects.stylix-theme
      den.aspects.agenix
      den.aspects.yubico
      den.aspects.i18n
      den.aspects.gc

      den.aspects.lan-mouse
      den.aspects.btrbk
      den.aspects.docker
      den.aspects.gitlab-runner
      den.aspects.lafayette
      den.aspects.nix-cache-server
      den.aspects.nix-cache-client
      den.aspects.pipewire
      den.aspects.steam
      den.aspects.virtualisation
      den.aspects.wl-kbptr
    ];

    nixos = {
      pkgs,
      config,
      ...
    }: {
      btrbk.remoteHost = "dream76";

      ssh = {
        sshPrivateKey = config.age.secrets.ssh_dreamland_ed25519_key.path;
      };

      hardware.cpu.intel.updateMicrocode = true;

      boot.kernelParams = [
        "pci=realloc" # "pci=assign-busses"
        "intel_iommu=on"
        "iommu=pt"
        "xe.max_vfs=1"
      ];
      boot.initrd.prepend = let
        acpiOverride = pkgs.runCommand "acpi_override.cpio" {} ''
          ${pkgs.coreutils}/bin/mkdir -p kernel/firmware/acpi
          ${pkgs.coreutils}/bin/cp ${../DSDT.aml} kernel/firmware/acpi/DSDT.aml
          ${pkgs.findutils}/bin/find kernel | ${pkgs.cpio}/bin/cpio -H newc --create > $out
        '';
      in [
        "${acpiOverride}"
      ];

      hardware.enableRedistributableFirmware = true;

      users.users.qemu-libvirtd.group = "qemu-libvirtd";
      users.groups.qemu-libvirtd = {};

      stylix-theme.cursorPackage = inputs.adwaita-cursors-multicolors.packages.x86_64-linux.default;

      dreamland.network.wifi.address = [
        "192.168.1.11/24"
        "2a04:cec0:1902:2824::11/64"
      ];
      dreamland.network.bridge.address = [
        "192.168.1.10/24"
        "2a04:cec0:1902:2824::10/64"
      ];

      # nix.cache.client = {
      #   extraSubstituters =
      #     [
      #       "http://dream76:5000?priority=10"
      #     ]
      #     ++ nixConfig.extra-substituters;
      #   extraTrustedPublicKeys =
      #     [
      #       "binarycache.example.com:9TSbWtdq8CqiAC28r3g2OF27vJP2I28edNSyRwMVgts="
      #     ]
      #     ++ nixConfig.extra-trusted-public-keys;
      # };

      home-manager.users.adjivas = {config, ...}: {
        lan-mouse = {
          port = 4242;
          authorizedFingerprints = config.age.secrets.lanmouse_fingerprints.path;

          clients = {
            dream00 = {
              position = "right";
              hostname = "localhost";
              port = 4343;
            };

            dream76 = {
              position = "left";
              hostname = "dream76";
              activate_on_startup = true;
              port = 4242;
            };
          };
        };
      };

      home-manager.users.kad = {config, ...}: {
        lan-mouse = {
          port = 4343;
          authorizedFingerprints =
            config.age.secrets.lanmouse_fingerprints.path;

          clients = {
            dream00 = {
              position = "left";
              hostname = "localhost";
              port = 4242;
            };

            dream76 = {
              position = "right";
              hostname = "dream76";
              port = 4343;
            };
          };
        };
      };
    };
  };

  den.aspects.dream76 = {
    includes = [
      den.aspects.dreamland
      den.aspects.hardware
      den.aspects.home-land
      den.aspects.stylix-theme
      den.aspects.agenix
      den.aspects.yubico
      den.aspects.i18n
      den.aspects.gc

      den.aspects.lan-mouse
      den.aspects.btrbk
      den.aspects.docker
      den.aspects.gitlab-runner
      den.aspects.lafayette
      den.aspects.nix-cache-server
      den.aspects.nix-cache-client
      den.aspects.pipewire
      den.aspects.steam
      den.aspects.virtualisation
      den.aspects.wl-kbptr
      den.aspects.dreamland-network
      den.aspects.dreamland-bridge

      den.aspects.nvidia
      den.aspects.power
    ];

    nixos = {
      services.xserver.videoDrivers = ["intel"];
      btrbk.remoteHost = "dream00";

      hardware.cpu.intel.updateMicrocode = true;
      hardware.enableRedistributableFirmware = true;

      users.users.qemu-libvirtd.group = "qemu-libvirtd";
      users.groups.qemu-libvirtd = {};

      hardware.system76.kernel-modules.enable = true;
      hardware.system76.enableAll = true;

      nvidia = {
        nvidiaBusId = "PCI:0:2:0";
        intelBusId = "PCI:1:0:0";
      };

      stylix-theme.cursorPackage = inputs.adwaita-cursors-multicolors.packages.x86_64-linux.default;

      # dreamland.network.lan.address = [
      #   "192.168.1.76/24"
      #   "::ffff:c0a8:14c/64"
      # ];
      dreamland.network.wifi.address = [
        "192.168.1.77/24"
        "2a04:cec0:1902:2824::77/64"
      ];
      dreamland.network.bridge.address = [
        "192.168.1.76/24"
        "2a04:cec0:1902:2824::76/64"
      ];

      nix.cache.client = {
        extraSubstituters = nixConfig.extra-substituters;
        extraTrustedPublicKeys = nixConfig.extra-trusted-public-keys;
      };

      home-manager.users.adjivas = {config, ...}: {
        sway.extraOptions = ["--unsupported-gpu"];
        lan-mouse = {
          port = 4242;
          authorizedFingerprints =
            config.age.secrets.lanmouse_fingerprints.path;

          clients.dream00 = {
            position = "right";
            hostname = "dream00";
            activate_on_startup = true;
            port = 4242;
          };
        };
      };

      home-manager.users.kad = {config, ...}: {
        sway.extraOptions = ["--unsupported-gpu"];
        lan-mouse = {
          port = 4343;
          authorizedFingerprints =
            config.age.secrets.lanmouse_fingerprints.path;

          clients.dream00 = {
            position = "left";
            hostname = "dream00";
            port = 4343;
          };
        };
      };
    };
  };

  den.aspects.adjivas = {
    includes = [
      den.aspects.agenix-adjivas
      den.aspects.switch

      den.aspects.terminal
      den.aspects.application
      den.aspects.desktop
      den.aspects.game
      den.aspects.sm64ex

      den.aspects.gnome-control-center
      den.aspects.gnome-keyring
      den.aspects.lan-mouse
      den.aspects.password-store
      den.aspects.agent
      den.aspects.wl-kbptr
      den.aspects.rofi
      den.aspects.rust
      den.aspects.newsboat
      den.aspects.cachix
      den.aspects.virtualisation
    ];

    nixos = {config, ...}: {
      users.users.adjivas = {
        hashedPasswordFile = config.age.secrets."adjivas-password".path;

        extraGroups = [
          "wheel"
          "power"
          "autologin"
          "seat"
          "video"
          "render"
          "input"
          "uinput"
          "docker"
          "microvm"
          "dialout"
        ]; # Enable ‘sudo’ for the user.

        openssh.authorizedKeys.keys = [
          "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIO9h/mVcJGG/DHtu+xD5rPRQSWJ4iJbpDILQgrg/B322AAAAFnNzaDp5dWJpa2V5XzVhX2Fkaml2YXM= adjivas@dream76"
          "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAINJSiyvg6B7BRwdsAGEJ26Xgl0E8bPGIhJbouQSQ2DYjAAAAFnNzaDp5dWJpa2V5XzVjX2Fkaml2YXM= adjivas@dream76"
        ];
      };
    };

    homeManager = {
      programs.home-manager.enable = true;
    };
  };

  den.aspects.kad = {
    includes = [
      den.aspects.agenix-kad

      den.aspects.terminal
      den.aspects.application
      den.aspects.desktop
      den.aspects.game

      den.aspects.gnome-control-center
      den.aspects.lan-mouse
      den.aspects.rust
      den.aspects.rofi
    ];

    nixos = {config, ...}: {
      users.users.kad = {
        hashedPasswordFile = config.age.secrets."adjivas-password".path;
        extraGroups = ["wheel" "power" "autologin" "seat" "video" "render" "kvm" "libvirtd" "input"]; # Enable ‘sudo’ for the user.
      };
    };

    homeManager = {
      programs.home-manager.enable = true;
    };
  };
}
