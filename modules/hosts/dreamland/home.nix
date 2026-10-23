{inputs, ...}: {
  den.aspects.home-land.nixos = {
    imports = [
      inputs.home-manager.nixosModules.home-manager
    ];
    home-manager = {
      verbose = true;
      useUserPackages = true;
      useGlobalPkgs = true;
      backupFileExtension = "backup";
      backupCommand = "rm";
      overwriteBackup = true;

      extraSpecialArgs = {
        wrappers = inputs.wrappers.lib.wrapPackage;
      };
    };
  };
}
