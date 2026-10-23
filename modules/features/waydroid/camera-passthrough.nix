{
  den.aspects.waydroid-camera-passthrough.nixos = {pkgs, ...}: let
    cameraConfig = ./external_camera_config.xml;
    waydroidConfig = "/var/lib/waydroid/lxc/waydroid/config";
  in {
    systemd.services.waydroid-camera-config = {
      description = "Configure Waydroid camera passthrough";

      wantedBy = [
        "waydroid-container.service"
      ];

      before = [
        "waydroid-container.service"
      ];

      unitConfig.ConditionPathExists = waydroidConfig;

      path = with pkgs; [
        gnused
        gnugrep
      ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };

      script = ''
        set -euo pipefail

        camera_config_mount="lxc.mount.entry = ${cameraConfig} vendor/etc/external_camera_config.xml none bind,ro,create=file"

         sed -i \
           -e '/^lxc\.cgroup2\.devices\.allow = c .* rwm$/d' \
           -e '\|^lxc\.mount\.entry = /dev/video30 dev/video30 none bind,optional,create=file$|d' \
           -e '\|^lxc\.mount\.entry = .*external_camera_config\.xml vendor/etc/external_camera_config\.xml none bind,ro,create=file$|d' \
           ${waydroidConfig}

        echo "$camera_config_mount" >> ${waydroidConfig}
      '';
    };
  };
}
