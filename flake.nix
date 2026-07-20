rec {
  nixConfig = {
    experimental-features = [
      "flakes"
      "nix-command"
      "pipe-operators"
    ];
    extra-substituters = [
      "https://adjivas.cachix.org"
      "https://shwewo.cachix.org"
      "https://microvm.cachix.org"
      "https://lan-mouse.cachix.org/"
      "https://nix-community.cachix.org"
      "https://cache.nixos.org/"
      "https://cache.garnix.io"
      "https://attic.xuyh0120.win/lantian"
      "https://mic92.cachix.org"
    ];
    extra-trusted-public-keys = [
      "adjivas.cachix.org-1:f/cVF492LrDoJugvKWsOziU+1x7PY3/Zw+D7rog1Igc="
      "shwewo.cachix.org-1:84cIX7ETlqQwAWHBnd51cD4BeUVXCyGbFdtp+vLxKOo="
      "microvm.cachix.org-1:oXnBc6hRE3eX5rSYdRyMYXnfzcCxC7yKPTbZXALsqys="
      "lan-mouse.cachix.org-1:KlE2AEZUgkzNKM7BIzMQo8w9yJYqUpor1CAUNRY6OyM="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
      "mic92.cachix.org-1:gi8IhgiT3CYZnJsaW7fxznzTkMUOn1RY4GmXdT/nXYQ="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";

    den.url = "github:denful/den";
    import-tree.url = "github:vic/import-tree";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-aspects.url = "github:denful/flake-aspects";
    nix-log-check.url = "github:dramforever/nix-log-check";

    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";

    den-diagram = {
      url = "github:denful/den-diagram";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-cachyos-kernel = {
      url = "github:xddxdd/nix-cachyos-kernel/release";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence = {
      url = "github:nix-community/impermanence";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lan-mouse = {
      url = "github:feschber/lan-mouse";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    wrappers = {
      url = "github:Lassulus/wrappers";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:nix-community/stylix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
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

    tincr = {
      url = "github:Mic92/tincr";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    fast-nix-gc = {
      url = "github:Mic92/fast-nix-gc";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    fenix = {
      url = "github:nix-community/fenix/a30830ebacdf957690dd8ea9ade9f12809ae0982";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    adwaita-cursors-multicolors = {
      url = "path:./thirdparty/adwaita-cursors-multicolors";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    moonlight-web-stream = {
      url = "path:./thirdparty/moonlight-web-stream";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.fenix.follows = "fenix";
      inputs.flake-parts.follows = "flake-parts";
    };

    munix = {
      url = "git+https://git.clan.lol/clan/munix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lafayette-keyboard = {
      # url = "https://qwerty-lafayette.org/releases/lafayette_linux_v0.9.xkb_custom";
      url = "https://qwerty-lafayette.org/layouts/lafayette.toml";
      flake = false;
    };

    # nix flake update secrets
    secrets = {
      url = "path:///nix/persistent/secrets/age";
      flake = false;
    };
    # nix flake update secretsHomeLand
    secretsHomeLand = {
      url = "path:///nix/persistent/home/adjivas/.secrets/age";
      flake = false;
    };

    detnix-patch = {
      url = "https://github.com/user-attachments/files/27144728/detnix.patch";
      flake = false;
    };
  };

  outputs = inputs @ {
    flake-parts,
    flake-aspects,
    pre-commit-hooks,
    import-tree,
    ...
  }:
    flake-parts.lib.mkFlake {
      inherit inputs;
      specialArgs = {
        inherit nixConfig;
      };
    } {
      _module.args = {inherit nixConfig;};
      imports = [
        pre-commit-hooks.flakeModule
        flake-aspects.flakeModule
        (import-tree ./modules)
      ];
      systems = ["x86_64-linux" "aarch64-linux"];

      flake.overlays.default = _final: prev: {
        qemu-host-cpu-only = prev.qemu_kvm.override {
          hostCpuOnly = true;
        };
      };

      perSystem = {
        config,
        pkgs,
        ...
      }: {
        pre-commit = {
          check.enable = true;

          settings = {
            src = ./.;
            hooks = {
              alejandra.enable = true;
              deadnix.enable = true;
              statix.enable = true;
            };
          };
        };

        # nix develop -c pre-commit run -a
        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.pre-commit
          ];
          shellHook = config.pre-commit.installationScript;
        };
      };
    };
}
