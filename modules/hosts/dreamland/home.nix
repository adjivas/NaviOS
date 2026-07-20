{inputs, ...}: {
  den.aspects.home-land.nixos = {pkgs, ...}: {
    home-manager = {
      verbose = true;
      useUserPackages = true;
      useGlobalPkgs = true;
      backupFileExtension = "backup";
      backupCommand = "rm";
      overwriteBackup = true;

      sharedModules = [
        inputs.nvf.homeManagerModules.default
        inputs.agenix.homeManagerModules.default
        inputs.lan-mouse.homeManagerModules.default
      ];

      extraSpecialArgs = {
        moonlight-web-stream = inputs.moonlight-web-stream.packages.${pkgs.stdenv.hostPlatform.system}.default;
        firefox-addons = inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system};
        buildFirefoxXpiAddon = inputs.firefox-addons.lib.${pkgs.stdenv.hostPlatform.system}.buildFirefoxXpiAddon;
        fenix = inputs.fenix.packages.${pkgs.stdenv.hostPlatform.system};
        wrappers = inputs.wrappers.lib.wrapPackage;
        gnome-contacts-vcard-importer = inputs.gnome-contacts-vcard-importer.packages.${pkgs.stdenv.hostPlatform.system}.default;
        nix-log-check = inputs.nix-log-check.packages.${pkgs.stdenv.hostPlatform.system}.default;
        munix = inputs.munix.packages.${pkgs.stdenv.hostPlatform.system}.munix;
        tincr = inputs.tincr.packages.${pkgs.stdenv.hostPlatform.system}.tincd;
        secretsHomeLand = inputs.secretsHomeLand;
      };
    };
  };
}
