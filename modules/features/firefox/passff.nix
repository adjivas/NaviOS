{
  den.aspects.firefox-passff.homeManager = {
    lib,
    config,
    pkgs,
    ...
  }: {
    firefox = {
      nativeMessagingHosts = [
        (pkgs.passff-host.overrideAttrs {
          dontStrip = true;

          patchPhase = ''
            passage_bin="${config.programs.password-store.package}/bin/passage"

            runtime_path="${lib.makeBinPath [
              config.programs.password-store.package
              pkgs.util-linux
              pkgs.age
              pkgs.git
              pkgs.coreutils
            ]}"

            sed -E -i              's#^COMMAND *= *"pass"#COMMAND = "'"$passage_bin"'"#'              src/passff.py

            sed -E -i              's#^COMMAND_ENV *= *\{\}#COMMAND_ENV = {"TREE_CHARSET":"ISO-8859-1","PASSAGE_DIR":"${config.home.homeDirectory}/.secrets/age/passage","PASSAGE_IDENTITIES_FILE":"${config.home.homeDirectory}/.secrets/ident.txt","PATH":"'"$runtime_path"'"}#'              src/passff.py

            sed -E -i              's#"PATH": "[^"]*"#"PATH": "'"$runtime_path"'"#'              src/passff.py

            sed -i              '/^COMMAND_ENV *= *{$/a\    "PASSAGE_DIR":"'"${config.home.homeDirectory}/.secrets/age/passage"'",'              src/passff.py

            sed -i              '/^COMMAND_ENV *= *{$/a\    "PASSAGE_IDENTITIES_FILE":"'"${config.home.homeDirectory}/.secrets/ident.txt"'",'              src/passff.py
          '';
        })
      ];
      policies.ExtensionSettings."passff@invicem.pro" = {
        installation_mode = "force_installed";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/passff/latest.xpi";
        default_area = "navbar";
        private_browsing = true;
        temporarily_allow_weak_signatures = false;
      };
    };
  };
}
