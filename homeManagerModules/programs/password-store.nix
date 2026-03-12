{ lib, pkgs, config, ... }: {
  options = {
    password-store.enable = lib.mkEnableOption "enable passage";
  };
  config = lib.mkIf config.password-store.enable {
    programs.password-store = {
      enable = true;
      package = pkgs.passage;

      settings = {
        # Passage specific
        PASSAGE_DIR = "${config.xdg.configHome}/passage/store/";
        PASSAGE_IDENTITIES_FILE = "${config.xdg.configHome}/passage/identities";
      };
    };
  };
}
