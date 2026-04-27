{ pkgs, lib, config, ... }: {
  options = {
    gpg.enable = lib.mkEnableOption "enable gpg";
  };
  config = lib.mkIf config.gpg.enable {
    home.packages = with pkgs; [
      sequoia-chameleon-gnupg
      gnupg # required until https://github.com/NixOS/nixpkgs/issues/473387 is fixed
    ];

    services.gpg-agent = {
      enable = true;
      pinentry.package = pkgs.pinentry-gnome3;
    };
    programs.gpg = {
      enable = true;
      homedir = "${config.home.homeDirectory}/.secrets/gpg";
      settings = {
        use-agent = true;
      };
    };
  };
}
