{
  den.batteries.runnable-microvm = {
    name,
    workingDirectory,
    runner ? "${workingDirectory}/result",
    bridge ? "br0",
    tapName ? "tap-${name}",
    multiQueue ? false,
    stateDirectories ? [],
  }: {user, ...}: let
    machineId = builtins.substring 0 32 (builtins.hashString "sha256" name);
  in {
    nixos = {
      pkgs,
      lib,
      ...
    }: {
      systemd.tmpfiles.rules = [
        "L+ /var/log/journal/${machineId} - - - - /var/lib/microvms/${name}/journal/${machineId}"
      ];

      systemd.services."microvm-${name}-virtiofsd" = {
        description = "VirtioFS daemons for MicroVM ${name}";

        before = [
          "microvm-${name}.service"
        ];

        partOf = [
          "microvm-${name}.service"
        ];

        serviceConfig = {
          Type = "notify";
          NotifyAccess = "all";

          User = user.userName;

          RuntimeDirectory = "microvm-${name}";
          RuntimeDirectoryMode = "0700";

          WorkingDirectory = workingDirectory;
          ExecStart = "${runner}/bin/virtiofsd-run";

          StateDirectory = ["microvms/${name}/journal"] ++ map (dir: "microvms/${name}/${dir}") stateDirectories;
          StateDirectoryMode = "0755";

          LimitNOFILE = 1048576;
          KillMode = "mixed";

          Restart = "always";
          RestartSec = 5;
        };
      };

      systemd.services."microvm-${name}" = {
        description = "MicroVM ${name}";

        wantedBy = ["multi-user.target"];

        wants = ["network-online.target"];

        requires = [
          "microvm-${name}-virtiofsd.service"
        ];

        after = [
          "network-online.target"
          "microvm-${name}-virtiofsd.service"
        ];

        serviceConfig = {
          Type = "simple";

          User = user.userName;
          WorkingDirectory = workingDirectory;

          ExecStartPre = [
            "+${lib.getExe' pkgs.iproute2 "ip"} tuntap add dev ${tapName} mode tap user ${user.userName} ${lib.optionalString multiQueue "multi_queue"}"
            "+${lib.getExe' pkgs.iproute2 "ip"} link set ${tapName} master ${bridge}"
            "+${lib.getExe' pkgs.iproute2 "ip"} link set ${tapName} up"
          ];

          ExecStart = "${runner}/bin/microvm-run";
          ExecStop = "${runner}/bin/microvm-shutdown";

          ExecStopPost = [
            "+${lib.getExe' pkgs.iproute2 "ip"} link delete ${tapName}"
          ];

          TimeoutStopSec = 30;
          KillMode = "mixed";

          Restart = "always";
          RestartSec = 5;
        };
      };
    };
  };
}
