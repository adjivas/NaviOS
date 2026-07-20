{inputs, ...}: {
  den.aspects.agenix.nixos = {
    config,
    lib,
    ...
  }: {
    age = {
      identityPaths = ["/nix/persistent/secrets/ident.txt"];
      secretsMountPoint = "/run/agenix.d";
    };

    environment.systemPackages = [
      inputs.agenix.packages.x86_64-linux.default
    ];

    systemd.tmpfiles.rules = [
      "d /nix/persistent/secrets 0700 root root - -"
      "d /nix/persistent/secrets/age/nmconnection 0700 root root - -"
      "z /nix/persistent/secrets/ident.txt 0400 root root - -"
    ];

    age.secrets = let
      secretsDirStore = inputs.secrets;

      mkAgeSecrets = dir: _prefix: let
        allEntries = builtins.attrNames (builtins.readDir dir);
        ageFiles = builtins.filter (f: lib.hasSuffix ".age" f) allEntries;
      in
        map (
          file: let
            key = lib.toLower (lib.removeSuffix ".age" file);
          in
            lib.nameValuePair key {
              file = "${dir}/${file}";
            }
        )
        ageFiles;

      topSecrets = mkAgeSecrets secretsDirStore "";
      nmSecrets = mkAgeSecrets "${secretsDirStore}/nmconnection" "";

      baseSecrets = builtins.listToAttrs (topSecrets ++ nmSecrets);
    in
      baseSecrets
      // {
        btrbk_dreamland_ed25519_key =
          baseSecrets.btrbk_dreamland_ed25519_key
          // {
            owner = "btrbk";
            group = "btrbk";
            mode = "0400";
          };
      };

    environment.etc = let
      nms = builtins.attrNames (
        lib.filterAttrs
        (name: _: lib.hasSuffix ".nmconnection" name)
        config.age.secrets
      );
    in
      builtins.listToAttrs (map (name: {
          name = "NetworkManager/system-connections/${name}";
          value = {
            source = config.age.secrets."${name}".path;
          };
        })
        nms);
  };
}
