{ lib, config, pkgs, ... }:  {
  options = {
    libreoffice.enable = lib.mkEnableOption "enable libreoffice";
  };
  config = lib.mkIf config.libreoffice.enable (let
    libreofficeWrapped = pkgs.writeShellScriptBin "libreoffice" ''exec ${pkgs.libreoffice-still}/bin/libreoffice --nologo "$@"'';
  in {
    home.packages = [
      libreofficeWrapped
      pkgs.hunspellDicts.fr-any
    ];
  });
}
