{inputs, ...}: {
  den.aspects.agenix.nixos = {
    config,
    lib,
    pkgs,
    ...
  }: let
    mkSecrets = path: group:
      lib.pipe (builtins.readDir "${inputs.secrets}/${path}") [
        (lib.filterAttrs (
          file: type:
            type == "regular" && lib.hasSuffix ".age" file
        ))
        (lib.mapAttrs' (file: _: {
          name = "${lib.optionalString (path != "." && path != "nmconnection") "${path}/"}${lib.removeSuffix ".age" file}";
          value = {
            file = "${inputs.secrets}/${path}/${file}";
            group = lib.mkDefault group;
            mode = lib.mkDefault "0440";
          };
        }))
      ];
  in {
    age = {
      identityPaths = ["/nix/persistent/secrets/ident.txt"];
      secretsMountPoint = "/run/agenix.d";
    };

    environment.systemPackages = [
      inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];

    systemd.tmpfiles.rules = [
      "d /nix/persistent/secrets 0700 root root - -"
      "d /nix/persistent/secrets/age 0700 root root - -"
      "d /nix/persistent/secrets/age/nmconnection 0700 root root - -"
      "d /nix/persistent/secrets/age/gitlab 0700 root root - -"
      "z /nix/persistent/secrets/ident.txt 0400 root root - -"
    ];

    age.secrets =
      mkSecrets "." "root"
      // mkSecrets "nmconnection" "root"
      // mkSecrets "gitlab" "gitlab"
      // {
        btrbk_dreamland_ed25519_key = {
          file = "${inputs.secrets}/btrbk_dreamland_ed25519_key.age";
          owner = "btrbk";
          group = "btrbk";
          mode = "0400";
        };
        ssh_dreamland_ed25519_key = {
          file = "${inputs.secrets}/ssh_dreamland_ed25519_key.age";
          owner = "root";
          group = "root";
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
}
