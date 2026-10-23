{
  den.aspects.dream05-qbootctl.nixos = {pkgs, ...}: {
    environment.systemPackages = [pkgs.qbootctl];

    systemd.services.qbootctl-mark-boot-successful = {
      description = "Mark current A/B slot as successfully booted";
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.qbootctl}/bin/qbootctl -m";
      };
    };
  };
}
