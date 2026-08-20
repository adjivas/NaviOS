{
  den.aspects.agenix-kad.homeManager = {
    secretsHomeLand,
    lib,
    ...
  }: let
    hostname = "kad";
    homeDir = "/home/${hostname}";
  in {
    # systemctl --user status agenix
    age = {
      identityPaths = ["/home/kad/.secrets/ident.txt"];

      secretsDir = "/home/kad/.agenix/agenix";
      secretsMountPoint = "/home/kad/.agenix/agenix.d";
    };

    home.activation.installAge = lib.hm.dag.entryAfter ["writeBoundary"] ''
      mkdir -p "${homeDir}/.secrets"
      chmod 0700 "${homeDir}/.secrets"
      chmod 0400 "${homeDir}/.secrets/ident.txt"
    '';

    age.secrets = let
      secretsDirStore = secretsHomeLand;
      allEntries = builtins.attrNames (builtins.readDir "${secretsDirStore}/fonts/");
      ageFiles = builtins.filter (f: lib.hasSuffix ".age" f) allEntries;
      fontSecrets = builtins.listToAttrs (
        map (
          file: let
            targetName = lib.removeSuffix ".age" file;
          in
            lib.nameValuePair "fonts/${targetName}" {
              file = "${secretsDirStore}/fonts/${file}";
              path = "${homeDir}/.local/share/fonts/${targetName}";
              mode = "0400";
            }
        )
        ageFiles
      );
    in
      {
        lanmouse_fingerprints = {
          file = "${homeDir}/.secrets/age/lanmouse/fingerprints.txt.age";
          mode = "0600";
        };
        lanmouse_pem = {
          file = "${homeDir}/.secrets/age/lanmouse/pem.age";
          path = "${homeDir}/.config/lan-mouse/lan-mouse.pem";
        };
      }
      // fontSecrets;
  };
}
