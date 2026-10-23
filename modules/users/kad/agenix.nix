{
  inputs,
  den,
  ...
}: {
  den.aspects.agenix-kad = {
    includes = [
      den.batteries.agenix-dir
    ];

    homeManager = {
      mkAgeSecretDir,
      config,
      lib,
      ...
    }: let
      homeDir = config.home.homeDirectory;
    in {
      imports = [
        inputs.agenix.homeManagerModules.default
      ];
      # systemctl --user status agenix
      age = {
        identityPaths = ["${homeDir}/.secrets/ident.txt"];

        secretsDir = "${homeDir}/.agenix/agenix";
        secretsMountPoint = "${homeDir}/.agenix/agenix.d";
      };

      home.activation.installAge = lib.hm.dag.entryAfter ["writeBoundary"] ''
        mkdir -p "${homeDir}/.secrets"
        chmod 0700 "${homeDir}/.secrets"
        chmod 0400 "${homeDir}/.secrets/ident.txt"
      '';

      age.secrets =
        (mkAgeSecretDir {
          sourceDir = "fonts";
          targetDir = "${homeDir}/.local/share/fonts";
        })
        // {
          lanmouse_fingerprints = {
            file = "${homeDir}/.secrets/age/lanmouse/fingerprints.txt.age";
            mode = "0600";
          };

          lanmouse_pem = {
            file = "${homeDir}/.secrets/age/lanmouse/pem.age";
            path = "${homeDir}/.config/lan-mouse/lan-mouse.pem";
          };
        };
    };
  };
}
