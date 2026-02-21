{ pkgs, lib, config, ... }: {
  options = {
    virt-manager.enable = lib.mkEnableOption "enable virt-manager";
  };
  config = lib.mkIf config.virt-manager.enable {
    dconf.settings = {
      "org/virt-manager/virt-manager" = {
        "xmleditor-enabled" = true;
      };
      "org/virt-manager/virt-manager/connections" = {
        "autoconnect" = [ "qemu:///system" ];
        "uris" = [ "qemu:///system" ];
      };
      "org/virt-manager/virt-manager/confirm" = {
        "delete-storage" = false;
        "forcepoweroff" = false;
      };
    };
  };
}
