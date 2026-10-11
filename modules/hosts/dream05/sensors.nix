# NixOS module for sensor support on Fairphone 5.
#
# The sensors are exposed by the ADSP Sensor Subsystem Controller through
# `libssc` and the FastRPC device, rather than as kernel-visible IIO devices.
{den, ...}: {
  den.aspects.dream05-sensors = {
    includes = [
      den.aspects.dream05-audio
    ];

    nixos = {
      # Run `iio-sensor-proxy` with its stock SSC backend.
      hardware.sensor.iio.enable = true;

      # If the proxy starts before the ADSP has registered its sensor service, it
      # exits successfully without exposing sensors. Retry until discovery works.
      systemd.services.iio-sensor-proxy = {
        after = ["hexagonrpcd-adsp-sensorspd.service"];
        unitConfig.StartLimitIntervalSec = 0;

        serviceConfig = {
          Restart = "always";
          RestartSec = "5";
        };
      };

      # Enable the SSC accelerometer and proximity backends and transform the
      # accelerometer readings into the Fairphone 5 display coordinate system.
      services.udev.extraRules = ''
        SUBSYSTEM=="misc", KERNEL=="fastrpc-adsp*", ENV{IIO_SENSOR_PROXY_TYPE}+="ssc-accel ssc-proximity"
        SUBSYSTEM=="misc", KERNEL=="fastrpc-*", ENV{ACCEL_MOUNT_MATRIX}+="-1, 0, 0; 0, -1, 0; 0, 0, -1"
      '';
    };
  };
}
