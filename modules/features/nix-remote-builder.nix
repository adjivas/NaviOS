{
  den.batteries.nix-remote-builder = {
    hostName,
    key,
    port ? 22,
    systems,
    sshUser ? "nix-builder",
    publicHostKey,
    protocol ? "ssh-ng",
    maxJobs ? 1,
    speedFactor ? 1,
    supportedFeatures ? ["big-parallel"],
  }: {
    nixos = {
      config,
      lib,
      ...
    }: {
      nix.buildMachines = lib.mkAfter [
        {
          hostName = "${hostName}:${toString port}";

          inherit
            systems
            sshUser
            protocol
            maxJobs
            speedFactor
            supportedFeatures
            publicHostKey
            ;

          sshKey = key config;
        }
      ];
    };
  };
}
