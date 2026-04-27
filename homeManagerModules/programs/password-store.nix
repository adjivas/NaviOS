{ lib, pkgs, config, ... }: {
  options = {
    password-store.enable = lib.mkEnableOption "enable passage";
  };
  config = lib.mkIf config.password-store.enable {
    programs.password-store = {
      enable = true;
      package = pkgs.passage;
      settings = {
        PASSAGE_DIR = "${config.home.homeDirectory}/.secrets/age/passage/";
        PASSAGE_IDENTITIES_FILE = "${config.home.homeDirectory}/.secrets/ident.txt";
      };
    };
  };
}
