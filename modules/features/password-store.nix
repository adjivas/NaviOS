{
  den.aspects.password-store.homeManager = {
    pkgs,
    config,
    ...
  }: {
    config = {
      programs.password-store = {
        enable = true;
        package = pkgs.passage;
        settings = {
          PASSAGE_DIR = "${config.home.homeDirectory}/.secrets/age/passage/";
          PASSAGE_IDENTITIES_FILE = "${config.home.homeDirectory}/.secrets/ident.txt";
        };
      };
    };
  };
}
