{
  self,
  inputs,
  ...
}: {
  # IDENT=... sudo --preserve-env=IDENT nix build ./#packages.x86_64-linux.dreaminstall --impure
  flake.packages.x86_64-linux.dreaminstall =
    (inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      specialArgs = {
        inherit inputs self;

        secretsSystem = inputs.secrets;
        secretsUser = inputs.secretsHomeLand;
      };

      modules = [
        self.nixosModules.dreaminstall
        ({modulesPath, ...}: {
          imports = [
            (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
          ];

          environment.etc."ident-red.txt".text =
            builtins.readFile (builtins.getEnv "IDENT");
        })
      ];
    }).config.system.build.isoImage;
}
