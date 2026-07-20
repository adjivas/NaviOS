{
  den.aspects.gpg.homeManager = {
    pkgs,
    lib,
    config,
    ...
  }: {
    options.gpg = {
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.pinentry-gnome3;
        description = "pinentry packages";
      };
    };
    config = {
      # home.packages = with pkgs; [
      #   sequoia-chameleon-gnupg
      #   # gnupg # required until https://github.com/NixOS/nixpkgs/issues/473387 is fixed
      # ];

      services.gpg-agent = {
        enable = true;
        pinentry.package = config.gpg.package;
      };
      programs.gpg = {
        enable = true;
        homedir = "${config.home.homeDirectory}/.secrets/gpg";
        settings = {
          use-agent = true;
        };
      };
    };
  };
}
