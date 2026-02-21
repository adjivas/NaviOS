{ lib, config, ... }: {
  options = {
    greetd.enable = lib.mkEnableOption "enable greetd";
    greetd.user = lib.mkOption {
      type = lib.types.str;
    };
    greetd.command = lib.mkOption {
      type = lib.types.str;
    };
  };
  config = lib.mkIf config.greetd.enable {
    services.greetd = {
      enable = true;
      settings = rec {
        initial_session = {
          command = config.greetd.command;
          # command = "${pkgs.sway}/bin/sway";
          # command = "${pkgs.dbus}/bin/dbus-run-session ${pkgs.sway}/bin/sway";
          # command = "${pkgs.dbus}/bin/dbus-run-session ${pkgs.systemd}/bin/systemctl --user start sway-session.target";

          user = config.greetd.user;
        };
        default_session = initial_session;

        terminals = [
          { vt = 1; }
        ];

        seats = [
          { name = "seat0"; tty = "tty1"; }
        ];
      };
    };
  };
}
