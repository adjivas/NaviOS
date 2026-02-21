{
  nixConfig = {
    experimental-features = [
      "flakes"
      "nix-command"
      "pipe-operators"
    ];
    extra-substituters = [
      "https://shwewo.cachix.org"
      "https://microvm.cachix.org"
      "https://lan-mouse.cachix.org/"
      "https://cache.garnix.io"
    ];
    extra-trusted-public-keys = [
      "shwewo.cachix.org-1:84cIX7ETlqQwAWHBnd51cD4BeUVXCyGbFdtp+vLxKOo="
      "microvm.cachix.org-1:oXnBc6hRE3eX5rSYdRyMYXnfzcCxC7yKPTbZXALsqys="
      "lan-mouse.cachix.org-1:KlE2AEZUgkzNKM7BIzMQo8w9yJYqUpor1CAUNRY6OyM="
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";

    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

    flake-utils.url = "github:numtide/flake-utils";

    impermanence.url = "github:nix-community/impermanence";
    agenix.url = "github:ryantm/agenix";
    nvf.url = "github:notashelf/nvf";
    stylix.url = "github:danth/stylix/release-25.11";
    lan-mouse.url = "github:feschber/lan-mouse";
    telegram-desktop-patched.url = "github:shwewo/telegram-desktop-patched";
    nix-topology.url = "github:oddlama/nix-topology";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    gnome-contacts-vcard-importer = {
      url = "github:adjivas/gnome-contacts-vcard-importer";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvirt = {
      # url = "https://flakehub.com/f/AshleyYakeley/NixVirt/*.tar.gz";
      url = "github:adjivas/NixVirt";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vfio = {
      url = "github:j-brn/nixos-vfio";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    microvm = {
      url = "github:microvm-nix/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lafayette-keyboard = {
      # url = "https://qwerty-lafayette.org/releases/lafayette_linux_v0.9.xkb_custom";
      url = "https://qwerty-lafayette.org/layouts/lafayette.toml";
      flake = false;
    };

    nix-luanti = {
      type = "gitlab";
      owner = "leonard";
      repo = "nix-luanti";
      host = "git.menzel.lol";
      ref = "main";
    };

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    adwaita-cursors-multicolors = {
      url = "path:./thirdparty/adwaita-cursors-multicolors";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    secrets = {
      url = "path:/nix/persistent/secrets/age";
      flake = false;
    };
  };

  outputs = {
    self,
    determinate,
    flake-utils,
    nixpkgs,
    disko,
    impermanence,
    vfio,
    nixvirt,
    home-manager,
    agenix,
    secrets,
    nixos-generators,
    stylix,
    firefox-addons,
    microvm,
    nix-topology,
    ...
  }@inputs: {
    # sudo nix --extra-experimental-features nix-command --extra-experimental-features flakes build /etc/nixos#packages.aarch64-linux.dreamsopine
    packages.aarch64-linux.dreamsopine = nixos-generators.nixosGenerate {
      system = "aarch64-linux";
      format = "sd-aarch64";
      specialArgs = {
        inherit inputs self;
      };
      modules = [
        ./hosts/dreamsopine/configuration.nix
        ./hosts/dreamsopine/hardware-configuration.nix
      ];
    };
    # sudo nix --extra-experimental-features nix-command --extra-experimental-features flakes build /etc/nixos#packages.x86_64-linux.dreaminstall
    # packages.x86_64-linux.dreaminstall = nixos-generators.nixosGenerate {
    #   system = "x86_64-linux";
    #   pkgs = nixpkgs.legacyPackages.x86_64-linux;
    #   format = "install-iso";
    #   specialArgs = {
    #     inherit inputs self;
    #   };
    #   modules = [
    #     ./hosts/dreaminstall/configuration.nix
    #   ];
    # };
    # sudo nix --extra-experimental-features nix-command --extra-experimental-features flakes build /etc/nixos#dreamsm64ex
    packages.x86_64-linux.dreamsm64ex = nixos-generators.nixosGenerate {
      system = "x86_64-linux";
      # pkgs = nixpkgs.legacyPackages.x86_64-linux;
      format = "qcow-efi";
      specialArgs = {
        inherit inputs self;
      };
      modules = [
        ./hosts/dreamsm64ex/configuration.nix
        home-manager.nixosModules.home-manager
      ];
    };
    # sudo nix --extra-experimental-features nix-command --extra-experimental-features flakes build /etc/nixos#dreamkad
    packages.x86_64-linux.dreamkad = nixos-generators.nixosGenerate {
      system = "x86_64-linux";
      # pkgs = nixpkgs.legacyPackages.x86_64-linux;
      format = "qcow-efi";
      specialArgs = {
        inherit inputs self;
      };
      modules = [
        ./hosts/dreamkad/configuration.nix
        vfio.nixosModules.vfio
        disko.nixosModules.disko
        nixvirt.nixosModules.default
        home-manager.nixosModules.home-manager
        ({ pkgs, ... }: {
          boot.initrd.supportedFilesystems = [ "btrfs" ];

          fileSystems."/home/kad" = {
            device = "/dev/disk/by-label/dreamkad-home";
            fsType = "btrfs";
            options = [
              "compress=zstd"
              "noatime"
              "nofail"
            ];
          };

          systemd.tmpfiles.rules = [
            "d /home/kad 0755 kad users - -"
          ];
        })
      ];
    };
    # sudo nix run --extra-experimental-features nix-command --extra-experimental-features flakes /etc/nixos#dreamluanti-microvm
    # sudo nix build --extra-experimental-features nix-command --extra-experimental-features flakes /etc/nixos#dreamluanti-microvm
    # packages.x86_64-linux.dreamluanti-microvm = let
    #   # pkgs = import nixpkgs { system = "x86_64-linux"; };
    #   vm = nixpkgs.lib.nixosSystem {
    #     system = "x86_64-v3-linux";
    #     specialArgs = {
    #       inherit self;
    #       nix-luanti = inputs.nix-luanti;
    #     };
    #     modules = [
    #       hosts/dreamluanti/configuration.nix
    #       microvm.nixosModules.microvm
    #       ({... }: {
    #         microvm = {
    #           hypervisor = "qemu";
    #           vcpu = 2;
    #           mem = 1024;
    #         };
    #       })
    #     ];
    #   };
    # in vm.config.microvm.declaredRunner;
    # nixos-rebuild --use-remote-sudo switch --flake /home/adjivas/Repositories/Nix#dreamadjivas
    nixosConfigurations.dreamadjivas = nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs self;
      };
      modules = [
        ./version.nix
        ./hosts/dreamadjivas/disk-config.nix
        ./hosts/dreamadjivas/configuration.nix
        ./hosts/dreamadjivas/hardware-configuration.nix
        determinate.nixosModules.default
        microvm.nixosModules.host
        disko.nixosModules.disko
        impermanence.nixosModules.impermanence
        home-manager.nixosModules.home-manager
        agenix.nixosModules.default
        vfio.nixosModules.vfio
        nixvirt.nixosModules.default
        nix-topology.nixosModules.default
      ];
    };
  } // flake-utils.lib.eachDefaultSystem (system: rec {
    pkgs = import nixpkgs {
      inherit system;
      overlays = [ nix-topology.overlays.default ];
    };

    topology = import nix-topology {
      inherit pkgs;
      modules = [
        # Your own file to define global topology. Works in principle like a nixos module but uses different options.
        ./topology.nix
        # Inline module to inform topology of your existing NixOS hosts.
        { nixosConfigurations = self.nixosConfigurations; }
      ];
    };
  });
}
