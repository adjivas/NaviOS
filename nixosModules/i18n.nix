{ lib, config, ... }: {
  options = {
    i18n.enable = lib.mkEnableOption "enable i18n";
  };
  config = lib.mkIf config.i18n.enable {
    # Mandatory
    i18n = {
      defaultLocale = "en_US.UTF-8";

      # Optionally (BEWARE: requires a different format with the added /UTF-8)
      extraLocales = ["fr_FR.UTF-8/UTF-8"];

      # Optionally
      extraLocaleSettings = {
        LC_CTYPE = "en_US.UTF8";
        LC_ADDRESS = "fr_FR.UTF-8";
        LC_MEASUREMENT = "fr_FR.UTF-8";
        LC_MESSAGES = "en_US.UTF-8";
        LC_MONETARY = "fr_FR.UTF-8";
        LC_NAME = "fr_FR.UTF-8";
        LC_NUMERIC = "en_US.UTF-8";
        LC_PAPER = "fr_FR.UTF-8";
        LC_TELEPHONE = "fr_FR.UTF-8";
        LC_TIME = "fr_FR.UTF-8";
        LC_COLLATE = "fr_FR.UTF-8";
      };
    };
  };
}
