{ lib, config, pkgs, ... }: {
  options = {
    gnome-control-center.enable = lib.mkEnableOption "enable gnome-control-center";
    gnome-control-center.user = lib.mkOption {
      type = lib.types.str;
    };
  };
  config = lib.mkIf config.gnome-control-center.enable {
    home.packages = with pkgs; [
      gnome-control-center
      gnome-online-accounts
    ];

    xdg.desktopEntries.gnome-control-center = {
      name = "GNOME Control Center";
      genericName = "Settings";
      comment = "Configure the system";
      exec = "env XDG_CURRENT_DESKTOP=GNOME ${pkgs.gnome-control-center}/bin/gnome-control-center";
      terminal = false;
      categories = [ "Settings" "GNOME" ];
    };

    # home-manager.users = {
    #   name = config.gnome-control-center.user;
    #   value = {
    #     xdg.desktopEntries.gnome-control-center = {
    #       name = "Gnome Control Center";
    #       exec = "env XDG_CURRENT_DESKTOP=GNOME ${pkgs.gnome-control-center}/bin/gnome-control-center";
    #     };
    #   };
    # };
  };
}
