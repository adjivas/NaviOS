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
    den.batteries.host-aspects
    den.batteries.i18n
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
      den.aspects.plymouth

      den.aspects.disko
      den.aspects.hardware
      den.aspects.pipewire
      den.aspects.lan-mouse
      den.aspects.wl-kbptr
      den.aspects.lafayette
      den.aspects.btrbk

      den.aspects.gc
      den.aspects.nix-cache-server
      den.aspects.nix-cache-client

      den.aspects.home-land
      den.aspects.stylix-theme

      den.aspects.terminal
      den.aspects.application
      den.aspects.desktop
      den.aspects.game

      den.aspects.gnome-control-center
      den.aspects.gnome-keyring
      den.aspects.rust
      den.aspects.agenix

      den.aspects.virtualisation
      den.aspects.dreamland-network
      den.aspects.dreamland-bridge

      den.aspects.yubico

      (den.batteries.cloud-hypervisor-tap {
        id = "sm64coopdx";
        user = "adjivas";
        mac = "02:00:00:00:00:30";
      })
      (den.batteries.cloud-hypervisor-tap {
        id = "srht";
        user = "adjivas";
        mac = "02:00:00:00:00:22";
      })
      (den.batteries.tincr {
        name = "dreamland";
        key = config: config.age.secrets.tincr_dream00_ed25519_key.path;
        netAddress = "10.77.0.1";
        dnsAddress = "10.77.0.254";
        hosts = {
          # tinc -c . -n libreoffice init libreoffice
          dreamland = {
            subnet = "10.77.0.1";
            pub = "x+HORyUyUS2taqEWq3TY0IOghkfA2kJfv8u5Ed6XS0P";
          };
          firefox = {
            subnet = "10.77.0.10";
            pub = "vsl/XNVEVSA5IFrMs/2GBVDdm8p35ByRqDT3hK6Va/B";
          };
          inkscape = {
            subnet = "10.77.0.11";
            pub = "cOQIaUdeWmK2Sy5Tj+emmVAtk+jJCAz7z7IW6WvFLVG";
          };
          freecad = {
            subnet = "10.77.0.12";
            pub = "mMVezhC2fcY4iGxV5CXgbiTzzzevzCVhPiC822eQWaA";
          };
          kicad = {
            subnet = "10.77.0.13";
            pub = "Z36RE4b/xAZ86P/pHbgrenDhXqltZyhXX19HoDBeYSN";
          };
          krita = {
            subnet = "10.77.0.14";
            pub = "GlZNX7lN62vEZBiFIB0T0e7eiM26qzaW2b4iV/nvenF";
          };
          blender = {
            subnet = "10.77.0.15";
            pub = "w3yZ49ODM4OKCG4F6gLn3DDsUkoRCJ4isGLIVtvsIJF";
          };
          libreoffice = {
            subnet = "10.77.0.16";
            pub = "wzirvFktkfcIG0OLUwYd6STd/2jbo79FK2vRfoEDeZK";
          };
          srht = {
            subnet = "10.77.0.22";
            pub = "a128IQAMJFWiAaB/4H68G449iWEQpPZUIcGOVZYJzGC";
          };
          sm64coopdx = {
            subnet = "10.77.0.30";
            pub = "/JwS9PmQSkWfCXRAATzVHf1LehUSFWpNAlzoYT3N80L";
          };
          xonotic = {
            subnet = "10.77.0.31";
            pub = "dK660YqKpaqHL2HHbMpc6zSN3txPv6Nk8WYAGa2LKlA";
          };
          blue_player = {
            subnet = "10.77.0.50";
            pub = "Cs5G1XUw6WPPMv1ZXKdHEe6WE6fgi6tTjcYjivq+gCL";
          };
          red_player = {
            subnet = "10.77.0.51";
            pub = "ZdSiO890oc9gnoM3K/lsaIUq883cBYewLxOU/xC6dvP";
          };
          cyan_player = {
            subnet = "10.77.0.52";
            pub = "RXnd89Ah3IYlUI9PiEQ3sCg4RaiRuKhUgiF7dN34kPI";
          };
          orange_player = {
            subnet = "10.77.0.53";
            pub = "qngKHoH6j8iRWkT7dOI0euaHqEPXv6ouowQ55em8v/P";
          };
        };
      })
      den.aspects.usbip
      den.aspects.gamepad-usbip
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

      security.pki.certificateFiles = [
        ../certificates/dreamland-root-ca.cert
      ];
      networking.hosts = {
        "10.77.0.22" = ["meta.sr.ht.local" "git.sr.ht.local"];
      };
      ssh = {
        sshPrivateKey = config.age.secrets.ssh_dreamland_ed25519_key.path;
      };
      age.secrets.tincr_dream00_ed25519_key = {
        owner = "tincr";
        group = "tincr";
        mode = "0400";
      };
      age.secrets.btrbk_dreamland_ed25519_key = {
        owner = "btrbk";
        group = "btrbk";
        mode = "0400";
      };
      networking.firewall.trustedInterfaces = [
        "tinc-dreamland"
      ];
      usbip.server.enable = true;

      users.groups.qmk = {};

      services.udev.extraRules = ''
        # ErgoDox EZ / HalfKay
        SUBSYSTEM=="usb", ATTR{idVendor}=="16c0", ATTR{idProduct}=="0478", GROUP="qmk", MODE="0660"

        # Swiss / Atmel DFU
        SUBSYSTEM=="usb", ATTR{idVendor}=="03eb", ATTR{idProduct}=="2ff4", GROUP="qmk", MODE="0660"
      '';
    };
  };

  den.aspects.dream00 = {
    includes = [
      den.aspects.dreamland

      # den.aspects.dream00-multiseat
    ];

    nixos = {pkgs, ...}: {
      btrbk.remoteHost = "dream76";

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
        "192.168.77.1/24"
        "fd77::1/64"
      ];

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
          authorizedFingerprints = config.age.secrets.lanmouse_fingerprints.path;

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

      den.aspects.smartd

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

      dreamland.network.wifi.address = [
        "192.168.1.77/24"
        "2a04:cec0:1902:2824::77/64"
      ];
      dreamland.network.bridge.address = [
        "192.168.77.1/24"
        "fd77::1/64"
      ];

      nix.cache.client = {
        extraSubstituters = nixConfig.extra-substituters;
        extraTrustedPublicKeys = nixConfig.extra-trusted-public-keys;
      };
      home-manager.users.adjivas = {config, ...}: {
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
    homeManager = {
      sway.extraOptions = ["--unsupported-gpu"];
    };
  };

  den.aspects.adjivas = {
    includes = [
      den.batteries.primary-user

      den.aspects.agenix-adjivas

      den.aspects.switch
      den.aspects.cachix
      den.aspects.password-store
    ];

    user = {osConfig, ...}: {
      hashedPasswordFile = osConfig.age.secrets."adjivas-password".path;
      extraGroups = [
        "power"
        "autologin"
        "seat"
        "video"
        "render"
        "input"
        "uinput"
        "microvm"
        "dialout"
        "qmk"
        # "docker"
      ];
      openssh.authorizedKeys.keys = [
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIO9h/mVcJGG/DHtu+xD5rPRQSWJ4iJbpDILQgrg/B322AAAAFnNzaDp5dWJpa2V5XzVhX2Fkaml2YXM= adjivas@dream76"
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAINJSiyvg6B7BRwdsAGEJ26Xgl0E8bPGIhJbouQSQ2DYjAAAAFnNzaDp5dWJpa2V5XzVjX2Fkaml2YXM= adjivas@dream76"
      ];
    };
  };

  den.aspects.kad = {
    includes = [
      den.aspects.agenix-kad
    ];

    user = {osConfig, ...}: {
      hashedPasswordFile = osConfig.age.secrets."adjivas-password".path;
      extraGroups = [
        "power"
        "autologin"
        "seat"
        "video"
        "render"
        "kvm"
        "libvirtd"
        "input"
      ]; # Enable ‘sudo’ for the user.
    };
  };
}
