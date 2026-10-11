{inputs, ...}: {
  den.batteries.agenix-dir = {
    name = "agenix-dir";

    nixos = {lib, ...}: let
      secrets = inputs.secrets;
    in {
      _module.args.mkAgeSecretDir = {
        path,
        group ? "root",
        mode ? "0400",
        prefix ? path,
      }:
        lib.pipe (builtins.readDir "${secrets}/${path}") [
          (lib.filterAttrs (
            file: type:
              type
              == "regular"
              && lib.hasSuffix ".age" file
          ))

          (lib.mapAttrs' (
            file: _:
              lib.nameValuePair
              "${lib.optionalString (prefix != "." && prefix != "") "${prefix}/"}${lib.removeSuffix ".age" file}"
              {
                file = "${secrets}/${path}/${file}";
                group = lib.mkDefault group;
                mode = lib.mkDefault mode;
              }
          ))
        ];
    };

    homeManager = {lib, ...}: let
      secretsHomeLand = inputs.secretsHomeLand;
    in {
      _module.args.mkAgeSecretDir = {
        sourceDir,
        targetDir,
        secretPrefix ? sourceDir,
        mode ? "0400",
      }:
        lib.pipe (builtins.readDir "${secretsHomeLand}/${sourceDir}") [
          (lib.filterAttrs (
            file: type:
              type
              == "regular"
              && lib.hasSuffix ".age" file
          ))

          (lib.mapAttrs' (
            file: _type: let
              targetName = lib.removeSuffix ".age" file;
            in
              lib.nameValuePair "${secretPrefix}/${targetName}" {
                file = "${secretsHomeLand}/${sourceDir}/${file}";
                path = "${targetDir}/${targetName}";
                inherit mode;
              }
          ))
        ];
    };
  };
}
