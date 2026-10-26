{
  inputs,
  den,
  ...
}: {
  den.aspects.agenix-adjivas = {
    includes = [
      den.batteries.agenix-dir
    ];

    homeManager = {
      mkAgeSecretDir,
      config,
      osConfig,
      lib,
      ...
    }: let
      homeDir = config.home.homeDirectory;
      hostName = osConfig.networking.hostName;
    in {
      imports = [
        inputs.agenix.homeManagerModules.default
      ];

      # home-manager-adjivas.service
      # systemctl --user status agenix
      age = {
        identityPaths = ["/home/adjivas/.secrets/ident.txt"];

        secretsDir = "/home/adjivas/.agenix/agenix";
        secretsMountPoint = "/home/adjivas/.agenix/agenix.d";
      };

      home.activation.installAge = lib.hm.dag.entryAfter ["writeBoundary"] ''
        mkdir -p "${homeDir}/.secrets"
        chmod 0700 "${homeDir}/.secrets"
        chmod 0400 "${homeDir}/.secrets/ident.txt"
      '';

      age.secrets =
        (mkAgeSecretDir {
          sourceDir = "games/sm64mods";
          targetDir = "${homeDir}/.games/sm64mods";
        })
        // (mkAgeSecretDir {
          sourceDir = "blender";
          targetDir = "${homeDir}/.local/share/blender";
        })
        // (mkAgeSecretDir {
          sourceDir = "freecad";
          targetDir = "${homeDir}/.local/share/freecad";
        })
        // (mkAgeSecretDir {
          sourceDir = "fonts";
          targetDir = "${homeDir}/.local/share/fonts";
        })
        // (mkAgeSecretDir {
          sourceDir = "oxt";
          targetDir = "${homeDir}/.local/share/libreoffice";
        })
        // (mkAgeSecretDir {
          sourceDir = "tincr";
          targetDir = "${homeDir}/.local/share/tincr";
        })
        // {
          "contacts.vcf" = {
            file = "${homeDir}/.secrets/age/contacts.vcf.age";
            mode = "0400";
          };
          switch_prod = {
            file = "${homeDir}/.secrets/age/switch-prod.keys.age";
            path = "${homeDir}/.switch/prod.keys";
            mode = "0400";
          };
          openai = {
            file = "${homeDir}/.secrets/age/openai-token.txt.age";
            mode = "0400";
          };
          dreamland_cert_root = {
            file = "${homeDir}/.secrets/age/cert/dreamland-root-ca.cert.age";
            mode = "0400";
          };
          dreamland_key_root = {
            file = "${homeDir}/.secrets/age/cert/dreamland-root-ca.key.age";
            mode = "0400";
          };
          srht_cert = {
            file = "${homeDir}/.secrets/age/cert/srht.cert.age";
            mode = "0400";
          };
          srht_key = {
            file = "${homeDir}/.secrets/age/cert/srht.key.age";
            mode = "0400";
          };
          u2f_keys = {
            file = "${homeDir}/.secrets/age/yubico/u2f_adjivas_${hostName}_keys.age";
            path = "${homeDir}/.config/Yubico/u2f_keys";
            mode = "0400";
          };
          recipients = {
            file = "${homeDir}/.secrets/age/recipients.txt.age";
            mode = "0600";
          };
          lanmouse_fingerprints = {
            file = "${homeDir}/.secrets/age/lanmouse/fingerprints.txt.age";
            mode = "0600";
          };
          lanmouse_pem = {
            file = "${homeDir}/.secrets/age/lanmouse/pem.age";
            path = "${homeDir}/.config/lan-mouse/lan-mouse.pem";
          };
          cachix-dhall = {
            file = "${homeDir}/.secrets/age/cachix.dhall.age";
            path = "${homeDir}/.config/cachix/cachix.dhall";
            mode = "0600";
          };
          mathpass = {
            file = "${homeDir}/.secrets/age/mathpass-system76.age";
            path = "${homeDir}/.Wolfram/Licensing/mathpass";
            mode = "0644";
          };
          cal_framagenda = {
            file = "${homeDir}/.secrets/age/cal/framagenda.txt.age";
            mode = "0400";
          };

          # GPG
          sk_gpg = {
            file = "${homeDir}/.secrets/age/gpg/sk_F6D4E60AA57C59F4.gpg.age";
            path = "${homeDir}/.secrets/gpg/sk_F6D4E60AA57C59F4.gpg";
            mode = "0400";
          };
          rev_gpg = {
            file = "${homeDir}/.secrets/age/gpg/8174CFE1C67691E2784385110318B003218F9366.rev.age";
            path = "${homeDir}/.secrets/gpg/openpgp-revocs.d/8174CFE1C67691E2784385110318B003218F9366.rev";
            mode = "0400";
          };
          # SSH
          yubikey_5a_adjivas = {
            file = "${homeDir}/.secrets/age/ssh/adjivas-yubikey-5a-26273430.age";
            path = "${homeDir}/.ssh/yubikey-5a-adjivas";
            mode = "0400";
          };
          yubikey_5c_adjivas = {
            file = "${homeDir}/.secrets/age/ssh/adjivas-yubikey-5c-24636935.age";
            path = "${homeDir}/.ssh/yubikey-5c-adjivas";
            mode = "0400";
          };
          dreamland-nix-trusted-key = {
            file = "${homeDir}/.secrets/age/dreamland-nix-trusted-key.age";
            mode = "0400";
          };
          "games/zelda_ocarina_of_time_64.us.z64" = {
            file = "${homeDir}/.secrets/age/games/zelda_ocarina_of_time_64.us.z64.age";
            path = "${homeDir}/.games/zelda_ocarina_of_time_64.us.z64";
            mode = "0400";
          };
          "games/super_mario_64.us.z64" = {
            file = "${homeDir}/.secrets/age/games/super_mario_64.us.z64.age";
            path = "${homeDir}/.games/super_mario_64.us.z64";
            mode = "0400";
          };
        };
    };
  };
}
