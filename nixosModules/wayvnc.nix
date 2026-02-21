{ pkgs, lib, config, ... }: {
  options = {
    wayvnc.enable = lib.mkEnableOption "enable wayvnc";
    wayvnc.config = lib.mkOption {
      type = lib.types.path;
      default = pkgs.writeText "wayvnc-config" ''
        use_relative_paths=true
        address=0.0.0.0
      '';
    };
    wayvnc.max-fps = lib.mkOption {
      type = lib.types.int;
      default = 60;
    };
  };
  config = lib.mkIf config.wayvnc.enable {
    systemd.user.services.wayvnc = {
      description = "wayvnc server";
      wantedBy = [ "default.target" ];
      after = [ "default.target" ];

      environment = {
        WAYLAND_DISPLAY = "wayland-0";
      };

      serviceConfig = {
        Type = "simple";
        ExecStart = ''
          ${pkgs.wayvnc}/bin/wayvnc --config ${config.wayvnc.config} --render-cursor --max-fps=${toString config.wayvnc.max-fps}
        '';
        Restart = "always";
        RestartSec = "5s";
      };
    };
  };
}
