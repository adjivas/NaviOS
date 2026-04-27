{ config, lib, secretsUser, ... }: {
  # systemctl --user status agenix
  age = {
    identityPaths = [ "${config.home.homeDirectory}/.secrets/ident.txt" ];
    
    secretsDir = "${config.home.homeDirectory}/.agenix/agenix";
    secretsMountPoint = "${config.home.homeDirectory}/.agenix/agenix.d";
  };

  home.activation.installAge = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "${config.home.homeDirectory}/.secrets"
    chmod 0700 "${config.home.homeDirectory}/.secrets"
    chmod 0400 "${config.home.homeDirectory}/.secrets/ident.txt"
  '';

  age.secrets = let
    secretsDirStore = secretsUser;
    allEntries = builtins.attrNames (builtins.readDir "${secretsDirStore}/fonts/");
    ageFiles = builtins.filter (f: lib.hasSuffix ".age" f) allEntries;
    fontSecrets = builtins.listToAttrs (
      map (file:
        let
          targetName = lib.removeSuffix ".age" file;
        in
        lib.nameValuePair "fonts/${targetName}" {
          file = "${secretsDirStore}/fonts/${file}";
          path = "${config.home.homeDirectory}/.local/share/fonts/${targetName}";
          mode = "0400";
        }
      ) ageFiles
    );
  in {
    "contacts.vcf" = {
      file = "${config.home.homeDirectory}/.secrets/age/contacts.vcf.age";
      mode = "0400";
    };
    switch_prod = {
      file = "${config.home.homeDirectory}/.secrets/age/switch-prod.keys.age";
      path = "${config.home.homeDirectory}/.switch/prod.keys";
      mode = "0400";
    };
    u2f_keys = {
      file = "${config.home.homeDirectory}/.secrets/age/u2f_keys.age";
      path = "${config.home.homeDirectory}/.config/Yubico/u2f_keys";
      mode = "0400";
    };
    recipients = {
      file = "${config.home.homeDirectory}/.secrets/age/recipients.txt.age";
      mode = "0600";
    };

    # GPG
    sk_gpg = {
      file = "${config.home.homeDirectory}/.secrets/age/gpg/sk_F6D4E60AA57C59F4.gpg.age";
      path = "${config.home.homeDirectory}/.secrets/gpg/sk_F6D4E60AA57C59F4.gpg";
      mode = "0400";
    };
    rev_gpg = {
      file = "${config.home.homeDirectory}/.secrets/age/gpg/8174CFE1C67691E2784385110318B003218F9366.rev.age";
      path = "${config.home.homeDirectory}/.secrets/gpg/openpgp-revocs.d/8174CFE1C67691E2784385110318B003218F9366.rev";
      mode = "0400";
    };
    # SSH
    yubikey_5a_adjivas = {
      file = "${config.home.homeDirectory}/.secrets/age/ssh/adjivas-yubikey-5a-26273430.age";
      path = "${config.home.homeDirectory}/.ssh/yubikey-5a-adjivas";
      mode = "0400";
    };
    yubikey_5c_adjivas = {
      file = "${config.home.homeDirectory}/.secrets/age/ssh/adjivas-yubikey-5c-24636935.age";
      path = "${config.home.homeDirectory}/.ssh/yubikey-5c-adjivas";
      mode = "0400";
    };
    "games/zelda_ocarina_of_time_64.us.z64" = {
      file = "${config.home.homeDirectory}/.secrets/age/games/zelda_ocarina_of_time_64.us.z64.age";
      path = "${config.home.homeDirectory}/.games/zelda_ocarina_of_time_64.us.z64";
      mode = "0400";
    };
    "games/super_mario_64.us.z64" = {
      file = "${config.home.homeDirectory}/.secrets/age/games/super_mario_64.us.z64.age";
      path = "${config.home.homeDirectory}/.games/super_mario_64.us.z64";
      mode = "0400";
    };
  } // fontSecrets;
}
