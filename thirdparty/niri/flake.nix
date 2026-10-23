{
  description = "NaviOS custom Niri build";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    niri.url = "github:kiryl/niri/3e9d49a0506a04c4778eba5c0f447cc3433c904c";

    biri = {
      url = "github:barrulus/biri";
      flake = false;
    };

    lniri = {
      url = "github:TattvaOrg/Lniri";
      flake = false;
    };
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      perSystem = {system, ...}: let
        # Important:
        # On utilise directement le package construit par la flake Kiryl.
        # Celui-ci utilise son propre nixpkgs (d3498f7), qui fournit
        # libdisplay-info_0_3.
        baseNiri = inputs.niri.packages.${system}.niri;

        niri = baseNiri.overrideAttrs (old: {
          pname = "niri";

          patches =
            (old.patches or [])
            ++ [
              ./biri-global-shader.patch
              ./lniri-on-biri.patch
            ];

          postPatch =
            (old.postPatch or "")
            + ''
              cp -f \
                ${inputs.lniri}/src/render_helpers/liquid_glass.rs \
                src/render_helpers/liquid_glass.rs

              cp -f \
                ${inputs.lniri}/src/render_helpers/background_effect.rs \
                src/render_helpers/background_effect.rs

              cp -f \
                ${inputs.lniri}/src/render_helpers/xray.rs \
                src/render_helpers/xray.rs

              cp -f \
                ${inputs.lniri}/src/render_helpers/shaders/clipped_surface.frag \
                src/render_helpers/shaders/clipped_surface.frag

              cp -f \
                ${inputs.lniri}/niri-config/src/appearance.rs \
                niri-config/src/appearance.rs
            '';
        });
      in {
        packages = {
          inherit niri;
          default = niri;
        };
      };
    };
}
