{
  inputs,
  den,
  ...
}: {
  den.aspects.agenix = {
    includes = [
      den.batteries.agenix-dir
    ];

    nixos = {
      config,
      lib,
      pkgs,
      mkAgeSecretDir,
      ...
    }: {
      imports = [
        inputs.agenix.nixosModules.default
      ];

      age = {
        identityPaths = [
          "/nix/persistent/secrets/ident.txt"
        ];

        secretsMountPoint = "/run/agenix.d";
      };

      environment.systemPackages = [
        inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];

      systemd.tmpfiles.rules = [
        "d /nix/persistent/secrets 0700 root root - -"
        "d /nix/persistent/secrets/age 0700 root root - -"
        "d /nix/persistent/secrets/age/nmconnection 0700 root root - -"
        # "d /nix/persistent/secrets/age/gitlab 0700 root root - -"
        "z /nix/persistent/secrets/ident.txt 0400 root root - -"
      ];

      age.secrets =
        (mkAgeSecretDir {
          path = ".";
          group = "root";
          mode = "0440";
          prefix = "";
        })
        // (mkAgeSecretDir {
          path = "nmconnection";
          group = "root";
          mode = "0400";
          prefix = "";
        })
        # // (mkAgeSecretDir {
        #   path = "gitlab";
        #   group = "gitlab";
        #   mode = "0440";
        # })
        // {
          # btrbk_dreamland_ed25519_key = {
          #   file = "${inputs.secrets}/btrbk_dreamland_ed25519_key.age";
          #   owner = "btrbk";
          #   group = "btrbk";
          #   mode = "0400";
          # };

          ssh_dreamland_ed25519_key = {
            file = "${inputs.secrets}/ssh_dreamland_ed25519_key.age";
            owner = "root";
            group = "root";
            mode = "0400";
          };
          dreamland-nix-builder = {
            file = "${inputs.secrets}/dreamland-nix-builder.age";
            owner = "adjivas";
            group = "users";
            mode = "0400";
          };
        };

      environment.etc = builtins.listToAttrs (
        map (name: {
          name = "NetworkManager/system-connections/${name}";
          value.source = config.age.secrets.${name}.path;
        }) (
          builtins.attrNames (
            lib.filterAttrs
            (name: _: lib.hasSuffix ".nmconnection" name)
            config.age.secrets
          )
        )
      );
    };
  };
}
