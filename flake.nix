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

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    gnome-contacts-vcard-importer = {
      url = "github:adjivas/gnome-contacts-vcard-importer/1c1ca073762d67edcf64092953fd21a379e08939";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko/5ad85c82cc52264f4beddc934ba57f3789f28347";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvirt = {
      url = "https://flakehub.com/f/AshleyYakeley/NixVirt/*.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vfio = {
      url = "github:j-brn/nixos-vfio/bcbc23d59d6adc871fdd19d14420c26b98f4de93";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-generators = {
      url = "github:nix-community/nixos-generators/8946737ff703382fda7623b9fab071d037e897d5";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    microvm = {
      url = "github:microvm-nix/microvm.nix/e91d0e3c728d2af0404bb62641150c75935f0a71";
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
      url = "github:nix-community/fenix/a30830ebacdf957690dd8ea9ade9f12809ae0982";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    adwaita-cursors-multicolors = {
      url = "path:./thirdparty/adwaita-cursors-multicolors";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    secrets = {
      url = "git+file:///nix/persistent/secrets/age";
      flake = false;
    };
    secretsHomeAdjivas = {
      url = "git+file:///nix/persistent/home/adjivas/.secrets/age";
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
    # IDENT=... sudo --preserve-env=IDENT nix build ./#packages.x86_64-linux.dreaminstall --impure
    packages.x86_64-linux.dreaminstall = (nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      specialArgs = {
        inherit inputs self;
        secretsSystem = inputs.secrets;
        secretsUser = inputs.secretsHomeAdjivas;
      };

      modules = [
        ./hosts/dreaminstall/configuration.nix
        ({ lib, ident, modulesPath, ... }: {
          imports = [
            (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
          ];

          environment.etc."ident-red.txt".text = builtins.readFile (builtins.getEnv "IDENT");
        })
      ];
    }).config.system.build.isoImage;
    nixosConfigurations.dream76 = nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs self;
        hostname = "dream76";
      };
      modules = [
        ./version.nix
        ./hosts/dreamland/disk-config.nix
        ./hosts/dreamland/configuration.nix
        ./hosts/dreamland/hardware-configuration.nix
        determinate.nixosModules.default
        microvm.nixosModules.host
        disko.nixosModules.disko
        impermanence.nixosModules.impermanence
        home-manager.nixosModules.home-manager
        agenix.nixosModules.default
        vfio.nixosModules.vfio
        nixvirt.nixosModules.default
        ({ self, config, ... }: {
          imports = [
            (self + /nixosModules/nvidia.nix)
            (self + /nixosModules/power.nix)
          ];

          hardware.cpu.intel.updateMicrocode = true;
          hardware.enableRedistributableFirmware = true;

          hardware.system76.kernel-modules.enable = true;
          hardware.system76.enableAll = true;

          power.enable = true;
          nvidia = {
            enable = true;
            nvidiaBusId = "PCI:0:2:0"; 
            intelBusId = "PCI:1:0:0"; 
          };
        })
      ];
    };
    nixosConfigurations.dream00 = nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs self;
        hostname = "dream00";
      };
      modules = [
        ./version.nix
        ./hosts/dreamland/disk-config.nix
        ./hosts/dreamland/configuration.nix
        ./hosts/dreamland/hardware-configuration.nix
        determinate.nixosModules.default
        microvm.nixosModules.host
        disko.nixosModules.disko
        impermanence.nixosModules.impermanence
        home-manager.nixosModules.home-manager
        agenix.nixosModules.default
        vfio.nixosModules.vfio
        nixvirt.nixosModules.default
      ];
    };
  };
}
