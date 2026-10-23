{den, ...}: {
  den.aspects.dream05-camera = {
    includes = [
      den.aspects.dream05-v4l2loopback
    ];

    nixos = {
      lib,
      pkgs,
      user,
      ...
    }: let
      libcamera = pkgs.libcamera;

      camera-stream = pkgs.writeShellScriptBin "camera-stream" ''
        export GST_PLUGIN_SYSTEM_PATH_1_0=${lib.escapeShellArg (
          lib.makeSearchPath "lib/gstreamer-1.0" [
            (lib.getLib pkgs.gst_all_1.gstreamer)
            libcamera
            pkgs.gst_all_1.gst-plugins-base
            pkgs.gst_all_1.gst-plugins-good
            pkgs.gst_all_1.gst-plugins-bad
          ]
        )}

        exec ${lib.getExe' pkgs.gst_all_1.gstreamer "gst-launch-1.0"} -q \
          libcamerasrc camera-name="/base/soc@0/cci@ac4a000/i2c-bus@1/camera@29" \
          ! "video/x-raw,width=640,height=480,framerate=30/1" \
          ! videoconvert \
          ! "video/x-raw,format=I420,width=640,height=480,framerate=30/1" \
          ! jpegenc \
          ! jpegparse \
          ! fdsink fd=1
      '';

      camera-share = pkgs.writeShellScriptBin "camera-share" ''
        set -o pipefail

        ${camera-stream}/bin/camera-stream \
          | exec ${pkgs.ffmpeg}/bin/ffmpeg \
          -hide_banner \
          -loglevel warning \
          -f mjpeg \
          -framerate 30 \
          -i pipe:0 \
          -c:v copy \
          -f v4l2 \
          /dev/video30
      '';
    in {
      security.polkit.extraConfig = ''
        polkit.addRule(function(action, subject) {
          if (
            subject.user == "${user.userName}" &&
            action.id == "org.freedesktop.systemd1.manage-units" &&
            action.lookup("unit") == "waydroid-container.service" &&
            action.lookup("verb") == "restart"
          ) {
            return polkit.Result.YES;
          }
        });
      '';

      systemd.user.services.camera-share = {
        description = "Share camera through v4l2loopback";

        serviceConfig = {
          Type = "simple";
          Restart = "on-failure";

          ExecStart = "${camera-share}/bin/camera-share";
          ExecStartPost = "${pkgs.systemd}/bin/systemctl restart waydroid-container.service";
        };
      };

      environment.systemPackages = [
        camera-stream
        camera-share
      ];
    };
  };
}
