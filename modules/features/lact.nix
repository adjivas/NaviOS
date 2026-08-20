{
  den.aspects.lact.nixos = {pkgs, ...}: {
    config = {
      environment.systemPackages = [pkgs.lact];

      systemd.services.lactd = {
        enable = true;
        description = "LACT AMDGPU daemon";

        # restartIfChanged = false;
        # stopIfChanged = false;

        serviceConfig = {
          ExecStartPre = "${pkgs.coreutils}/bin/rm -f /run/lactd.sock";
          ExecStart = "${pkgs.lact}/bin/lact daemon";
          # Restart = "no";
        };

        wantedBy = ["multi-user.target"];
      };

      systemd.tmpfiles.rules = [
        "d /var/lib/lact 0755 root root -"
        "C /var/lib/lact/config.yaml 0644 root root - ${pkgs.writeText "lact-config.yaml" ''
          daemon:
            log_level: warn
            admin_groups:
              - wheel
            admin_users:
              - adjivas
            tcp_listen_address: 127.0.0.1:12853
        ''}"

        "d /etc/lact 0755 root root -"
        "L+ /etc/lact/config.yaml - - - - /var/lib/lact/config.yaml"
        "L+ /usr/share/hwdata/pci.ids - - - - ${pkgs.hwdata}/share/hwdata/pci.ids"
      ];
    };
  };
}
