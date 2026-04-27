{ config, lib, inputs, ... }: {
  age = {
    identityPaths = [ "/nix/persistent/secrets/ident.txt" ];
    secretsMountPoint = "/run/agenix.d";
  };

  systemd.tmpfiles.rules = [
    "d /nix/persistent/secrets 0700 root root - -"
    "z /nix/persistent/secrets/ident.txt 0400 root root - -"
  ];

  age.secrets = let
    secretsDirStore = inputs.secrets;
    allEntries = builtins.attrNames (builtins.readDir secretsDirStore);
    ageFiles = builtins.filter (f: lib.hasSuffix ".age" f) allEntries;
  in builtins.listToAttrs (map (file:
    let
      key = lib.toLower (lib.removeSuffix ".age" file);
    in lib.nameValuePair key {
      file = "${secretsDirStore}/${file}";
    }
  ) ageFiles);

  environment.etc = let nms = (builtins.attrNames (lib.filterAttrs
    (name: _: lib.hasSuffix ".nmconnection" name)
    config.age.secrets
  )); in builtins.listToAttrs (map (name: {
    name = "NetworkManager/system-connections/${name}.age";
    value = {
      source = config.age.secrets."${name}".path;
    };
  }) nms);
}
