{ self, hostname, lib, pkgs, inputs, ... }:  {
  home-manager.backupFileExtension = "backup2";

  home-manager.sharedModules = [
    inputs.stylix.homeModules.stylix
    inputs.agenix.homeManagerModules.default
    inputs.lan-mouse.homeManagerModules.default
  ];

  home-manager.extraSpecialArgs = {
    nvf = inputs.nvf.homeManagerModules.default;
    adwaita-cursors-multicolors = inputs.adwaita-cursors-multicolors.packages.${pkgs.stdenv.hostPlatform.system}.default;
    firefox-addons = inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system};
    buildFirefoxXpiAddon = inputs.firefox-addons.lib.${pkgs.stdenv.hostPlatform.system}.buildFirefoxXpiAddon;
    telegram-desktop = inputs.telegram-desktop-patched.packages.${pkgs.stdenv.hostPlatform.system}.default;
    luanti = inputs.nix-luanti.overlays.default;
    fenix = inputs.fenix.packages.${pkgs.stdenv.hostPlatform.system};
    gnome-contacts-vcard-importer = inputs.gnome-contacts-vcard-importer.packages.${pkgs.stdenv.hostPlatform.system}.default;
    secretsUser = inputs.secretsHomeAdjivas;
  };

  home-manager.useUserPackages = true;

  imports = [
    ./adjivas
    ./kad
  ];
}
