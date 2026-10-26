{
  den,
  lib,
  ...
}: {
  den.aspects.waydroid = {cameraPassthrough ? false, ...}: {
    includes =
      lib.optional cameraPassthrough
      den.aspects.waydroid-camera-passthrough;

    nixos = {
      # Enable Waydroid.
      virtualisation.waydroid.enable = true;
    };
  };
}
