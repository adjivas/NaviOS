{ pkgs, telegram-desktop, lib, config, ... }: {
  options = {
    telegram.enable = lib.mkEnableOption "enable telegram";
  };
  config = lib.mkIf config.telegram.enable {
    home.packages = [
      telegram-desktop
    ];

    home.file.".local/share/TelegramDesktop/tdata/shortcuts-custom.json".text = builtins.toJSON [
      {
        "command" = "account1";
        "keys" = "ctrl+[";
      }
      {
        "command" = "account2";
        "keys" = "ctrl+]";
      }
      {
        "command" = "next_chat";
        "keys" = "ctrl+j";
      }
      {
        "command" = "previous_chat";
        "keys" = "ctrl+k";
      }
    ];
  };
}
