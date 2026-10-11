{
  den.aspects.dream05-v4l2loopback.nixos = {
    config,
    pkgs,
    ...
  }: {
    boot.extraModulePackages = with config.boot.kernelPackages; [
      v4l2loopback
    ];

    boot.kernelModules = [
      "v4l2loopback"
    ];

    boot.extraModprobeConfig = ''
      options v4l2loopback \
        devices=1 \
        video_nr=30 \
        card_label="FP5 Camera" \
        exclusive_caps=1 \
        max_buffers=4
    '';

    environment.systemPackages = with pkgs; [
      v4l-utils
    ];
  };
}
