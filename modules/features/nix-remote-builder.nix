{den, ...}: {
  den.aspects.nix-remote-builder.nixos = {
    config,
    lib,
    ...
  }: {
    options.nix-remote-builder = {
      sshKey = lib.mkOption {
        type = lib.types.path;
        description = "SSH private key used by Nix remote builders.";
      };
      localBuilds = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether local Nix builds are allowed.";
      };
    };

    config.nix = {
      distributedBuilds = true;
      settings = {
        builders-use-substitutes = true;
        max-jobs =
          if config.nix-remote-builder.localBuilds
          then "auto"
          else 0;
      };
    };
  };

  den.batteries.nix-remote-builder = {
    hostName,
    port ? 22,
    systems,
    sshUser ? "nix-builder",
    publicHostKey,
    protocol ? "ssh-ng",
    maxJobs ? 1,
    speedFactor ? 1,
    supportedFeatures ? ["big-parallel"],
  }: {
    includes = [
      den.aspects.nix-remote-builder
    ];

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

          sshKey = config.nix-remote-builder.sshKey;
        }
      ];
    };
  };
}
