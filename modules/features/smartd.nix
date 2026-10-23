{
  den.aspects.smartd = {devices}: {
    # Thank's Hopper for the suggestion
    nixos = {
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
          devices;

        notifications = {
          wall.enable = true;
          systembus-notify.enable = true;
          # test = true; # Uncomment to validate the service
        };
      };
    };
  };
}
