{
  den.aspects.feedbackd.nixos = {pkgs, ...}: {
    environment.systemPackages = [
      pkgs.feedbackd
    ];

    services.dbus.packages = [
      pkgs.feedbackd
    ];

    systemd.packages = [
      pkgs.feedbackd
    ];
  };
}
