{inputs, ...}: {
  den.aspects.microvm-rootless-virtiofsd = {
    nixos = let
      patchedMicrovm = inputs.nixpkgs.legacyPackages.aarch64-linux.applyPatches {
        name = "microvm-rootless";
        src = inputs.microvm;
        patches = [
          ./microvm-virtiofsd-rootless.patch
        ];
      };
    in {
      disabledModules = [
        "${inputs.microvm}/nixos-modules/microvm/virtiofsd"
      ];

      imports = [
        "${patchedMicrovm}/nixos-modules/microvm/virtiofsd"
      ];
    };
  };
}
