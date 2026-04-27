{ lib, pkgs, config, ... }: {
  options = {
    lact.enable = lib.mkEnableOption "enable lact";
  };
  config = lib.mkIf config.lact.enable {
    environment.etc."lact/config.yaml".text = ''
      daemon:
        log_level: warn
        admin_groups:
          - wheel
        admin_users:
          - adjivas
        tcp_listen_address: 127.0.0.1:12853
    '';
    
    environment.systemPackages = [ pkgs.lact ];

    systemd.services.lactd = {
      enable = true;
      description = "Amdgpu";
      serviceConfig.ExecStart = "${pkgs.lact}/bin/lact daemon";
      wantedBy = [ "multi-user.target" ];
    };

    systemd.tmpfiles.rules = [
      "L+ /usr/share/hwdata/pci.ids - - - - ${pkgs.hwdata}/share/hwdata/pci.ids"
    ];
  };
}
