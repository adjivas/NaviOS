{
  den.aspects.smartd.nixos = {
    config,
    lib,
    ...
  }: {
    options.smartd = {
      devices = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = ["/dev/nvme0"];
        description = "List of block devices monitored by smartd.";
        example = [
          "/dev/nvme0"
          "/dev/nvme1"
          "/dev/sda"
        ];
      };
    };

    config = {
      # Thank's Hopper for the suggestion
      services.smartd = {
        enable = true;

        autodetect = false;
        devices =
          map (device: {
            inherit device;
            # Check the overall health status, monitor SMART data,
            # run a short test every day at 02:00,
            # and a long test on the first Sunday of each month at 03:00.
            options = "-H -a -s (S/../.././02|L/../01/7/03)";
          })
          config.smartd.devices;

        notifications = {
          wall.enable = true;
          systembus-notify.enable = true;
          # test = true; # Uncomment to validate the service
        };
      };
    };
  };
}
