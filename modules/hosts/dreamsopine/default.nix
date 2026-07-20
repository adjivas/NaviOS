{
  self,
  inputs,
  ...
}: {
  # sudo nix --extra-experimental-features nix-command --extra-experimental-features flakes build /etc/nixos#packages.aarch64-linux.dreamsopine
  flake.packages.aarch64-linux.dreamsopine = inputs.nixos-generators.nixosGenerate {
    system = "aarch64-linux";
    format = "sd-aarch64";

    specialArgs = {
      inherit inputs self;
    };

    modules = [
      self.nixosModules.dreamsopine
    ];
  };
}
