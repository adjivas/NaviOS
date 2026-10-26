{
  den.aspects.virtualisation.homeManager = {
    config = {
      dconf.settings = {
        "org/virt-manager/virt-manager" = {
          "xmleditor-enabled" = true;
        };
        "org/virt-manager/virt-manager/connections" = {
          "autoconnect" = ["qemu:///system"];
          "uris" = ["qemu:///system"];
        };
        "org/virt-manager/virt-manager/confirm" = {
          "delete-storage" = false;
          "forcepoweroff" = false;
        };
      };
    };
  };
}
